import {
  HttpStatus,
  Injectable,
  NestMiddleware,
  UnprocessableEntityException
} from "@nestjs/common";
import type { NextFunction, Request, Response } from "express";

import { DomainException } from "../http/domain.exception";
import { hashPayload } from "./request-hash.util";

const enforcedPaths = [
  "/api/v1/payments/pay",
  "/api/v1/payments/merchant",
  "/api/v1/payments/webhooks/psp",
  "/api/v1/bank-transfers/beneficiaries",
  "/api/v1/bank-transfers/transfer",
  "/api/v1/merchants/onboard",
  "/api/v1/merchants/qr"
];

@Injectable()
export class IdempotencyMiddleware implements NestMiddleware {
  use(request: Request, _response: Response, next: NextFunction) {
    const isMutatingRequest = ["POST", "PUT", "PATCH"].includes(request.method);
    const requiresIdempotency =
      isMutatingRequest &&
      enforcedPaths.some((path) => request.originalUrl.startsWith(path));

    if (!requiresIdempotency) {
      return next();
    }

    const idempotencyKey = request.header("x-idempotency-key");

    if (!idempotencyKey) {
      throw new DomainException({
        status: HttpStatus.BAD_REQUEST,
        code: "IDEMPOTENCY_KEY_REQUIRED",
        message: "x-idempotency-key is required for financial write operations"
      });
    }

    if (idempotencyKey.length > 128) {
      throw new UnprocessableEntityException({
        code: "VALIDATION_FAILED",
        message: "Idempotency key is too long",
        details: {
          field: "x-idempotency-key",
          maxLength: 128
        }
      });
    }

    const requestHash = hashPayload(request.body as Record<string, unknown>);
    Reflect.set(request, "idempotencyKey", idempotencyKey);
    Reflect.set(request, "requestHash", requestHash);

    return next();
  }
}
