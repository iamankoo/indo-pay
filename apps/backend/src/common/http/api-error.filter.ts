import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger
} from "@nestjs/common";
import type { Request, Response } from "express";

@Catch()
export class ApiErrorFilter implements ExceptionFilter {
  private readonly logger = new Logger(ApiErrorFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const context = host.switchToHttp();
    const request = context.getRequest<Request>();
    const response = context.getResponse<Response>();

    const { status, code, message, details } = this.getPayload(exception);

    if (!(exception instanceof HttpException)) {
      this.logger.error(
        `Unhandled error for ${request.method} ${request.url}`,
        exception instanceof Error ? exception.stack : undefined
      );
    }

    response.status(status).json({
      statusCode: status,
      code,
      message,
      details,
      timestamp: new Date().toISOString(),
      path: request.url,
      requestId: request.header("x-request-id") ?? null
    });
  }

  private getPayload(exception: unknown) {
    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const payload = exception.getResponse();

      if (typeof payload === "string") {
        return {
          status,
          code: this.defaultCodeFor(status),
          message: payload,
          details: null
        };
      }

      const body = payload as {
        readonly code?: string;
        readonly message?: string | string[];
        readonly details?: unknown;
        readonly error?: string;
      };

      return {
        status,
        code: body.code ?? this.defaultCodeFor(status),
        message: Array.isArray(body.message)
          ? body.message.join(", ")
          : body.message ?? body.error ?? "Request failed",
        details: body.details ?? null
      };
    }

    if (exception instanceof Error) {
      return {
        status: HttpStatus.INTERNAL_SERVER_ERROR,
        code: "INTERNAL_SERVER_ERROR",
        message: exception.message,
        details: null
      };
    }

    return {
      status: HttpStatus.INTERNAL_SERVER_ERROR,
      code: "INTERNAL_SERVER_ERROR",
      message: "Unexpected server failure",
      details: null
    };
  }

  private defaultCodeFor(status: number) {
    switch (status) {
      case HttpStatus.BAD_REQUEST:
        return "BAD_REQUEST";
      case HttpStatus.UNAUTHORIZED:
        return "UNAUTHORIZED";
      case HttpStatus.NOT_FOUND:
        return "NOT_FOUND";
      case HttpStatus.CONFLICT:
        return "CONFLICT";
      case HttpStatus.TOO_MANY_REQUESTS:
        return "RATE_LIMITED";
      case HttpStatus.UNPROCESSABLE_ENTITY:
        return "VALIDATION_FAILED";
      default:
        return "REQUEST_FAILED";
    }
  }
}
