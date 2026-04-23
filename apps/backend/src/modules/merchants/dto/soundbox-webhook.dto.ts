import { ApiProperty } from "@nestjs/swagger";
import { IsString, MaxLength } from "class-validator";

export class SoundboxWebhookDto {
  @ApiProperty({ example: "PAYMENT_RECEIVED" })
  @IsString()
  @MaxLength(64)
  eventType!: string;

  @ApiProperty({ example: "mrc_001" })
  @IsString()
  merchantId!: string;

  @ApiProperty({ example: "Merchant payment received" })
  @IsString()
  payload!: string;
}
