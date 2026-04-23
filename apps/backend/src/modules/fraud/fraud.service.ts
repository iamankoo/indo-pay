import { Injectable } from "@nestjs/common";

export interface FraudContext {
  sameMerchantCountToday: number;
  deviceSeenOnMultipleAccounts: boolean;
  merchantLoopDetected: boolean;
  sameVpaCycleDetected: boolean;
}

@Injectable()
export class FraudService {
  screenTransaction(context: FraudContext) {
    const flags: string[] = [];

    if (context.sameMerchantCountToday > 3) {
      flags.push("MERCHANT_DAILY_FREQUENCY");
    }

    if (context.deviceSeenOnMultipleAccounts) {
      flags.push("DEVICE_DUPLICATE");
    }

    if (context.merchantLoopDetected) {
      flags.push("MERCHANT_LOOP");
    }

    if (context.sameVpaCycleDetected) {
      flags.push("VPA_CYCLE");
    }

    return {
      allowCashback: flags.length === 0,
      flags
    };
  }
}
