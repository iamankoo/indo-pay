import { Body, Controller, Get, Param, Post, Query } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

import { BalanceInquiryService } from "./balance-inquiry.service";
import { ExportStatementDto } from "./dto/export-statement.dto";
import { PassbookQueryDto } from "./dto/passbook-query.dto";
import { PassbookService } from "./passbook.service";
import { StatementExportService } from "./statement-export.service";

@ApiTags("passbook")
@Controller("passbook")
export class PassbookController {
  constructor(
    private readonly passbookService: PassbookService,
    private readonly balanceInquiryService: BalanceInquiryService,
    private readonly statementExportService: StatementExportService
  ) {}

  @Get()
  @ApiOperation({ summary: "Fetch passbook entries by tab" })
  getPassbook(
    @Query() query: PassbookQueryDto
  ) {
    return this.passbookService.getPassbook({
      userId: query.userId ?? "usr_demo_001",
      tab: query.tab ?? "all",
      page: query.page ?? 1,
      limit: query.limit ?? 20,
      category: query.category,
      minAmount: query.minAmount,
      maxAmount: query.maxAmount
    });
  }

  @Get("wallet")
  @ApiOperation({ summary: "Fetch wallet ledger entries" })
  getWalletLedger(
    @Query("userId") userId = "usr_demo_001",
    @Query("page") page = "1",
    @Query("limit") limit = "20"
  ) {
    return this.passbookService.getPassbook({
      userId,
      tab: "wallet",
      page: Number(page),
      limit: Number(limit)
    });
  }

  @Get("cashback")
  @ApiOperation({ summary: "Fetch cashback history entries" })
  getCashbackHistory(
    @Query("userId") userId = "usr_demo_001",
    @Query("page") page = "1",
    @Query("limit") limit = "20"
  ) {
    return this.passbookService.getPassbook({
      userId,
      tab: "cashback",
      page: Number(page),
      limit: Number(limit)
    });
  }

  @Get("balance/:accountId")
  @ApiOperation({ summary: "Check linked bank account balance" })
  getBankBalance(
    @Param("accountId") accountId: string,
    @Query("userId") userId = "usr_demo_001"
  ) {
    return this.balanceInquiryService.fetchBalance(accountId, userId);
  }

  @Get("mini-statement/:accountId")
  @ApiOperation({ summary: "Fetch last 5 bank transfer style entries" })
  getMiniStatement(
    @Param("accountId") accountId: string,
    @Query("userId") userId = "usr_demo_001"
  ) {
    return this.balanceInquiryService.getMiniStatement(accountId, userId);
  }

  @Post("export")
  @ApiOperation({ summary: "Create a statement export record" })
  exportStatement(
    @Body()
    body: ExportStatementDto
  ) {
    return this.statementExportService.createExport({
      userId: body.userId ?? "usr_demo_001",
      fromDate: body.fromDate,
      toDate: body.toDate,
      format: body.format ?? "PDF"
    });
  }
}
