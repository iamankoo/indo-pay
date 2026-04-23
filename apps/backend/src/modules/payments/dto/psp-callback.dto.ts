import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { Type } from "class-transformer";
import { IsIn, IsInt, IsOptional, IsString, MaxLength, Min } from "class-validator";

export class PspCallbackDto {
  @ApiProperty({ example: "PAYMENT_STATUS_UPDATE" })
  @IsString()
  @MaxLength(64)
  eventType!: string;

  @ApiProperty({ example: "provider_ref_xyz" })
  @IsString()
  providerRef!: string;

  @ApiPropertyOptional({ example: "txn_123" })
  @IsOptional()
  @IsString()
  transactionId?: string;

  @ApiProperty({ example: "SUCCESS" })
  @IsIn(["SUCCESS", "FAILED", "PENDING", "REVERSED"])
  status!: "SUCCESS" | "FAILED" | "PENDING" | "REVERSED";

  @ApiPropertyOptional({ example: 1000 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  amount?: number;
}
