import { Body, Controller, Headers, Post, Req } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";
import type { Request } from "express";

import { FinancialRequestContext } from "../../common/reliability/request-context";
import { CreateBillPaymentDto } from "./dto/create-bill-payment.dto";
import { CreatePaymentDto } from "./dto/create-payment.dto";
import { PspCallbackDto } from "./dto/psp-callback.dto";
import { PaymentsService } from "./payments.service";

@ApiTags("payments")
@Controller("payments")
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post("pay")
  @ApiOperation({ summary: "Process a payment and apply wallet plus cashback rules" })
  processPayment(
    @Body()
    body: CreatePaymentDto,
    @Req() request: Request
  ) {
    return this.paymentsService.processPayment(
      body,
      this.buildRequestContext(request)
    );
  }

  @Post("merchant")
  @ApiOperation({ summary: "Alias for merchant payment flow" })
  processMerchantPayment(
    @Body()
    body: CreatePaymentDto,
    @Req() request: Request
  ) {
    return this.paymentsService.processPayment(
      body,
      this.buildRequestContext(request)
    );
  }

  @Post("bills")
  @ApiOperation({ summary: "Create a bill payment order" })
  createBillPayment(
    @Body()
    body: CreateBillPaymentDto
  ) {
    return this.paymentsService.createBillPayment(body);
  }

  @Post("webhooks/psp")
  @ApiOperation({ summary: "Receive PSP callbacks with HMAC verification and replay protection" })
  handlePspCallback(
    @Body() body: PspCallbackDto,
    @Req() request: Request & { rawBody?: Buffer },
    @Headers("x-psp-signature") signature = ""
  ) {
    return this.paymentsService.handlePspCallback(
      body,
      request.rawBody?.toString("utf8") ?? JSON.stringify(body),
      signature
    );
  }

  private buildRequestContext(request: Request): FinancialRequestContext {
    return {
      idempotencyKey: Reflect.get(request, "idempotencyKey") as string | undefined,
      requestHash: Reflect.get(request, "requestHash") as string | undefined,
      requestId: request.header("x-request-id") ?? undefined,
      ipAddress: request.ip
    };
  }
}
