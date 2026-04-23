import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsDateString, IsIn, IsOptional, IsString } from "class-validator";

export class ExportStatementDto {
  @ApiPropertyOptional({ example: "usr_demo_001" })
  @IsOptional()
  @IsString()
  userId?: string;

  @ApiProperty({ example: "2026-04-01T00:00:00.000Z" })
  @IsDateString()
  fromDate!: string;

  @ApiProperty({ example: "2026-04-30T23:59:59.000Z" })
  @IsDateString()
  toDate!: string;

  @ApiPropertyOptional({ example: "PDF" })
  @IsOptional()
  @IsIn(["PDF", "CSV"])
  format?: "PDF" | "CSV";
}
