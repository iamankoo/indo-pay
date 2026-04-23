import { Body, Controller, Post } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

import { RefreshSessionDto } from "./dto/refresh-session.dto";
import { RequestOtpDto } from "./dto/request-otp.dto";
import { VerifyOtpDto } from "./dto/verify-otp.dto";
import { AuthService } from "./auth.service";

@ApiTags("auth")
@Controller("auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post("login")
  @ApiOperation({ summary: "Request OTP for a mobile number" })
  requestLoginOtp(@Body() body: RequestOtpDto) {
    return this.authService.requestOtp(body.mobile);
  }

  @Post("otp/request")
  @ApiOperation({ summary: "Alias for OTP request" })
  requestOtp(@Body() body: RequestOtpDto) {
    return this.authService.requestOtp(body.mobile);
  }

  @Post("verify-otp")
  @ApiOperation({ summary: "Verify OTP and bind the device" })
  verifyOtp(
    @Body()
    body: VerifyOtpDto
  ) {
    return this.authService.verifyOtp(body);
  }

  @Post("otp/verify")
  @ApiOperation({ summary: "Alias for OTP verification" })
  verifyOtpAlias(
    @Body()
    body: VerifyOtpDto
  ) {
    return this.authService.verifyOtp(body);
  }

  @Post("refresh")
  @ApiOperation({ summary: "Refresh an app session using the refresh token" })
  refresh(@Body() body: RefreshSessionDto) {
    return this.authService.refreshSession(body.refreshToken);
  }
}
