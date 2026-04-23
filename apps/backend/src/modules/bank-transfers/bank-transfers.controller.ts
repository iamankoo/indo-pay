import { Body, Controller, Get, Post, Query, Req } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";
import type { Request } from "express";

import { FinancialRequestContext } from "../../common/reliability/request-context";
import { BankTransfersService } from "./bank-transfers.service";
import { CreateBeneficiaryDto } from "./dto/create-beneficiary.dto";
import { CreateTransferDto } from "./dto/create-transfer.dto";
import { NameEnquiryDto } from "./dto/name-enquiry.dto";
import { PreviewTransferDto } from "./dto/preview-transfer.dto";
import { ValidateIfscDto } from "./dto/validate-ifsc.dto";

@ApiTags("bank-transfers")
@Controller("bank-transfers")
export class BankTransfersController {
  constructor(private readonly bankTransfersService: BankTransfersService) {}

  @Post("beneficiaries")
  @ApiOperation({ summary: "Add or update a beneficiary with IFSC validation" })
  addBeneficiary(
    @Body() body: CreateBeneficiaryDto,
    @Req() request: Request
  ) {
    return this.bankTransfersService.addBeneficiary(
      body,
      this.buildRequestContext(request)
    );
  }

  @Get("beneficiaries")
  @ApiOperation({ summary: "Fetch recent beneficiaries for the transfer flow" })
  listBeneficiaries(@Query("userId") userId = "usr_demo_001") {
    return this.bankTransfersService.listBeneficiaries(userId);
  }

  @Post("validate-ifsc")
  @ApiOperation({ summary: "Validate IFSC and resolve bank metadata" })
  validateIfsc(@Body() body: ValidateIfscDto) {
    return this.bankTransfersService.validateIfsc(body.ifsc);
  }

  @Post("name-enquiry")
  @ApiOperation({ summary: "Fetch beneficiary name for the entered account and IFSC" })
  nameEnquiry(@Body() body: NameEnquiryDto) {
    return this.bankTransfersService.fetchBeneficiaryName(
      body.accountNumber,
      body.ifsc
    );
  }

  @Post("preview")
  @ApiOperation({ summary: "Preview transfer rail, ETA, and bank debit summary" })
  preview(@Body() body: PreviewTransferDto) {
    return this.bankTransfersService.previewTransfer(body);
  }

  @Post("transfer")
  @ApiOperation({ summary: "Execute IMPS, NEFT, RTGS, or smart quick transfer" })
  createTransfer(
    @Body() body: CreateTransferDto,
    @Req() request: Request
  ) {
    return this.bankTransfersService.createTransfer(
      body,
      this.buildRequestContext(request)
    );
  }

  private buildRequestContext(request: Request): FinancialRequestContext {
    return {
      idempotencyKey: Reflect.get(request, "idempotencyKey") as string | undefined,
      requestHash: Reflect.get(request, "requestHash") as string | undefined,
      requestId: request.header("x-request-id") ?? undefined,
      ipAddress: request.ip
    };
  }
}
