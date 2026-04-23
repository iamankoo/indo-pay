import { ApiProperty } from "@nestjs/swagger";
import { IsMobilePhone, IsString, Length, Matches } from "class-validator";

export class VerifyOtpDto {
  @ApiProperty({ example: "9876543210" })
  @IsMobilePhone("en-IN")
  mobile!: string;

  @ApiProperty({ example: "112233" })
  @IsString()
  @Length(6, 6)
  @Matches(/^\d{6}$/)
  otp!: string;

  @ApiProperty({ example: "android-device-hash" })
  @IsString()
  @Length(8, 128)
  deviceFingerprint!: string;
}
