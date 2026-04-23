import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsOptional, IsString, Length, Matches } from "class-validator";

export class CreateBeneficiaryDto {
  @ApiPropertyOptional({ example: "usr_demo_001" })
  @IsOptional()
  @IsString()
  userId?: string;

  @ApiProperty({ example: "123456789012" })
  @IsString()
  @Length(9, 18)
  @Matches(/^\d+$/)
  accountNumber!: string;

  @ApiProperty({ example: "123456789012" })
  @IsString()
  @Length(9, 18)
  @Matches(/^\d+$/)
  confirmAccountNumber!: string;

  @ApiProperty({ example: "HDFC0001234" })
  @IsString()
  @Matches(/^[A-Z]{4}0[A-Z0-9]{6}$/)
  ifsc!: string;

  @ApiPropertyOptional({ example: "Ananya Sharma" })
  @IsOptional()
  @IsString()
  beneficiaryName?: string;

  @ApiPropertyOptional({ example: "Rent Owner" })
  @IsOptional()
  @IsString()
  nickname?: string;
}
