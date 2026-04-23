import { Injectable } from "@nestjs/common";

import { PrismaService } from "../../common/prisma/prisma.service";

@Injectable()
export class AnalyticsService {
  constructor(private readonly prisma: PrismaService) {}

  async getDashboard() {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);
    const startOfWeek = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

    const [
      totalTransactions,
      successfulTransactions,
      gmvToday,
      dau,
      wau,
      rechargeVolume,
      merchantVolume,
      cashbackIssuedToday,
      cashbackExpiredToday,
      cashbackRedeemedToday,
      walletLiabilityCredits,
      walletLiabilityDebits,
      walletLiabilityExpired,
      fraudAlerts,
      bankTransferVolume,
      topMerchantTransactions,
      cityMerchants,
      cityTransactions,
      imphalMerchants,
      imphalTransactions
    ] = await Promise.all([
      this.prisma.transaction.count(),
      this.prisma.transaction.count({
        where: {
          status: "SUCCESS"
        }
      }),
      this.prisma.transaction.aggregate({
        _sum: { amount: true },
        where: {
          status: "SUCCESS",
          createdAt: { gte: startOfDay }
        }
      }),
      this.prisma.transaction.groupBy({
        by: ["userId"],
        where: {
          createdAt: { gte: startOfDay },
          status: "SUCCESS"
        }
      }),
      this.prisma.transaction.groupBy({
        by: ["userId"],
        where: {
          createdAt: { gte: startOfWeek },
          status: "SUCCESS"
        }
      }),
      this.prisma.transaction.aggregate({
        _sum: { amount: true },
        where: {
          status: "SUCCESS",
          category: {
            in: ["RECHARGE", "MOBILE", "DTH", "FASTAG"]
          }
        }
      }),
      this.prisma.transaction.aggregate({
        _sum: { amount: true },
        where: {
          status: "SUCCESS",
          merchantId: {
            not: null
          }
        }
      }),
      this.prisma.walletEntry.aggregate({
        _sum: { amount: true },
        where: {
          type: "CREDIT",
          createdAt: { gte: startOfDay }
        }
      }),
      this.prisma.walletEntry.aggregate({
        _sum: { amount: true },
        where: {
          type: "EXPIRY",
          createdAt: { gte: startOfDay }
        }
      }),
      this.prisma.walletEntry.aggregate({
        _sum: { amount: true },
        where: {
          type: "DEBIT",
          createdAt: { gte: startOfDay }
        }
      }),
      this.prisma.walletEntry.aggregate({
        _sum: { amount: true },
        where: {
          type: "CREDIT"
        }
      }),
      this.prisma.walletEntry.aggregate({
        _sum: { amount: true },
        where: {
          type: "DEBIT"
        }
      }),
      this.prisma.walletEntry.aggregate({
        _sum: { amount: true },
        where: {
          type: "EXPIRY"
        }
      }),
      this.prisma.fraudEvent.findMany({
        orderBy: {
          createdAt: "desc"
        },
        take: 10
      }),
      this.prisma.transaction.aggregate({
        _sum: { amount: true },
        where: {
          status: "SUCCESS",
          rail: {
            in: ["IMPS", "NEFT", "RTGS"]
          }
        }
      }),
      this.prisma.transaction.groupBy({
        by: ["merchantId"],
        where: {
          status: "SUCCESS",
          merchantId: {
            not: null
          },
          createdAt: { gte: thirtyDaysAgo }
        },
        _sum: { amount: true },
        _count: { merchantId: true },
        orderBy: {
          _sum: {
            amount: "desc"
          }
        },
        take: 5
      }),
      this.prisma.merchant.findMany({
        select: {
          id: true,
          city: true
        }
      }),
      this.prisma.transaction.findMany({
        where: {
          merchantId: {
            not: null
          },
          status: "SUCCESS",
          createdAt: { gte: thirtyDaysAgo }
        },
        select: {
          merchantId: true,
          amount: true
        }
      }),
      this.prisma.merchant.findMany({
        where: {
          city: {
            equals: "Imphal",
            mode: "insensitive"
          }
        },
        select: {
          id: true
        }
      }),
      this.prisma.transaction.findMany({
        where: {
          status: "SUCCESS",
          merchant: {
            city: {
              equals: "Imphal",
              mode: "insensitive"
            }
          }
        },
        select: {
          userId: true,
          amount: true
        }
      })
    ]);

    const cityAdoption = cityMerchants.reduce<
      Array<{ city: string; merchants: number; gmv: number }>
    >((accumulator, merchant) => {
      const existing = accumulator.find((entry) => entry.city === merchant.city);
      if (existing) {
        existing.merchants += 1;
        return accumulator;
      }

      accumulator.push({
        city: merchant.city,
        merchants: 1,
        gmv: 0
      });

      return accumulator;
    }, []);

    for (const transaction of cityTransactions) {
      const merchant = cityMerchants.find((item) => item.id === transaction.merchantId);
      if (!merchant) {
        continue;
      }

      const cityMetric = cityAdoption.find((entry) => entry.city === merchant.city);
      if (cityMetric) {
        cityMetric.gmv += transaction.amount;
      }
    }

    const walletLiability =
      (walletLiabilityCredits._sum.amount ?? 0) -
      (walletLiabilityDebits._sum.amount ?? 0) -
      (walletLiabilityExpired._sum.amount ?? 0);
    const rewardBurnPercent =
      (walletLiabilityCredits._sum.amount ?? 0) === 0
        ? 0
        : Number(
            (
              ((walletLiabilityDebits._sum.amount ?? 0) /
                (walletLiabilityCredits._sum.amount ?? 1)) *
              100
            ).toFixed(2)
          );

    return {
      gmvToday: gmvToday._sum.amount ?? 0,
      dau: dau.length,
      wau: wau.length,
      rechargeVolume: rechargeVolume._sum.amount ?? 0,
      merchantVolume: merchantVolume._sum.amount ?? 0,
      cashbackIssuedToday: cashbackIssuedToday._sum.amount ?? 0,
      cashbackRedeemedToday: cashbackRedeemedToday._sum.amount ?? 0,
      cashbackExpiredToday: cashbackExpiredToday._sum.amount ?? 0,
      walletLiability,
      rewardBurnPercent,
      transactionSuccessRate:
        totalTransactions === 0
          ? 0
          : Number(((successfulTransactions / totalTransactions) * 100).toFixed(2)),
      bankTransferVolume: bankTransferVolume._sum.amount ?? 0,
      topMerchants: topMerchantTransactions.map((merchant) => ({
        merchantId: merchant.merchantId,
        volume: merchant._sum.amount ?? 0,
        orders: merchant._count.merchantId
      })),
      fraudAlerts: fraudAlerts.map((flag) => ({
        id: flag.id,
        reason: flag.reason,
        riskScore: flag.riskScore,
        createdAt: flag.createdAt
      })),
      retentionCohorts: [
        {
          cohort: "30-day repeaters",
          retainedUsers: wau.length,
          retainedPercent:
            dau.length === 0
              ? 0
              : Number(((wau.length / dau.length) * 100).toFixed(2))
        }
      ],
      cityWiseAdoption: cityAdoption.sort((left, right) => right.gmv - left.gmv),
      imphalBetaCohort: {
        merchants: imphalMerchants.length,
        activeUsers: new Set(imphalTransactions.map((transaction) => transaction.userId)).size,
        gmv: imphalTransactions.reduce(
          (sum, transaction) => sum + transaction.amount,
          0
        )
      }
    };
  }
}
