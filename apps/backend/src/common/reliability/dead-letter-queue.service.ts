import { Injectable, Logger } from "@nestjs/common";

import { RedisService } from "../redis/redis.service";

@Injectable()
export class DeadLetterQueueService {
  private readonly logger = new Logger(DeadLetterQueueService.name);

  constructor(private readonly redisService: RedisService) {}

  async enqueue(topic: string, payload: Record<string, unknown>) {
    const result = await this.redisService.lpush(
      `dlq:${topic}`,
      JSON.stringify({
        ...payload,
        queuedAt: new Date().toISOString()
      })
    );

    if (result === null) {
      this.logger.error(`DLQ degraded for ${topic}`);
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
