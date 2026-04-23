import { Module } from "@nestjs/common";

import { WalletModule } from "../wallet/wallet.module";
import { BalanceInquiryService } from "./balance-inquiry.service";
import { PassbookController } from "./passbook.controller";
import { PassbookService } from "./passbook.service";
import { StatementExportService } from "./statement-export.service";

@Module({
  imports: [WalletModule],
  controllers: [PassbookController],
  providers: [PassbookService, BalanceInquiryService, StatementExportService]
})
export class PassbookModule {}

