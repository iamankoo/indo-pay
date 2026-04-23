import { Module } from "@nestjs/common";

import { RewardsModule } from "../rewards/rewards.module";
import { GiftCardsController } from "./gift-cards.controller";
import { GiftCardsService } from "./gift-cards.service";

@Module({
  imports: [RewardsModule],
  controllers: [GiftCardsController],
  providers: [GiftCardsService]
})
export class GiftCardsModule {}
