import { Prisma } from "@prisma/client";
import { Injectable } from "@nestjs/common";

import { PrismaService } from "../../common/prisma/prisma.service";
import { NotificationsService } from "../notifications/notifications.service";

@Injectable()
export class RewardsExpiryJob {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService
  ) {}

  async runDailySweep() {
    const now = new Date();
    const expiringEntries = await this.prisma.walletEntry.findMany({
      where: {
        type: "CREDIT",
        status: "ACTIVE",
        expiresAt: {
          lt: now
        }
      }
    });

    const processed = await Promise.all(
      expiringEntries.map(async (entry: (typeof expiringEntries)[number]) => {
        await this.prisma.$transaction(async (tx: Prisma.TransactionClient) => {
          await tx.walletEntry.update({
            where: { id: entry.id },
            data: {
              status: "EXPIRED"
            }
          });

          await tx.walletEntry.create({
            data: {
              userId: entry.userId,
              txnId: entry.txnId,
              type: "EXPIRY",
              amount: entry.amount,
              status: "POSTED",
              description: "Promo wallet expiry"
            }
          });

          await tx.rewardExpiryJob.update({
            where: {
              walletEntryId: entry.id
            },
            data: {
              processedAt: now,
              status: "COMPLETED"
            }
          });
        });

        return this.notificationsService.expiryReminder(
          entry.userId,
          entry.amount,
          0
        );
      })
    );

    return {
      expiredEntriesProcessed: processed.length,
      notifications: processed
    };
  }
}
