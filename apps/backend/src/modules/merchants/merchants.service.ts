import { HttpStatus, Injectable, NotFoundException } from "@nestjs/common";

import { DomainException } from "../../common/http/domain.exception";
import { PrismaService } from "../../common/prisma/prisma.service";
import { RedisService } from "../../common/redis/redis.service";
import { IdempotencyService } from "../../common/reliability/idempotency.service";
import { FinancialRequestContext } from "../../common/reliability/request-context";
import { createTransactionReferenceHash } from "../../common/reliability/request-hash.util";
import { WebhookSecurityService } from "../../common/reliability/webhook-security.service";
import { CreateInvoiceDto } from "./dto/create-invoice.dto";
import { CreatePaymentLinkDto } from "./dto/create-payment-link.dto";
import { IssueMerchantQrDto } from "./dto/issue-merchant-qr.dto";
import { OnboardMerchantDto } from "./dto/onboard-merchant.dto";
import { SoundboxWebhookDto } from "./dto/soundbox-webhook.dto";
import { UpdatePayoutSettingsDto } from "./dto/update-payout-settings.dto";
import { UpdateStoreProfileDto } from "./dto/update-store-profile.dto";

@Injectable()
export class MerchantsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redisService: RedisService,
    private readonly idempotencyService: IdempotencyService,
    private readonly webhookSecurityService: WebhookSecurityService
  ) {}

  async onboard(
    input: OnboardMerchantDto,
    context: FinancialRequestContext = {}
  ) {
    const referenceHash = createTransactionReferenceHash([
      input.businessName,
      input.ownerMobile,
      input.city
    ]);

    return this.idempotencyService.execute(
      "merchant-onboard",
      context.idempotencyKey ?? referenceHash,
      context.requestHash ?? referenceHash,
      async () => {
        const merchant = await this.prisma.merchant.create({
          data: {
            businessName: input.businessName,
            ownerMobile: input.ownerMobile,
            city: input.city,
            kycStatus: "PENDING"
          }
        });

        await this.redisService.setJson(
          this.profileKey(merchant.id),
          {
            category: input.category ?? "General Merchant",
            brandTheme: input.brandTheme ?? "fintech-premium",
            onboardingStage: "KYC_PENDING"
          },
          30 * 24 * 60 * 60
        );

        return {
          merchantId: merchant.id,
          businessName: merchant.businessName,
          ownerMobile: merchant.ownerMobile,
          city: merchant.city,
          kycStatus: merchant.kycStatus,
          onboardingChecklist: [
            "GST and PAN verification",
            "Storefront proof upload",
            "Settlement bank verification"
          ]
        };
      }
    );
  }

  async getStoreProfile(merchantId: string) {
    const merchant = await this.prisma.merchant.findUnique({
      where: { id: merchantId }
    });

    if (!merchant) {
      throw new NotFoundException(`Merchant ${merchantId} not found`);
    }

    const [profile, payoutSettings] = await Promise.all([
      this.redisService.getJson<Record<string, unknown>>(this.profileKey(merchantId)),
      this.redisService.getJson<Record<string, unknown>>(this.payoutKey(merchantId))
    ]);

    return {
      merchantId: merchant.id,
      businessName: merchant.businessName,
      ownerMobile: merchant.ownerMobile,
      city: merchant.city,
      settlementVpa: merchant.settlementVpa,
      kycStatus: merchant.kycStatus,
      profile: profile ?? {},
      payoutSettings: payoutSettings ?? null
    };
  }

  async updateStoreProfile(merchantId: string, input: UpdateStoreProfileDto) {
    await this.ensureMerchant(merchantId);

    const current = (await this.redisService.getJson<Record<string, unknown>>(
      this.profileKey(merchantId)
    )) ?? {};
    const nextProfile = {
      ...current,
      ...input
    };

    await this.redisService.setJson(
      this.profileKey(merchantId),
      nextProfile,
      30 * 24 * 60 * 60
    );

    return {
      merchantId,
      profile: nextProfile
    };
  }

  async issueQr(
    input: IssueMerchantQrDto,
    context: FinancialRequestContext = {}
  ) {
    const merchant = await this.ensureMerchant(input.merchantId);
    const referenceHash = createTransactionReferenceHash([
      input.merchantId,
      input.mode,
      input.amount ?? "",
      input.note ?? ""
    ]);

    return this.idempotencyService.execute(
      "merchant-qr",
      context.idempotencyKey ?? referenceHash,
      context.requestHash ?? referenceHash,
      async () => ({
        merchantId: input.merchantId,
        merchantName: merchant.businessName,
        mode: input.mode,
        amount: input.amount ?? null,
        qrPayload: `upi://pay?pa=${input.merchantId}@indopay&pn=${encodeURIComponent(
          merchant.businessName
        )}${input.amount ? `&am=${input.amount}` : ""}`,
        branding: {
          primary: "#0B4DFF",
          accent: "#FF9B2F",
          logoText: merchant.businessName.slice(0, 2).toUpperCase()
        },
        note: input.note ?? null,
        expiresAt:
          input.mode === "DYNAMIC"
            ? new Date(Date.now() + (input.expirySeconds ?? 300) * 1000)
            : null
      })
    );
  }

  async getSettlements(merchantId: string, days: number) {
    await this.ensureMerchant(merchantId);

    const since = new Date(Date.now() - Math.max(days, 1) * 24 * 60 * 60 * 1000);
    const transactions = await this.prisma.transaction.findMany({
      where: {
        merchantId,
        status: "SUCCESS",
        createdAt: {
          gte: since
        }
      },
      orderBy: {
        createdAt: "desc"
      }
    });

    const grouped = new Map<
      string,
      { gross: number; orders: number; settlementDate: string }
    >();

    for (const transaction of transactions) {
      const day = transaction.createdAt.toISOString().slice(0, 10);
      const settlementDate = new Date(transaction.createdAt.getTime() + 24 * 60 * 60 * 1000)
        .toISOString()
        .slice(0, 10);
      const current = grouped.get(day) ?? {
        gross: 0,
        orders: 0,
        settlementDate
      };

      current.gross += transaction.amount;
      current.orders += 1;
      grouped.set(day, current);
    }

    return {
      merchantId,
      items: Array.from(grouped.entries()).map(([day, summary]) => ({
        businessDay: day,
        grossSales: summary.gross,
        netSettlement: Math.round(summary.gross * 0.992),
        orders: summary.orders,
        settlementDate: summary.settlementDate,
        status:
          new Date(summary.settlementDate) <= new Date() ? "SETTLED" : "SCHEDULED",
        settlementPdfUrl: `https://files.indo-pay.local/settlements/${merchantId}-${day}.pdf`
      }))
    };
  }

  async updatePayoutSettings(merchantId: string, input: UpdatePayoutSettingsDto) {
    await this.ensureMerchant(merchantId);

    const payoutSettings = {
      accountName: input.accountName ?? "Primary Payout Account",
      accountNumberMasked: `${"*".repeat(Math.max(input.accountNumber.length - 4, 0))}${input.accountNumber.slice(-4)}`,
      ifsc: input.ifsc
    };

    await this.redisService.setJson(
      this.payoutKey(merchantId),
      payoutSettings,
      30 * 24 * 60 * 60
    );

    return {
      merchantId,
      payoutSettings
    };
  }

  async createPaymentLink(
    merchantId: string,
    input: CreatePaymentLinkDto,
    context: FinancialRequestContext = {}
  ) {
    await this.ensureMerchant(merchantId);
    const linkId = `plink_${Date.now()}`;
    const referenceHash = createTransactionReferenceHash([
      merchantId,
      input.amount,
      input.title ?? "",
      input.expirySeconds ?? 0
    ]);

    return this.idempotencyService.execute(
      "merchant-link",
      context.idempotencyKey ?? referenceHash,
      context.requestHash ?? referenceHash,
      async () => {
        const payload = {
          linkId,
          merchantId,
          amount: input.amount,
          title: input.title ?? "Merchant payment link",
          expiresAt: new Date(Date.now() + (input.expirySeconds ?? 86400) * 1000).toISOString(),
          shareUrl: `https://pay.indo-pay.app/m/${merchantId}/pay/${linkId}`
        };

        await this.redisService.setJson(
          this.paymentLinkKey(merchantId, linkId),
          payload,
          input.expirySeconds ?? 86400
        );

        return payload;
      }
    );
  }

  async createInvoice(merchantId: string, input: CreateInvoiceDto) {
    await this.ensureMerchant(merchantId);
    const invoiceNumber = `INV-${merchantId.slice(0, 4).toUpperCase()}-${Date.now()}`;

    return {
      merchantId,
      invoiceNumber,
      customerName: input.customerName,
      amount: input.amount,
      items: input.items ?? [],
      pdfUrl: `https://files.indo-pay.local/invoices/${invoiceNumber}.pdf`,
      createdAt: new Date().toISOString()
    };
  }

  async getMerchantAnalytics(merchantId: string, days: number) {
    await this.ensureMerchant(merchantId);
    const since = new Date(Date.now() - Math.max(days, 1) * 24 * 60 * 60 * 1000);
    const transactions = await this.prisma.transaction.findMany({
      where: {
        merchantId,
        status: "SUCCESS",
        createdAt: {
          gte: since
        }
      },
      orderBy: {
        createdAt: "asc"
      }
    });

    const totalSales = transactions.reduce((sum, transaction) => sum + transaction.amount, 0);

    const dailySeries = transactions.reduce<
      Array<{ day: string; sales: number; orders: number }>
    >((accumulator, transaction) => {
      const day = transaction.createdAt.toISOString().slice(0, 10);
      const existing = accumulator.find((entry) => entry.day === day);
      if (existing) {
        existing.sales += transaction.amount;
        existing.orders += 1;
        return accumulator;
      }

      accumulator.push({
        day,
        sales: transaction.amount,
        orders: 1
      });

      return accumulator;
    }, []);

    return {
      merchantId,
      totalSales,
      totalOrders: transactions.length,
      averageOrderValue:
        transactions.length === 0 ? 0 : Math.round(totalSales / transactions.length),
      settlementReadiness: totalSales === 0 ? "LOW" : "READY",
      dailySeries
    };
  }

  async handleSoundboxWebhook(
    body: SoundboxWebhookDto,
    rawBody: string,
    signature: string
  ) {
    const secret = process.env.MERCHANT_WEBHOOK_SECRET ?? "indo-pay-soundbox-secret";

    if (!this.webhookSecurityService.verifySignature(rawBody, signature, secret)) {
      throw new DomainException({
        status: HttpStatus.UNAUTHORIZED,
        code: "INVALID_MERCHANT_SIGNATURE",
        message: "Merchant webhook signature verification failed"
      });
    }

    const reservation = await this.webhookSecurityService.reserveWebhook(
      body.eventType,
      `${body.merchantId}:${body.payload}`,
      signature
    );

    if (reservation.replay) {
      return {
        accepted: true,
        replay: true
      };
    }

    await this.webhookSecurityService.markProcessed(reservation.record.id, 200);

    return {
      accepted: true,
      replay: false,
      merchantId: body.merchantId,
      eventType: body.eventType
    };
  }

  private async ensureMerchant(merchantId: string) {
    const merchant = await this.prisma.merchant.findUnique({
      where: { id: merchantId }
    });

    if (!merchant) {
      throw new NotFoundException(`Merchant ${merchantId} not found`);
    }

    return merchant;
  }

  private profileKey(merchantId: string) {
    return `merchant-profile:${merchantId}`;
  }

  private payoutKey(merchantId: string) {
    return `merchant-payout:${merchantId}`;
  }

  private paymentLinkKey(merchantId: string, linkId: string) {
    return `merchant-link:${merchantId}:${linkId}`;
  }
}
