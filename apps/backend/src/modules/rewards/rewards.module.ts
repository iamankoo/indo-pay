import { Module } from "@nestjs/common";

import { NotificationsModule } from "../notifications/notifications.module";
import { RewardsExpiryJob } from "./rewards.expiry.job";
import { RewardsService } from "./rewards.service";

@Module({
  imports: [NotificationsModule],
  providers: [RewardsService, RewardsExpiryJob],
  exports: [RewardsService]
})
export class RewardsModule {}

