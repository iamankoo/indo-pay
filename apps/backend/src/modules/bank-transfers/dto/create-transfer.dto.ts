import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { Type } from "class-transformer";
import {
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Length,
  Matches,
  Min
} from "class-validator";

export class CreateTransferDto {
  @ApiPropertyOptional({ example: "usr_demo_001" })
  @IsOptional()
  @IsString()
  userId?: string;

  @ApiProperty({ example: "123456789012" })
  @IsString()
  @Length(9, 18)
  @Matches(/^\d+$/)
  accountNumber!: string;

  @ApiProperty({ example: "HDFC0001234" })
  @IsString()
  @Matches(/^[A-Z]{4}0[A-Z0-9]{6}$/)
  ifsc!: string;

  @ApiProperty({ example: "Ananya Sharma" })
  @IsString()
  beneficiaryName!: string;

  @ApiPropertyOptional({ example: "Rent Owner" })
  @IsOptional()
  @IsString()
  nickname?: string;

  @ApiProperty({ example: 25000 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  amount!: number;

  @ApiPropertyOptional({ example: "SMART_QUICK" })
  @IsOptional()
  @IsIn(["SMART_QUICK", "IMPS", "NEFT", "RTGS"])
  rail?: "SMART_QUICK" | "IMPS" | "NEFT" | "RTGS";

  @ApiPropertyOptional({ example: "April rent" })
  @IsOptional()
  @IsString()
  note?: string;
}
