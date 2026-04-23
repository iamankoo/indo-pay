import { HttpStatus, Injectable } from "@nestjs/common";

import { DomainException } from "../http/domain.exception";
import { RedisService } from "./redis.service";

@Injectable()
export class WalletLockService {
  private static readonly lockTtlMs = 5000;

  constructor(private readonly redisService: RedisService) {}

  async withLock<T>(subject: string, transactionKey: string, task: () => Promise<T>) {
    const redis = await this.redisService.getClient();

    if (!redis) {
      this.redisService.raiseFallbackAlert(
        "Wallet lock degraded because Redis is unavailable"
      );

      return task();
    }

    const key = `wallet-lock:${subject}`;
    const lockValue = `${transactionKey}:${Date.now()}`;
    const lockAcquired = await redis.set(
      key,
      lockValue,
      "PX",
      WalletLockService.lockTtlMs,
      "NX"
    );

    if (lockAcquired !== "OK") {
      throw new DomainException({
        status: HttpStatus.CONFLICT,
        code: "WALLET_LOCK_ACTIVE",
        message: "Another financial transaction is already in flight"
      });
    }

    try {
      return await task();
    } finally {
      const releaseScript = [
        "if redis.call('get', KEYS[1]) == ARGV[1] then",
        "  return redis.call('del', KEYS[1])",
        "end",
        "return 0"
      ].join("\n");

      await this.redisService.eval(releaseScript, 1, key, lockValue);
    }
  }
}
