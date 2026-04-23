import { Injectable } from "@nestjs/common";

import { PrismaService } from "../../common/prisma/prisma.service";
import { RewardsService } from "../rewards/rewards.service";

@Injectable()
export class WalletService {
  constructor(
    private readonly rewardsService: RewardsService,
    private readonly prisma: PrismaService
  ) {}

  async getWalletSummary(userId: string) {
    const now = new Date();
    const inSevenDays = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

    const [
      promoWalletBalance,
      expiringIn7Days,
      monthlyRedeemed,
      monthlyExpired,
      upcomingExpiries
    ] = await Promise.all([
      this.getAvailableBalance(userId),
      this.prisma.walletEntry.aggregate({
        _sum: { amount: true },
        where: {
          userId,
          type: "CREDIT",
          status: "ACTIVE",
          expiresAt: {
            gte: now,
            lte: inSevenDays
          }
        }
      }),
      this.prisma.walletEntry.aggregate({
        _sum: { amount: true },
        where: {
          userId,
          type: "DEBIT",
          createdAt: {
            gte: monthStart
          }
        }
      }),
      this.prisma.walletEntry.aggregate({
        _sum: { amount: true },
        where: {
          userId,
          type: "EXPIRY",
          createdAt: {
            gte: monthStart
          }
        }
      }),
      this.prisma.walletEntry.findMany({
        where: {
          userId,
          type: "CREDIT",
          status: "ACTIVE",
          expiresAt: {
            gte: now
          }
        },
        orderBy: {
          expiresAt: "asc"
        },
        take: 4
      })
    ]);

    const redeemed = monthlyRedeemed._sum.amount ?? 0;
    const expired = monthlyExpired._sum.amount ?? 0;
    const expiringSoon = expiringIn7Days._sum.amount ?? 0;

    return {
      userId,
      promoWalletBalance,
      expiringIn7Days: expiringSoon,
      monthlyRedeemed: redeemed,
      monthlyExpired: expired,
      redemptionUsageMeter: {
        capPercent: 1.6,
        consumedThisMonth: redeemed,
        burnThisMonth: expired,
        availableBalance: promoWalletBalance
      },
      rewardExpiryChips: upcomingExpiries.map((entry) => ({
        id: entry.id,
        amount: entry.amount,
        expiresAt: entry.expiresAt,
        label:
          entry.expiresAt && entry.expiresAt <= inSevenDays
            ? "Expiring this week"
            : "Upcoming expiry"
      })),
      upcomingExpiries: upcomingExpiries.map((entry) => ({
        id: entry.id,
        amount: entry.amount,
        expiresAt: entry.expiresAt,
        description: entry.description
      }))
    };
  }

  async getAvailableBalance(userId: string) {
    const [credits, debits, expiries] = await Promise.all([
      this.prisma.walletEntry.aggregate({
        _sum: { amount: true },
        where: { userId, type: "CREDIT" }
      }),
      this.prisma.walletEntry.aggregate({
        _sum: { amount: true },
        where: { userId, type: "DEBIT" }
      }),
      this.prisma.walletEntry.aggregate({
        _sum: { amount: true },
        where: { userId, type: "EXPIRY" }
      })
    ]);

    return (
      (credits._sum.amount ?? 0) -
      (debits._sum.amount ?? 0) -
      (expiries._sum.amount ?? 0)
    );
  }

  async listWalletEntries(userId: string, limit = 20) {
    return this.prisma.walletEntry.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
      take: limit
    });
  }

  async previewRedemption(input: {
    transactionAmount: number;
    walletBalance?: number;
    userId?: string;
  }) {
    const walletBalance =
      input.walletBalance ??
      (input.userId ? await this.getAvailableBalance(input.userId) : 0);

    return this.rewardsService.previewWalletSplit(
      input.transactionAmount,
      walletBalance
    );
  }
}
