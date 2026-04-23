import { HttpStatus, Injectable } from "@nestjs/common";

import { DomainException } from "../http/domain.exception";
import { RedisService } from "../redis/redis.service";

interface StoredIdempotencyRecord<T = unknown> {
  readonly requestHash: string;
  readonly status: "IN_PROGRESS" | "COMPLETED";
  readonly response?: T;
  readonly statusCode?: number;
  readonly updatedAt: string;
}

@Injectable()
export class IdempotencyService {
  private static readonly completedTtlSeconds = 24 * 60 * 60;

  private static readonly inFlightTtlSeconds = 5 * 60;

  constructor(private readonly redisService: RedisService) {}

  async execute<T>(
    scope: string,
    idempotencyKey: string | undefined,
    requestHash: string | undefined,
    action: () => Promise<T>
  ) {
    if (!idempotencyKey || !requestHash) {
      return action();
    }

    const storageKey = this.storageKey(scope, idempotencyKey);
    const existing = await this.redisService.getJson<StoredIdempotencyRecord<T>>(storageKey);

    if (existing) {
      if (existing.requestHash !== requestHash) {
        throw new DomainException({
          status: HttpStatus.CONFLICT,
          code: "IDEMPOTENCY_KEY_REUSED",
          message: "The idempotency key was already used with a different payload"
        });
      }

      if (existing.status === "COMPLETED") {
        return existing.response as T;
      }

      throw new DomainException({
        status: HttpStatus.CONFLICT,
        code: "REQUEST_ALREADY_IN_PROGRESS",
        message: "A matching request is already being processed"
      });
    }

    const reservation = await this.redisService.setJson(
      storageKey,
      {
        requestHash,
        status: "IN_PROGRESS",
        updatedAt: new Date().toISOString()
      } satisfies StoredIdempotencyRecord,
      IdempotencyService.inFlightTtlSeconds,
      "NX"
    );

    if (reservation === null) {
      return action();
    }

    if (reservation !== "OK") {
      const raceWinner = await this.redisService.getJson<StoredIdempotencyRecord<T>>(storageKey);
      if (raceWinner?.status === "COMPLETED") {
        return raceWinner.response as T;
      }

      throw new DomainException({
        status: HttpStatus.CONFLICT,
        code: "REQUEST_ALREADY_IN_PROGRESS",
        message: "A matching request is already being processed"
      });
    }

    try {
      const response = await action();

      await this.redisService.setJson(
        storageKey,
        {
          requestHash,
          status: "COMPLETED",
          response,
          statusCode: HttpStatus.OK,
          updatedAt: new Date().toISOString()
        } satisfies StoredIdempotencyRecord<T>,
        IdempotencyService.completedTtlSeconds
      );

      return response;
    } catch (error) {
      await this.redisService.del(storageKey);
      throw error;
    }
  }

  async assertUniqueReference(
    scope: string,
    referenceHash: string,
    requestKey?: string
  ) {
    const redis = await this.redisService.getClient();
    if (!redis) {
      return;
    }

    const key = `dedupe:${scope}:${referenceHash}`;
    const value = requestKey ?? referenceHash;
    const reserved = await redis.set(key, value, "EX", 120, "NX");

    if (reserved === "OK") {
      return;
    }

    const existingValue = await redis.get(key);
    if (existingValue === value) {
      return;
    }

    throw new DomainException({
      status: HttpStatus.CONFLICT,
      code: "DUPLICATE_REQUEST_BLOCKED",
      message: "A similar financial request was already received recently"
    });
  }

  private storageKey(scope: string, idempotencyKey: string) {
    return `idempotency:${scope}:${idempotencyKey}`;
  }
}
