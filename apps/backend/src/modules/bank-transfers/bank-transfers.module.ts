import { Module } from "@nestjs/common";

import { ReliabilityModule } from "../../common/reliability/reliability.module";
import { BankTransfersController } from "./bank-transfers.controller";
import { BankTransfersService } from "./bank-transfers.service";

@Module({
  imports: [ReliabilityModule],
  controllers: [BankTransfersController],
  providers: [BankTransfersService]
})
export class BankTransfersModule {}
