import { Injectable, Logger } from "@nestjs/common";

import { RedisService } from "../redis/redis.service";

@Injectable()
export class RiskQueueService {
  private readonly logger = new Logger(RiskQueueService.name);

  constructor(private readonly redisService: RedisService) {}

  async enqueue(payload: Record<string, unknown>) {
    const result = await this.redisService.lpush(
      "queue:fraud-risk",
      JSON.stringify({
        ...payload,
        queuedAt: new Date().toISOString()
      })
    );

    if (result === null) {
      this.logger.warn("Fraud risk queue degraded; event was only logged");
      return {
        accepted: false,
        fallback: true
      };
    }

    return {
      accepted: true,
      depth: result
    };
  }
}
