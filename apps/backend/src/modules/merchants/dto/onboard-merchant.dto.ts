import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsMobilePhone, IsOptional, IsString, MaxLength } from "class-validator";

export class OnboardMerchantDto {
  @ApiProperty({ example: "North Star Cafe" })
  @IsString()
  @MaxLength(80)
  businessName!: string;

  @ApiProperty({ example: "9876543210" })
  @IsMobilePhone("en-IN")
  ownerMobile!: string;

  @ApiProperty({ example: "Imphal" })
  @IsString()
  @MaxLength(40)
  city!: string;

  @ApiPropertyOptional({ example: "Cafe" })
  @IsOptional()
  @IsString()
  category?: string;

  @ApiPropertyOptional({ example: "premium-blue" })
  @IsOptional()
  @IsString()
  brandTheme?: string;
}
