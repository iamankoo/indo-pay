import { Injectable } from "@nestjs/common";

import { PrismaService } from "../prisma/prisma.service";
import {
  createHmacSignature,
  hashString,
  verifyHmacSignature
} from "./request-hash.util";

@Injectable()
export class WebhookSecurityService {
  constructor(private readonly prisma: PrismaService) {}

  verifySignature(payload: string, signature: string, secret: string) {
    return verifyHmacSignature(payload, signature, secret);
  }

  async reserveWebhook(eventType: string, externalRef: string, signature: string) {
    const signatureHash = hashString(signature);
    const existing = await this.prisma.webhookDelivery.findFirst({
      where: {
        eventType,
        externalRef,
        signature: signatureHash
      }
    });

    if (existing) {
      return {
        replay: true,
        record: existing
      };
    }

    const record = await this.prisma.webhookDelivery.create({
      data: {
        eventType,
        externalRef,
        signature: signatureHash
      }
    });

    return {
      replay: false,
      record
    };
  }

  async markProcessed(id: string, responseCode: number) {
    return this.prisma.webhookDelivery.update({
      where: { id },
      data: {
        processedAt: new Date(),
        responseCode
      }
    });
  }

  createResponseSignature(payload: string, secret: string) {
    return createHmacSignature(payload, secret);
  }
}
