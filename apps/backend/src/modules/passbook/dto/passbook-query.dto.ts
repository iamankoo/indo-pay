import { ApiPropertyOptional } from "@nestjs/swagger";
import { Type } from "class-transformer";
import {
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min
} from "class-validator";

export class PassbookQueryDto {
  @ApiPropertyOptional({ example: "all" })
  @IsOptional()
  @IsIn(["all", "bank-transfers", "wallet", "cashback", "bank-balance"])
  tab?: "all" | "bank-transfers" | "wallet" | "cashback" | "bank-balance";

  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number;

  @ApiPropertyOptional({ example: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;

  @ApiPropertyOptional({ example: "usr_demo_001" })
  @IsOptional()
  @IsString()
  userId?: string;

  @ApiPropertyOptional({ example: "QR_PAYMENT" })
  @IsOptional()
  @IsString()
  category?: string;

  @ApiPropertyOptional({ example: 100 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  minAmount?: number;

  @ApiPropertyOptional({ example: 1000 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  maxAmount?: number;
}
