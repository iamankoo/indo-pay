import { Body, Controller, Get, Param, Post, Query } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

import { WalletPreviewDto } from "./dto/wallet-preview.dto";
import { WalletService } from "./wallet.service";

@ApiTags("wallet")
@Controller("wallet")
export class WalletController {
  constructor(private readonly walletService: WalletService) {}

  @Get(":userId")
  @ApiOperation({ summary: "Get promo wallet summary for a user" })
  getWalletSummary(@Param("userId") userId: string) {
    return this.walletService.getWalletSummary(userId);
  }

  @Get(":userId/entries")
  @ApiOperation({ summary: "List wallet ledger entries" })
  getWalletEntries(@Param("userId") userId: string, @Query("limit") limit = "20") {
    return this.walletService.listWalletEntries(userId, Number(limit));
  }

  @Post("preview-redemption")
  @ApiOperation({ summary: "Preview the wallet plus bank split" })
  previewRedemption(
    @Body()
    body: WalletPreviewDto
  ) {
    return this.walletService.previewRedemption(body);
  }
}
