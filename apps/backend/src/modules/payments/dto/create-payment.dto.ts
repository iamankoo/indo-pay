import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { Type } from "class-transformer";
import {
  IsBoolean,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min
} from "class-validator";

export class CreatePaymentDto {
  @ApiPropertyOptional({ example: "usr_demo_001" })
  @IsOptional()
  @IsString()
  userId?: string;

  @ApiPropertyOptional({ example: "mrc_demo_001" })
  @IsOptional()
  @IsString()
  merchantId?: string;

  @ApiProperty({ example: 1000 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  amount!: number;

  @ApiProperty({ example: "QR_PAYMENT" })
  @IsString()
  @MaxLength(48)
  category!: string;

  @ApiPropertyOptional({ example: "UPI" })
  @IsOptional()
  @IsString()
  rail?: string;

  @ApiPropertyOptional({ example: "Cafe payment" })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  referenceLabel?: string;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean()
  deviceSeenOnMultipleAccounts?: boolean;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean()
  merchantLoopDetected?: boolean;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean()
  sameVpaCycleDetected?: boolean;
}
