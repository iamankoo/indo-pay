import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { Type } from "class-transformer";
import { IsArray, IsInt, IsOptional, IsString, Min } from "class-validator";

export class CreateInvoiceDto {
  @ApiProperty({ example: "North Star Catering" })
  @IsString()
  customerName!: string;

  @ApiProperty({ example: 1800 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  amount!: number;

  @ApiPropertyOptional({ example: ["Cappuccino", "Croissant"] })
  @IsOptional()
  @IsArray()
  items?: string[];
}
