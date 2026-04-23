import {
  HttpStatus,
  Injectable,
  NestMiddleware
} from "@nestjs/common";
import type { NextFunction, Request, Response } from "express";

import { DomainException } from "../http/domain.exception";
import { RedisService } from "../redis/redis.service";

interface RateLimitPolicy {
  readonly name: string;
  readonly windowSeconds: number;
  readonly maxRequests: number;
}

@Injectable()
export class RateLimitMiddleware implements NestMiddleware {
  constructor(private readonly redisService: RedisService) {}

  async use(request: Request, response: Response, next: NextFunction) {
    const policy = this.resolvePolicy(request.originalUrl);
    if (!policy) {
      return next();
    }

    const callerKey =
      request.header("x-device-fingerprint") ??
      request.header("x-forwarded-for") ??
      request.ip;
    const bucketKey = `rate-limit:${policy.name}:${callerKey}`;
    const counter = await this.redisService.incr(bucketKey, policy.windowSeconds);

    if (counter === null) {
      return next();
    }

    response.setHeader(
      "x-rate-limit-remaining",
      Math.max(policy.maxRequests - counter, 0).toString()
    );

    if (counter > policy.maxRequests) {
      throw new DomainException({
        status: HttpStatus.TOO_MANY_REQUESTS,
        code: "RATE_LIMITED",
        message: "Too many requests. Please retry after the cooling window."
      });
    }

    return next();
  }

  private resolvePolicy(url: string): RateLimitPolicy | null {
    if (url.startsWith("/api/v1/auth")) {
      return {
        name: "auth",
        windowSeconds: 300,
        maxRequests: 5
      };
    }

    if (url.startsWith("/api/v1/payments")) {
      return {
        name: "payments",
        windowSeconds: 60,
        maxRequests: 30
      };
    }

    if (url.startsWith("/api/v1/bank-transfers")) {
      return {
        name: "bank-transfers",
        windowSeconds: 60,
        maxRequests: 12
      };
    }

    if (url.startsWith("/api/v1/merchants")) {
      return {
        name: "merchants",
        windowSeconds: 60,
        maxRequests: 60
      };
    }

    return null;
  }
}
