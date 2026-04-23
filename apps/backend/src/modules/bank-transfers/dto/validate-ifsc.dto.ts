import { ApiProperty } from "@nestjs/swagger";
import { IsString, Matches } from "class-validator";

export class ValidateIfscDto {
  @ApiProperty({ example: "SBIN0000123" })
  @IsString()
  @Matches(/^[A-Z]{4}0[A-Z0-9]{6}$/)
  ifsc!: string;
}
