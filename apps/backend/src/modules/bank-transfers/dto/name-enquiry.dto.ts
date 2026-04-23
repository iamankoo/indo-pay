import { ApiProperty } from "@nestjs/swagger";
import { IsString, Length, Matches } from "class-validator";

export class NameEnquiryDto {
  @ApiProperty({ example: "123456789012" })
  @IsString()
  @Length(9, 18)
  @Matches(/^\d+$/)
  accountNumber!: string;

  @ApiProperty({ example: "ICIC0004321" })
  @IsString()
  @Matches(/^[A-Z]{4}0[A-Z0-9]{6}$/)
  ifsc!: string;
}
