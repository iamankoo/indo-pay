import { HttpException, HttpStatus } from "@nestjs/common";

interface DomainExceptionOptions {
  readonly message: string;
  readonly code: string;
  readonly status?: HttpStatus;
  readonly details?: unknown;
}

export class DomainException extends HttpException {
  readonly code: string;

  readonly details?: unknown;

  constructor(options: DomainExceptionOptions) {
    super(
      {
        code: options.code,
        message: options.message,
        details: options.details
      },
      options.status ?? HttpStatus.BAD_REQUEST
    );

    this.code = options.code;
    this.details = options.details;
  }
}
