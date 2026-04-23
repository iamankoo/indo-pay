import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { Type } from "class-transformer";
import { IsInt, IsOptional, IsString, Min } from "class-validator";

export class CreatePaymentLinkDto {
  @ApiProperty({ example: 499 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  amount!: number;

  @ApiPropertyOptional({ example: "Order #441" })
  @IsOptional()
  @IsString()
  title?: string;

  @ApiPropertyOptional({ example: 86400 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(300)
  expirySeconds?: number;
}
