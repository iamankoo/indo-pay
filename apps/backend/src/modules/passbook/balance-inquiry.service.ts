import { Injectable, NotFoundException } from "@nestjs/common";

import { PrismaService } from "../../common/prisma/prisma.service";

@Injectable()
export class BalanceInquiryService {
  constructor(private readonly prisma: PrismaService) {}

  async fetchBalance(accountId: string, userId: string) {
    const bankAccount = await this.prisma.bankAccount.findFirst({
      where: {
        id: accountId,
        userId
      }
    });

    if (!bankAccount) {
      throw new NotFoundException(`Bank account ${accountId} not found`);
    }

    const latestSnapshot = await this.prisma.accountBalanceSnapshot.findFirst({
      where: {
        bankAccountId: accountId
      },
      orderBy: {
        fetchedAt: "desc"
      }
    });

    const availableBalance =
      latestSnapshot?.availableBalance ?? 48650;
    const currentBalance =
      latestSnapshot?.currentBalance ?? 48990;

    const snapshot = await this.prisma.accountBalanceSnapshot.create({
      data: {
        userId,
        bankAccountId: accountId,
        availableBalance,
        currentBalance
      }
    });

    return {
      bankAccountId: bankAccount.id,
      maskedAccount: bankAccount.maskedAccount,
      availableBalance: snapshot.availableBalance,
      currentBalance: snapshot.currentBalance,
      fetchedAt: snapshot.fetchedAt
    };
  }

  async getMiniStatement(accountId: string, userId: string) {
    const bankAccount = await this.prisma.bankAccount.findFirst({
      where: {
        id: accountId,
        userId
      }
    });

    if (!bankAccount) {
      throw new NotFoundException(`Bank account ${accountId} not found`);
    }

    const recentTransactions = await this.prisma.transaction.findMany({
      where: {
        userId,
        rail: {
          in: ["UPI", "IMPS", "NEFT", "RTGS"]
        }
      },
      orderBy: {
        createdAt: "desc"
      },
      take: 5
    });

    return {
      bankAccountId: bankAccount.id,
      maskedAccount: bankAccount.maskedAccount,
      items: recentTransactions.map((transaction: (typeof recentTransactions)[number]) => ({
        transactionId: transaction.id,
        amount: transaction.amount,
        rail: transaction.rail,
        category: transaction.category,
        status: transaction.status,
        createdAt: transaction.createdAt
      }))
    };
  }
}
