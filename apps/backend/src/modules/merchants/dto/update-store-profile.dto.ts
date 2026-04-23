import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsOptional, IsString, MaxLength } from "class-validator";

export class UpdateStoreProfileDto {
  @ApiPropertyOptional({ example: "Daily 8 AM - 10 PM" })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  operatingHours?: string;

  @ApiPropertyOptional({ example: "Near City Centre" })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  address?: string;

  @ApiPropertyOptional({ example: "Fresh coffee and bakery" })
  @IsOptional()
  @IsString()
  @MaxLength(160)
  tagline?: string;

  @ApiPropertyOptional({ example: "#0B4DFF" })
  @IsOptional()
  @IsString()
  primaryColor?: string;
}
