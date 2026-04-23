import { TransactionStatus } from "@prisma/client";
import { HttpStatus, Injectable } from "@nestjs/common";

import { DomainException } from "../../common/http/domain.exception";
import { PrismaService } from "../../common/prisma/prisma.service";
import { RedisService } from "../../common/redis/redis.service";
import { WalletLockService } from "../../common/redis/wallet-lock.service";
import { IdempotencyService } from "../../common/reliability/idempotency.service";
import { FinancialRequestContext } from "../../common/reliability/request-context";
import {
  createTransactionReferenceHash,
  hashString
} from "../../common/reliability/request-hash.util";
import { CreateBeneficiaryDto } from "./dto/create-beneficiary.dto";
import { CreateTransferDto } from "./dto/create-transfer.dto";
import { PreviewTransferDto } from "./dto/preview-transfer.dto";

export interface BeneficiaryRecord {
  readonly id: string;
  readonly userId: string;
  readonly beneficiaryName: string;
  readonly nickname: string;
  readonly ifsc: string;
  readonly bankName: string;
  readonly accountNumber: string;
  readonly accountNumberMasked: string;
  readonly createdAt: string;
}

@Injectable()
export class BankTransfersService {
  private readonly bankDirectory: Record<string, string> = {
    HDFC: "HDFC Bank",
    ICIC: "ICICI Bank",
    SBIN: "State Bank of India",
    UTIB: "Axis Bank",
    KKBK: "Kotak Mahindra Bank"
  };

  constructor(
    private readonly prisma: PrismaService,
    private readonly redisService: RedisService,
    private readonly walletLockService: WalletLockService,
    private readonly idempotencyService: IdempotencyService
  ) {}

  async addBeneficiary(
    input: CreateBeneficiaryDto,
    context: FinancialRequestContext
  ) {
    const userId = input.userId ?? "usr_demo_001";

    if (input.accountNumber !== input.confirmAccountNumber) {
      throw new DomainException({
        status: HttpStatus.UNPROCESSABLE_ENTITY,
        code: "ACCOUNT_NUMBER_MISMATCH",
        message: "Account number and re-entered account number must match"
      });
    }

    const beneficiaryName =
      input.beneficiaryName ??
      (await this.fetchBeneficiaryName(input.accountNumber, input.ifsc)).beneficiaryName;
    const bank = this.validateIfsc(input.ifsc);
    const referenceHash = createTransactionReferenceHash([
      userId,
      input.accountNumber,
      input.ifsc,
      input.nickname ?? beneficiaryName
    ]);

    return this.idempotencyService.execute(
      "bank-beneficiary",
      context.idempotencyKey,
      context.requestHash,
      async () => {
        await this.idempotencyService.assertUniqueReference(
          "bank-beneficiary",
          referenceHash,
          context.idempotencyKey
        );

        const beneficiary: BeneficiaryRecord = {
          id: `bnf_${Date.now()}`,
          userId,
          beneficiaryName,
          nickname: input.nickname ?? beneficiaryName.split(" ")[0] ?? "Beneficiary",
          ifsc: input.ifsc,
          bankName: bank.bankName,
          accountNumber: input.accountNumber,
          accountNumberMasked: this.maskAccountNumber(input.accountNumber),
          createdAt: new Date().toISOString()
        };

        const existing = await this.getStoredBeneficiaries(userId);
        const merged = [
          beneficiary,
          ...existing.filter(
            (record) =>
              !(
                record.accountNumber === input.accountNumber &&
                record.ifsc === input.ifsc
              )
          )
        ].slice(0, 10);

        await this.redisService.setJson(
          this.beneficiariesKey(userId),
          merged,
          30 * 24 * 60 * 60
        );

        return beneficiary;
      }
    );
  }

  async listBeneficiaries(userId: string) {
    const stored = await this.getStoredBeneficiaries(userId);
    if (stored.length > 0) {
      return stored.map((beneficiary) => ({
        ...beneficiary,
        accountNumber: undefined
      }));
    }

    const recentTransfers = await this.prisma.transaction.findMany({
      where: {
        userId,
        category: "BANK_TRANSFER",
        status: TransactionStatus.SUCCESS
      },
      orderBy: {
        createdAt: "desc"
      },
      take: 5
    });

    return recentTransfers.flatMap((transaction) => {
      const metadata = transaction.metadata as
        | {
            readonly beneficiary?: Omit<BeneficiaryRecord, "accountNumber">;
          }
        | null;

      return metadata?.beneficiary ? [metadata.beneficiary] : [];
    });
  }

  validateIfsc(ifsc: string) {
    const bankCode = ifsc.slice(0, 4);
    const bankName = this.bankDirectory[bankCode] ?? "Partner Bank";

    return {
      ifsc,
      valid: /^[A-Z]{4}0[A-Z0-9]{6}$/.test(ifsc),
      bankCode,
      bankName,
      supportsImmediateSettlement: bankCode !== "SBIN"
    };
  }

  async fetchBeneficiaryName(accountNumber: string, ifsc: string) {
    const profileSeed = hashString(`${accountNumber}:${ifsc}`).slice(0, 2);
    const names = [
      "Ananya Sharma",
      "Rohan Enterprises",
      "Jupiter Foods",
      "Indo Retail Pvt Ltd",
      "Maya Services"
    ];
    const index = Number.parseInt(profileSeed, 16) % names.length;

    return {
      accountNumber: this.maskAccountNumber(accountNumber),
      ifsc,
      beneficiaryName: names[index] ?? "Verified Beneficiary",
      fetchedAt: new Date().toISOString()
    };
  }

  previewTransfer(input: PreviewTransferDto) {
    const rail = this.resolveRail(input.amount, input.rail);

    return {
      amount: input.amount,
      walletAmount: 0,
      bankAmount: input.amount,
      fee: 0,
      rail: rail.name,
      eta: rail.eta,
      note: input.note ?? null,
      availableRails: ["IMPS", "NEFT", "RTGS", "SMART_QUICK"],
      railReason: rail.reason
    };
  }

  async createTransfer(
    input: CreateTransferDto,
    context: FinancialRequestContext
  ) {
    const userId = input.userId ?? "usr_demo_001";
    const rail = this.resolveRail(input.amount, input.rail);
    const beneficiary: BeneficiaryRecord = {
      id: `bnf_${hashString(`${input.accountNumber}:${input.ifsc}`).slice(0, 12)}`,
      userId,
      beneficiaryName: input.beneficiaryName,
      nickname: input.nickname ?? input.beneficiaryName.split(" ")[0] ?? "Beneficiary",
      ifsc: input.ifsc,
      bankName: this.validateIfsc(input.ifsc).bankName,
      accountNumber: input.accountNumber,
      accountNumberMasked: this.maskAccountNumber(input.accountNumber),
      createdAt: new Date().toISOString()
    };

    const referenceHash = createTransactionReferenceHash([
      userId,
      beneficiary.accountNumber,
      beneficiary.ifsc,
      input.amount,
      rail.name,
      input.note ?? ""
    ]);

    return this.idempotencyService.execute(
      "bank-transfer",
      context.idempotencyKey ?? referenceHash,
      context.requestHash ?? referenceHash,
      async () =>
        this.walletLockService.withLock(`bank-transfer:${userId}`, referenceHash, async () => {
          await this.idempotencyService.assertUniqueReference(
            "bank-transfer",
            referenceHash,
            context.idempotencyKey
          );

          const transaction = await this.prisma.transaction.create({
            data: {
              userId,
              amount: input.amount,
              bankAmount: input.amount,
              walletAmount: 0,
              category: "BANK_TRANSFER",
              rail: rail.name,
              status: TransactionStatus.SUCCESS,
              providerRef: referenceHash,
              referenceLabel: input.note ?? beneficiary.nickname,
              metadata: {
                note: input.note ?? null,
                beneficiary: {
                  id: beneficiary.id,
                  userId: beneficiary.userId,
                  beneficiaryName: beneficiary.beneficiaryName,
                  nickname: beneficiary.nickname,
                  ifsc: beneficiary.ifsc,
                  bankName: beneficiary.bankName,
                  accountNumberMasked: beneficiary.accountNumberMasked,
                  createdAt: beneficiary.createdAt
                },
                railReason: rail.reason,
                transferType: input.rail ?? "SMART_QUICK"
              }
            }
          });

          const existing = await this.getStoredBeneficiaries(userId);
          await this.redisService.setJson(
            this.beneficiariesKey(userId),
            [beneficiary, ...existing.filter((item) => item.id !== beneficiary.id)].slice(
              0,
              10
            ),
            30 * 24 * 60 * 60
          );

          return {
            transactionId: transaction.id,
            status: transaction.status,
            amount: transaction.amount,
            bankAmount: transaction.bankAmount,
            walletAmount: transaction.walletAmount,
            rail: rail.name,
            eta: rail.eta,
            beneficiary: {
              beneficiaryName: beneficiary.beneficiaryName,
              nickname: beneficiary.nickname,
              ifsc: beneficiary.ifsc,
              bankName: beneficiary.bankName,
              accountNumberMasked: beneficiary.accountNumberMasked
            },
            referenceHash
          };
        })
    );
  }

  private beneficiariesKey(userId: string) {
    return `bank-beneficiaries:${userId}`;
  }

  private async getStoredBeneficiaries(userId: string) {
    return (
      (await this.redisService.getJson<BeneficiaryRecord[]>(
        this.beneficiariesKey(userId)
      )) ?? []
    );
  }

  private maskAccountNumber(accountNumber: string) {
    return `${"*".repeat(Math.max(accountNumber.length - 4, 0))}${accountNumber.slice(-4)}`;
  }

  private resolveRail(amount: number, preferredRail?: string) {
    if (preferredRail && preferredRail !== "SMART_QUICK") {
      return {
        name: preferredRail,
        eta:
          preferredRail === "IMPS"
            ? "Instant"
            : preferredRail === "NEFT"
              ? "Under 2 hours"
              : "Same day during settlement window",
        reason: "Customer-selected rail"
      };
    }

    if (amount <= 5000) {
      return {
        name: "IMPS",
        eta: "Instant",
        reason: "Smart quick routed the transfer through instant settlement"
      };
    }

    if (amount < 200000) {
      return {
        name: "NEFT",
        eta: "Under 2 hours",
        reason: "Smart quick optimized for the lower-cost bank rail"
      };
    }

    return {
      name: "RTGS",
      eta: "Same day during settlement window",
      reason: "High-value transfer routed through RTGS"
    };
  }
}
