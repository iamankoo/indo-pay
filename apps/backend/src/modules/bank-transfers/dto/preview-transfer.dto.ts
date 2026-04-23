import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { Type } from "class-transformer";
import { IsIn, IsInt, IsOptional, IsString, Min } from "class-validator";

export class PreviewTransferDto {
  @ApiProperty({ example: 12500 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  amount!: number;

  @ApiPropertyOptional({ example: "SMART_QUICK" })
  @IsOptional()
  @IsIn(["SMART_QUICK", "IMPS", "NEFT", "RTGS"])
  rail?: "SMART_QUICK" | "IMPS" | "NEFT" | "RTGS";

  @ApiPropertyOptional({ example: "Salary advance" })
  @IsOptional()
  @IsString()
  note?: string;
}
