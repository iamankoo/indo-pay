import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { Type } from "class-transformer";
import { IsIn, IsInt, IsOptional, IsString, Min } from "class-validator";

export class IssueMerchantQrDto {
  @ApiProperty({ example: "mrc_001" })
  @IsString()
  merchantId!: string;

  @ApiProperty({ example: "STATIC" })
  @IsIn(["STATIC", "DYNAMIC"])
  mode!: "STATIC" | "DYNAMIC";

  @ApiPropertyOptional({ example: 299 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  amount?: number;

  @ApiPropertyOptional({ example: 300 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(30)
  expirySeconds?: number;

  @ApiPropertyOptional({ example: "Lunch combo" })
  @IsOptional()
  @IsString()
  note?: string;
}
