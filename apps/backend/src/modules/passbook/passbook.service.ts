import { Injectable } from "@nestjs/common";

import { PrismaService } from "../../common/prisma/prisma.service";
import { WalletService } from "../wallet/wallet.service";

type PassbookTab =
  | "all"
  | "bank-transfers"
  | "wallet"
  | "cashback"
  | "bank-balance";

@Injectable()
export class PassbookService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly walletService: WalletService
  ) {}

  async getPassbook(input: {
    userId: string;
    tab: PassbookTab;
    page: number;
    limit: number;
    category?: string;
    minAmount?: number;
    maxAmount?: number;
  }) {
    const skip = (input.page - 1) * input.limit;
    const take = input.limit + 1;

    if (input.tab === "wallet") {
      const items = await this.prisma.walletEntry.findMany({
        where: { userId: input.userId },
        orderBy: { createdAt: "desc" },
        skip,
        take
      });

      return {
        tab: input.tab,
        page: input.page,
        hasMore: items.length > input.limit,
        nextPage: items.length > input.limit ? input.page + 1 : null,
        items: items.slice(0, input.limit).map((entry) => ({
          id: entry.id,
          type:
            entry.type === "CREDIT"
              ? "cashback_credit"
              : entry.type === "DEBIT"
                ? "cashback_used"
                : "cashback_expired",
          amount: entry.amount,
          direction: entry.type === "CREDIT" ? "credit" : "debit",
          sourceTxn: entry.txnId,
          expiresAt: entry.expiresAt,
          status: entry.status,
          description: entry.description,
          createdAt: entry.createdAt
        }))
      };
    }

    if (input.tab === "cashback") {
      const cashbackEntries = await this.prisma.walletEntry.findMany({
        where: {
          userId: input.userId,
          type: {
            in: ["CREDIT", "DEBIT", "EXPIRY"]
          }
        },
        orderBy: {
          createdAt: "desc"
        },
        skip,
        take
      });

      return {
        tab: input.tab,
        page: input.page,
        hasMore: cashbackEntries.length > input.limit,
        nextPage: cashbackEntries.length > input.limit ? input.page + 1 : null,
        items: cashbackEntries
          .slice(0, input.limit)
          .map((entry: (typeof cashbackEntries)[number]) => ({
            id: entry.id,
            type:
              entry.type === "CREDIT"
                ? "cashback_credit"
                : entry.type === "DEBIT"
                  ? "cashback_used"
                  : "cashback_expired",
            amount: entry.amount,
            direction: entry.type === "CREDIT" ? "credit" : "debit",
            sourceTxn: entry.txnId,
            expiresAt: entry.expiresAt,
            status: entry.status,
            description: entry.description,
            createdAt: entry.createdAt
          }))
      };
    }

    const transactions = await this.prisma.transaction.findMany({
      where: this.buildTransactionWhere(input),
      orderBy: {
        createdAt: "desc"
      },
      skip,
      take
    });

    if (input.tab === "all") {
      const [walletEntries, balanceSnapshots, walletSummary] = await Promise.all([
        this.prisma.walletEntry.findMany({
          where: { userId: input.userId },
          orderBy: {
            createdAt: "desc"
          },
          take
        }),
        this.prisma.accountBalanceSnapshot.findMany({
          where: { userId: input.userId },
          orderBy: {
            fetchedAt: "desc"
          },
          take: 3
        }),
        this.walletService.getWalletSummary(input.userId)
      ]);

      const merged = [
        ...transactions.map((transaction: (typeof transactions)[number]) => ({
          id: transaction.id,
          type: transaction.category.toLowerCase(),
          amount: transaction.amount,
          bankAmount: transaction.bankAmount,
          walletAmount: transaction.walletAmount,
          direction: "debit",
          rail: transaction.rail,
          status: transaction.status,
          referenceLabel: transaction.referenceLabel,
          createdAt: transaction.createdAt
        })),
        ...walletEntries.map((entry: (typeof walletEntries)[number]) => ({
          id: entry.id,
          type:
            entry.type === "CREDIT"
              ? "cashback_credit"
              : entry.type === "DEBIT"
                ? "cashback_used"
                : "cashback_expired",
          amount: entry.amount,
          direction: entry.type === "CREDIT" ? "credit" : "debit",
          sourceTxn: entry.txnId,
          expiresAt: entry.expiresAt,
          status: entry.status,
          description: entry.description,
          createdAt: entry.createdAt
        })),
        ...balanceSnapshots.map((snapshot) => ({
          id: snapshot.id,
          type: "balance_snapshot",
          amount: snapshot.availableBalance,
          direction: "info",
          currentBalance: snapshot.currentBalance,
          bankAccountId: snapshot.bankAccountId,
          createdAt: snapshot.fetchedAt
        }))
      ]
        .sort((left, right) => right.createdAt.getTime() - left.createdAt.getTime())
        .slice(0, input.limit);

      return {
        tab: input.tab,
        page: input.page,
        hasMore: transactions.length > input.limit || walletEntries.length > input.limit,
        nextPage:
          transactions.length > input.limit || walletEntries.length > input.limit
            ? input.page + 1
            : null,
        filters: ["recharge", "cashback", "qr", "IMPS", "NEFT", "RTGS"],
        monthlySummary: {
          walletBalance: walletSummary.promoWalletBalance,
          expiringIn7Days: walletSummary.expiringIn7Days,
          monthlyRedeemed: walletSummary.monthlyRedeemed,
          monthlyExpired: walletSummary.monthlyExpired
        },
        exportFormats: ["PDF", "CSV"],
        items: merged
      };
    }

    if (input.tab === "bank-balance") {
      const items = await this.prisma.accountBalanceSnapshot.findMany({
        where: { userId: input.userId },
        orderBy: {
          fetchedAt: "desc"
        },
        skip,
        take
      });

      return {
        tab: input.tab,
        page: input.page,
        hasMore: items.length > input.limit,
        nextPage: items.length > input.limit ? input.page + 1 : null,
        items: items.slice(0, input.limit).map((snapshot) => ({
          id: snapshot.id,
          type: "balance_snapshot",
          availableBalance: snapshot.availableBalance,
          currentBalance: snapshot.currentBalance,
          bankAccountId: snapshot.bankAccountId,
          createdAt: snapshot.fetchedAt
        }))
      };
    }

    return {
      tab: input.tab,
      page: input.page,
      hasMore: transactions.length > input.limit,
      nextPage: transactions.length > input.limit ? input.page + 1 : null,
      items: transactions.slice(0, input.limit).map((transaction: (typeof transactions)[number]) => ({
        id: transaction.id,
        type: transaction.category,
        amount: transaction.amount,
        bankAmount: transaction.bankAmount,
        walletAmount: transaction.walletAmount,
        direction: "debit",
        rail: transaction.rail,
        status: transaction.status,
        referenceLabel: transaction.referenceLabel,
        createdAt: transaction.createdAt
      }))
    };
  }

  private buildTransactionWhere(input: {
    userId: string;
    tab: PassbookTab;
    category?: string;
    minAmount?: number;
    maxAmount?: number;
  }) {
    const normalizedCategory = input.category?.toUpperCase();
    const railFilter =
      normalizedCategory && ["IMPS", "NEFT", "RTGS"].includes(normalizedCategory)
        ? normalizedCategory
        : undefined;

    return {
      userId: input.userId,
      ...(input.tab === "bank-transfers"
        ? {
            rail: {
              in: ["IMPS", "NEFT", "RTGS"]
            }
          }
        : {}),
      ...(railFilter ? { rail: railFilter } : {}),
      ...(!railFilter && normalizedCategory
        ? {
            category: {
              contains: normalizedCategory
            }
          }
        : {}),
      ...(input.minAmount || input.maxAmount
        ? {
            amount: {
              ...(input.minAmount ? { gte: input.minAmount } : {}),
              ...(input.maxAmount ? { lte: input.maxAmount } : {})
            }
          }
        : {})
    };
  }
}
