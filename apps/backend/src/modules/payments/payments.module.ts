import { Module } from "@nestjs/common";

import { ReliabilityModule } from "../../common/reliability/reliability.module";
import { FraudModule } from "../fraud/fraud.module";
import { NotificationsModule } from "../notifications/notifications.module";
import { RewardsModule } from "../rewards/rewards.module";
import { WalletModule } from "../wallet/wallet.module";
import { PaymentsController } from "./payments.controller";
import { PaymentsService } from "./payments.service";

@Module({
  imports: [
    RewardsModule,
    FraudModule,
    WalletModule,
    NotificationsModule,
    ReliabilityModule
  ],
  controllers: [PaymentsController],
  providers: [PaymentsService]
})
export class PaymentsModule {}
