import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { Type } from "class-transformer";
import { IsInt, IsOptional, IsString, Min } from "class-validator";

export class WalletPreviewDto {
  @ApiProperty({ example: 300 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  transactionAmount!: number;

  @ApiPropertyOptional({ example: 100 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  walletBalance?: number;

  @ApiPropertyOptional({ example: "usr_demo_001" })
  @IsOptional()
  @IsString()
  userId?: string;
}
