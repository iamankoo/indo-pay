import { ApiProperty } from "@nestjs/swagger";
import { IsString, Length } from "class-validator";

export class RefreshSessionDto {
  @ApiProperty({ example: "refresh_placeholder" })
  @IsString()
  @Length(8, 256)
  refreshToken!: string;
}
