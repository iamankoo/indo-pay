import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { Type } from "class-transformer";
import { IsInt, IsOptional, IsString, MaxLength, Min } from "class-validator";

export class CreateBillPaymentDto {
  @ApiPropertyOptional({ example: "usr_demo_001" })
  @IsOptional()
  @IsString()
  userId?: string;

  @ApiProperty({ example: "ELECTRICITY" })
  @IsString()
  @MaxLength(48)
  billerType!: string;

  @ApiProperty({ example: 850 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  amount!: number;
}
