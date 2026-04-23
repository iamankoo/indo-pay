import { Injectable } from "@nestjs/common";

import { RewardsService } from "../rewards/rewards.service";

@Injectable()
export class GiftCardsService {
  constructor(private readonly rewardsService: RewardsService) {}

  getCatalog() {
    return [
      { brandCode: "AMAZON", minAmount: 100, maxAmount: 10000 },
      { brandCode: "FLIPKART", minAmount: 100, maxAmount: 10000 },
      { brandCode: "MYNTRA", minAmount: 250, maxAmount: 5000 }
    ];
  }

  purchase(input: {
    userId: string;
    brandCode: string;
    amount: number;
    walletBalance: number;
  }) {
    const split = this.rewardsService.previewWalletSplit(
      input.amount,
      input.walletBalance
    );

    return {
      orderId: `gc_${Date.now()}`,
      userId: input.userId,
      brandCode: input.brandCode,
      amount: input.amount,
      walletAmount: split.walletUse,
      bankAmount: split.bankAmount,
      status: "ISSUANCE_PENDING"
    };
  }
}

