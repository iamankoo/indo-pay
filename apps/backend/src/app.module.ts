import {
  MiddlewareConsumer,
  Module,
  NestModule,
  RequestMethod
} from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";

import { PrismaModule } from "./common/prisma/prisma.module";
import { RedisModule } from "./common/redis/redis.module";
import { IdempotencyMiddleware } from "./common/reliability/idempotency.middleware";
import { RateLimitMiddleware } from "./common/reliability/rate-limit.middleware";
import { ReliabilityModule } from "./common/reliability/reliability.module";
import { AnalyticsModule } from "./modules/analytics/analytics.module";
import { AuthModule } from "./modules/auth/auth.module";
import { BankTransfersModule } from "./modules/bank-transfers/bank-transfers.module";
import { FraudModule } from "./modules/fraud/fraud.module";
import { GiftCardsModule } from "./modules/gift-cards/gift-cards.module";
import { HealthModule } from "./modules/health/health.module";
import { MerchantsModule } from "./modules/merchants/merchants.module";
import { NotificationsModule } from "./modules/notifications/notifications.module";
import { PassbookModule } from "./modules/passbook/passbook.module";
import { PaymentsModule } from "./modules/payments/payments.module";
import { RewardsModule } from "./modules/rewards/rewards.module";
import { WalletModule } from "./modules/wallet/wallet.module";

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true
    }),
    PrismaModule,
    RedisModule,
    ReliabilityModule,
    HealthModule,
    AuthModule,
    PaymentsModule,
    WalletModule,
    RewardsModule,
    FraudModule,
    GiftCardsModule,
    NotificationsModule,
    MerchantsModule,
    AnalyticsModule,
    PassbookModule,
    BankTransfersModule
  ]
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(RateLimitMiddleware)
      .forRoutes({ path: "*", method: RequestMethod.ALL });

    consumer
      .apply(IdempotencyMiddleware)
      .forRoutes(
        { path: "payments/pay", method: RequestMethod.POST },
        { path: "payments/merchant", method: RequestMethod.POST },
        { path: "payments/webhooks/psp", method: RequestMethod.POST },
        { path: "bank-transfers/beneficiaries", method: RequestMethod.POST },
        { path: "bank-transfers/transfer", method: RequestMethod.POST },
        { path: "merchants/onboard", method: RequestMethod.POST },
        { path: "merchants/qr", method: RequestMethod.POST }
      );
  }
}
