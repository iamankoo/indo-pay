import { Body, Controller, Get, Headers, Param, Patch, Post, Query, Req } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";
import type { Request } from "express";

import { FinancialRequestContext } from "../../common/reliability/request-context";
import { CreateInvoiceDto } from "./dto/create-invoice.dto";
import { CreatePaymentLinkDto } from "./dto/create-payment-link.dto";
import { IssueMerchantQrDto } from "./dto/issue-merchant-qr.dto";
import { OnboardMerchantDto } from "./dto/onboard-merchant.dto";
import { SoundboxWebhookDto } from "./dto/soundbox-webhook.dto";
import { UpdatePayoutSettingsDto } from "./dto/update-payout-settings.dto";
import { UpdateStoreProfileDto } from "./dto/update-store-profile.dto";
import { MerchantsService } from "./merchants.service";

@ApiTags("merchants")
@Controller("merchants")
export class MerchantsController {
  constructor(private readonly merchantsService: MerchantsService) {}

  @Post("onboard")
  @ApiOperation({ summary: "Create a merchant onboarding record" })
  onboard(@Body() body: OnboardMerchantDto, @Req() request: Request) {
    return this.merchantsService.onboard(body, this.buildRequestContext(request));
  }

  @Post("qr")
  @ApiOperation({ summary: "Issue a merchant QR payload" })
  issueQr(@Body() body: IssueMerchantQrDto, @Req() request: Request) {
    return this.merchantsService.issueQr(body, this.buildRequestContext(request));
  }

  @Get(":merchantId/profile")
  @ApiOperation({ summary: "Fetch merchant store profile and dashboard shell" })
  getStoreProfile(@Param("merchantId") merchantId: string) {
    return this.merchantsService.getStoreProfile(merchantId);
  }

  @Patch(":merchantId/profile")
  @ApiOperation({ summary: "Update store profile and branding" })
  updateStoreProfile(
    @Param("merchantId") merchantId: string,
    @Body() body: UpdateStoreProfileDto
  ) {
    return this.merchantsService.updateStoreProfile(merchantId, body);
  }

  @Get(":merchantId/settlements")
  @ApiOperation({ summary: "Fetch daily settlement timeline and downloadable reports" })
  getSettlements(
    @Param("merchantId") merchantId: string,
    @Query("days") days = "7"
  ) {
    return this.merchantsService.getSettlements(merchantId, Number(days));
  }

  @Post(":merchantId/payout-settings")
  @ApiOperation({ summary: "Store merchant payout bank settings" })
  updatePayoutSettings(
    @Param("merchantId") merchantId: string,
    @Body() body: UpdatePayoutSettingsDto
  ) {
    return this.merchantsService.updatePayoutSettings(merchantId, body);
  }

  @Post(":merchantId/payment-links")
  @ApiOperation({ summary: "Create a shareable merchant payment link" })
  createPaymentLink(
    @Param("merchantId") merchantId: string,
    @Body() body: CreatePaymentLinkDto,
    @Req() request: Request
  ) {
    return this.merchantsService.createPaymentLink(
      merchantId,
      body,
      this.buildRequestContext(request)
    );
  }

  @Post(":merchantId/invoices")
  @ApiOperation({ summary: "Generate an invoice and settlement-ready PDF link" })
  createInvoice(
    @Param("merchantId") merchantId: string,
    @Body() body: CreateInvoiceDto
  ) {
    return this.merchantsService.createInvoice(merchantId, body);
  }

  @Get(":merchantId/analytics")
  @ApiOperation({ summary: "Fetch merchant daily sales analytics" })
  getAnalytics(
    @Param("merchantId") merchantId: string,
    @Query("days") days = "7"
  ) {
    return this.merchantsService.getMerchantAnalytics(merchantId, Number(days));
  }

  @Post("webhooks/soundbox")
  @ApiOperation({ summary: "Handle soundbox-ready merchant event webhooks" })
  handleSoundboxWebhook(
    @Body() body: SoundboxWebhookDto,
    @Req() request: Request & { rawBody?: Buffer },
    @Headers("x-merchant-signature") signature = ""
  ) {
    return this.merchantsService.handleSoundboxWebhook(
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
