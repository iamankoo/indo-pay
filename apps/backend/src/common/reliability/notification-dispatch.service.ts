import { Injectable } from "@nestjs/common";

import { NotificationsService } from "../../modules/notifications/notifications.service";
import { RedisService } from "../redis/redis.service";
import { hashString } from "./request-hash.util";

@Injectable()
export class NotificationDispatchService {
  constructor(
    private readonly notificationsService: NotificationsService,
    private readonly redisService: RedisService
  ) {}

  async dispatchRewardCredited(userId: string, amount: number, transactionKey: string) {
    const dedupeKey = `notification:${hashString(`${transactionKey}:reward`)}`;
    const reserved = await this.redisService.set(dedupeKey, "sent", 24 * 60 * 60, "NX");

    if (reserved === null) {
      return {
        queued: false,
        degraded: true,
        payload: this.notificationsService.rewardCredited(userId, amount)
      };
    }

    if (reserved !== "OK") {
      return {
        queued: false,
        duplicate: true,
        payload: null
      };
    }

    return {
      queued: true,
      payload: this.notificationsService.rewardCredited(userId, amount)
    };
  }
}
