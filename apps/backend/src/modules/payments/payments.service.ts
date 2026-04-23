import { Prisma, Transaction, TransactionStatus } from "@prisma/client";
import { HttpStatus, Injectable, NotFoundException } from "@nestjs/common";

import { DomainException } from "../../common/http/domain.exception";
import { WalletLockService } from "../../common/redis/wallet-lock.service";
import { DeadLetterQueueService } from "../../common/reliability/dead-letter-queue.service";
import { IdempotencyService } from "../../common/reliability/idempotency.service";
import { NotificationDispatchService } from "../../common/reliability/notification-dispatch.service";
import { FinancialRequestContext } from "../../common/reliability/request-context";
import { createTransactionReferenceHash } from "../../common/reliability/request-hash.util";
import { RiskQueueService } from "../../common/reliability/risk-queue.service";
import { WebhookSecurityService } from "../../common/reliability/webhook-security.service";
import { PrismaService } from "../../common/prisma/prisma.service";
import { FraudService } from "../fraud/fraud.service";
import { RewardsService } from "../rewards/rewards.service";
import { WalletService } from "../wallet/wallet.service";
import { CreatePaymentDto } from "./dto/create-payment.dto";
import { PspCallbackDto } from "./dto/psp-callback.dto";

@Injectable()
export class PaymentsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly rewardsService: RewardsService,
    private readonly fraudService: FraudService,
    private readonly walletService: WalletService,
    private readonly walletLockService: WalletLockService,
    private readonly idempotencyService: IdempotencyService,
    private readonly riskQueueService: RiskQueueService,
    private readonly notificationDispatchService: NotificationDispatchService,
    private readonly webhookSecurityService: WebhookSecurityService,
    private readonly deadLetterQueueService: DeadLetterQueueService
  ) {}

  async processPayment(
    input: CreatePaymentDto,
    context: FinancialRequestContext = {}
  ) {
    const userId = input.userId ?? "usr_demo_001";
    const referenceHash = createTransactionReferenceHash([
      userId,
      input.merchantId ?? "direct",
      input.amount,
      input.category,
      input.rail ?? "UPI",
      input.referenceLabel ?? ""
    ]);

    return this.idempotencyService.execute(
      "payments",
      context.idempotencyKey ?? referenceHash,
      context.requestHash ?? referenceHash,
      async () =>
        this.walletLockService.withLock(`wallet:${userId}`, referenceHash, async () => {
          await this.idempotencyService.assertUniqueReference(
            "payments",
            referenceHash,
            context.idempotencyKey
          );

          const user = await this.prisma.user.findUnique({
            where: { id: userId }
          });

          if (!user) {
            throw new NotFoundException(`User ${userId} not found`);
          }

          const existingTransaction = await this.prisma.transaction.findFirst({
            where: {
              providerRef: referenceHash
            }
          });

          if (existingTransaction) {
            return this.buildExistingPaymentReceipt(existingTransaction);
          }

          const startOfDay = new Date();
          startOfDay.setHours(0, 0, 0, 0);

          const [walletBalance, sameMerchantCountToday, userDailyCashbackTotal] =
            await Promise.all([
              this.walletService.getAvailableBalance(userId),
              input.merchantId
                ? this.prisma.transaction.count({
                    where: {
                      userId,
                      merchantId: input.merchantId,
                      status: TransactionStatus.SUCCESS,
                      createdAt: { gte: startOfDay }
                    }
                  })
                : Promise.resolve(0),
              this.prisma.walletEntry.aggregate({
                _sum: { amount: true },
                where: {
                  userId,
                  type: "CREDIT",
                  createdAt: {
                    gte: startOfDay
                  }
                }
              })
            ]);

          const fraudDecision = this.fraudService.screenTransaction({
            sameMerchantCountToday,
            deviceSeenOnMultipleAccounts:
              input.deviceSeenOnMultipleAccounts ?? false,
            merchantLoopDetected: input.merchantLoopDetected ?? false,
            sameVpaCycleDetected: input.sameVpaCycleDetected ?? false
          });

          const paymentSplit = await this.walletService.previewRedemption({
            transactionAmount: input.amount,
            walletBalance
          });

          const rewardDecision = this.rewardsService.evaluateTransaction(
            {
              amount: input.amount,
              category: input.category,
              isSelfTransfer: input.category.toUpperCase() === "SELF_TRANSFER"
            },
            userDailyCashbackTotal._sum.amount ?? 0
          );

          const result = await this.prisma.$transaction(
            async (tx: Prisma.TransactionClient) => {
              const transaction = await tx.transaction.create({
                data: {
                  userId,
                  merchantId: input.merchantId,
                  amount: input.amount,
                  bankAmount: paymentSplit.bankAmount,
                  walletAmount: paymentSplit.walletUse,
                  category: input.category,
                  rail: input.rail ?? "UPI",
                  status: TransactionStatus.SUCCESS,
                  providerRef: referenceHash,
                  referenceLabel: input.referenceLabel ?? input.category,
                  metadata: {
                    transactionReferenceHash: referenceHash,
                    requestId: context.requestId ?? null,
                    ipAddress: context.ipAddress ?? null,
                    noDoubleCashbackOnRetry: true
                  }
                }
              });

              let walletDebit = null;
              if (paymentSplit.walletUse > 0) {
                walletDebit = await tx.walletEntry.create({
                  data: {
                    userId,
                    txnId: transaction.id,
                    type: "DEBIT",
                    amount: paymentSplit.walletUse,
                    status: "APPLIED",
                    description: "Promo wallet redemption"
                  }
                });
              }

              let cashbackEntry = null;
              if (
                fraudDecision.allowCashback &&
                rewardDecision.eligible &&
                rewardDecision.cashbackAmount > 0
              ) {
                const rewardExpiresAt =
                  rewardDecision.expiresAt ??
                  this.rewardsService.getExpiryDate().toISOString();

                cashbackEntry = await tx.walletEntry.create({
                  data: {
                    userId,
                    txnId: transaction.id,
                    type: "CREDIT",
                    amount: rewardDecision.cashbackAmount,
                    expiresAt: new Date(rewardExpiresAt),
                    status: "ACTIVE",
                    description: "11 percent promo cashback"
                  }
                });

                await tx.rewardExpiryJob.create({
                  data: {
                    walletEntryId: cashbackEntry.id,
                    scheduledFor:
                      cashbackEntry.expiresAt ?? this.rewardsService.getExpiryDate(),
                    status: "PENDING"
                  }
                });
              }

              if (fraudDecision.flags.length > 0) {
                await tx.fraudEvent.createMany({
                  data: fraudDecision.flags.map((flag, index) => ({
                    userId,
                    merchantId: input.merchantId,
                    reason: flag,
                    riskScore: 70 + index * 5,
                    metadata: {
                      category: input.category,
                      amount: input.amount,
                      referenceHash
                    }
                  }))
                });
              }

              return {
                transaction,
                walletDebit,
                cashbackEntry
              };
            }
          );

          if (fraudDecision.flags.length > 0) {
            await this.riskQueueService.enqueue({
              userId,
              merchantId: input.merchantId ?? null,
              referenceHash,
              amount: input.amount,
              flags: fraudDecision.flags
            });
          }

          const notification = result.cashbackEntry
            ? await this.notificationDispatchService.dispatchRewardCredited(
                userId,
                result.cashbackEntry.amount,
                referenceHash
              )
            : null;

          return {
            transactionId: result.transaction.id,
            status: result.transaction.status,
            userId,
            merchantId: input.merchantId ?? null,
            amount: input.amount,
            bankAmount: result.transaction.bankAmount,
            walletAmount: result.transaction.walletAmount,
            cashback: fraudDecision.allowCashback ? rewardDecision : null,
            walletBalanceAfterTxn: await this.walletService.getAvailableBalance(
              userId
            ),
            notification,
            fraudFlags: fraudDecision.flags,
            referenceHash
          };
        })
    );
  }

  async createBillPayment(input: {
    userId?: string;
    billerType: string;
    amount: number;
  }) {
    const userId = input.userId ?? "usr_demo_001";
    const transaction = await this.prisma.transaction.create({
      data: {
        userId,
        amount: input.amount,
        bankAmount: input.amount,
        walletAmount: 0,
        category: input.billerType,
        rail: "UPI",
        status: TransactionStatus.PENDING,
        referenceLabel: input.billerType
      }
    });

    return {
      orderId: transaction.id,
      userId,
      billerType: input.billerType,
      amount: input.amount,
      status: transaction.status
    };
  }

  async handlePspCallback(
    body: PspCallbackDto,
    rawBody: string,
    signature: string
  ) {
    const secret = process.env.PSP_WEBHOOK_SECRET ?? "indo-pay-psp-secret";

    if (!this.webhookSecurityService.verifySignature(rawBody, signature, secret)) {
      throw new DomainException({
        status: HttpStatus.UNAUTHORIZED,
        code: "INVALID_WEBHOOK_SIGNATURE",
        message: "PSP callback signature verification failed"
      });
    }

    const reservation = await this.webhookSecurityService.reserveWebhook(
      body.eventType,
      body.providerRef,
      signature
    );

    if (reservation.replay) {
      return {
        accepted: true,
        replay: true
      };
    }

    try {
      const transaction = await this.prisma.transaction.findFirst({
        where: {
          OR: [
            { providerRef: body.providerRef },
            ...(body.transactionId ? [{ id: body.transactionId }] : [])
          ]
        }
      });

      if (!transaction) {
        throw new NotFoundException(
          `Transaction not found for provider reference ${body.providerRef}`
        );
      }

      const updated = await this.prisma.transaction.update({
        where: {
          id: transaction.id
        },
        data: {
          status: body.status,
          metadata: {
            ...(typeof transaction.metadata === "object" && transaction.metadata
              ? transaction.metadata
              : {}),
            callbackEventType: body.eventType,
            callbackAmount: body.amount ?? null
          }
        }
      });

      await this.webhookSecurityService.markProcessed(reservation.record.id, 200);

      return {
        accepted: true,
        replay: false,
        transactionId: updated.id,
        status: updated.status
      };
    } catch (error) {
      await this.deadLetterQueueService.enqueue("callbacks", {
        providerRef: body.providerRef,
        eventType: body.eventType,
        status: body.status,
        reason: error instanceof Error ? error.message : "Unknown error"
      });

      throw error;
    }
  }

  private async buildExistingPaymentReceipt(transaction: Transaction) {
    const cashbackEntry = await this.prisma.walletEntry.findFirst({
      where: {
        txnId: transaction.id,
        type: "CREDIT"
      }
    });
    const fraudFlags = transaction.providerRef
      ? await this.prisma.fraudEvent.findMany({
          where: {
            metadata: {
              path: ["referenceHash"],
              equals: transaction.providerRef
            }
          },
          take: 5
        })
      : [];

    return {
      transactionId: transaction.id,
      status: transaction.status,
      userId: transaction.userId,
      merchantId: transaction.merchantId,
      amount: transaction.amount,
      bankAmount: transaction.bankAmount,
      walletAmount: transaction.walletAmount,
      cashback: cashbackEntry
        ? {
            eligible: true,
            reason: "IDEMPOTENT_REPLAY",
            cashbackAmount: cashbackEntry.amount,
            expiresAt: cashbackEntry.expiresAt?.toISOString() ?? null
          }
        : null,
      walletBalanceAfterTxn: await this.walletService.getAvailableBalance(
        transaction.userId
      ),
      notification: null,
      fraudFlags: fraudFlags.map((flag) => flag.reason),
      referenceHash: transaction.providerRef
    };
  }
}
