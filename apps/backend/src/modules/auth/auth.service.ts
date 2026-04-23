import { Injectable } from "@nestjs/common";

import { PrismaService } from "../../common/prisma/prisma.service";

@Injectable()
export class AuthService {
  constructor(private readonly prisma: PrismaService) {}

  requestOtp(mobile: string) {
    return {
      mobile,
      challengeId: `otp_${Date.now()}`,
      expiresInSeconds: 120,
      channel: "SMS"
    };
  }

  async verifyOtp(input: {
    mobile: string;
    otp: string;
    deviceFingerprint: string;
  }) {
    const user = await this.prisma.user.upsert({
      where: { mobile: input.mobile },
      update: {},
      create: {
        mobile: input.mobile,
        kycStatus: "PENDING"
      }
    });

    await this.prisma.deviceBinding.create({
      data: {
        userId: user.id,
        deviceFingerprint: input.deviceFingerprint,
        isPrimary: true
      }
    });

    return {
      userId: user.id,
      mobile: input.mobile,
      sessionToken: "jwt_placeholder",
      refreshToken: "refresh_placeholder",
      mpinRequired: true,
      deviceBound: Boolean(input.deviceFingerprint)
    };
  }

  refreshSession(refreshToken: string) {
    return {
      refreshToken,
      sessionToken: `jwt_${Date.now()}`,
      refreshTokenExpiresInSeconds: 7 * 24 * 60 * 60
    };
  }
}
