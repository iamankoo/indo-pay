import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsOptional, IsString, Matches } from "class-validator";

export class UpdatePayoutSettingsDto {
  @ApiProperty({ example: "123456789012" })
  @IsString()
  @Matches(/^\d{9,18}$/)
  accountNumber!: string;

  @ApiProperty({ example: "HDFC0001234" })
  @IsString()
  @Matches(/^[A-Z]{4}0[A-Z0-9]{6}$/)
  ifsc!: string;

  @ApiPropertyOptional({ example: "North Star Settlements" })
  @IsOptional()
  @IsString()
  accountName?: string;
}
