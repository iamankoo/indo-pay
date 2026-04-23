import { Module } from "@nestjs/common";

import { ReliabilityModule } from "../../common/reliability/reliability.module";
import { MerchantsController } from "./merchants.controller";
import { MerchantsService } from "./merchants.service";

@Module({
  imports: [ReliabilityModule],
  controllers: [MerchantsController],
  providers: [MerchantsService]
})
export class MerchantsModule {}
