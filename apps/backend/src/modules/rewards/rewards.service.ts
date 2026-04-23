import { Injectable } from "@nestjs/common";

import { promoWalletRules } from "../../common/config";

export interface RewardableTransaction {
  amount: number;
  category: string;
  isSelfTransfer: boolean;
}

export interface RewardEvaluation {
  eligible: boolean;
  reason: string;
  cashbackAmount: number;
  expiresAt: string | null;
}

@Injectable()
export class RewardsService {
  evaluateTransaction(
    transaction: RewardableTransaction,
    userDailyCashbackTotal: number
  ): RewardEvaluation {
    if (transaction.amount < promoWalletRules.minTransactionAmount) {
      return {
        eligible: false,
        reason: "MIN_TRANSACTION_NOT_MET",
        cashbackAmount: 0,
        expiresAt: null
      };
    }

    if (transaction.isSelfTransfer) {
      return {
        eligible: false,
        reason: "SELF_TRANSFER_BLOCKED",
        cashbackAmount: 0,
        expiresAt: null
      };
    }

    if (
      ["SELF_TRANSFER", "WALLET_WITHDRAWAL", "P2P_TRANSFER"].includes(
        transaction.category.toUpperCase()
      )
    ) {
      return {
        eligible: false,
        reason: "CATEGORY_EXCLUDED",
        cashbackAmount: 0,
        expiresAt: null
      };
    }

    const cashbackAmount = Math.round(
      transaction.amount * promoWalletRules.cashbackPercent
    );
    const remainingDailyCap = Math.max(
      promoWalletRules.dailyCashbackCap - userDailyCashbackTotal,
      0
    );

    return {
      eligible: remainingDailyCap > 0,
      reason: remainingDailyCap > 0 ? "ELIGIBLE" : "DAILY_CAP_REACHED",
      cashbackAmount: Math.min(cashbackAmount, remainingDailyCap),
      expiresAt: new Date(
        Date.now() + promoWalletRules.expiryDays * 24 * 60 * 60 * 1000
      ).toISOString()
    };
  }

  previewWalletSplit(transactionAmount: number, walletBalance: number) {
    const walletUse = Math.min(
      walletBalance,
      Math.round(transactionAmount * promoWalletRules.redemptionPercent)
    );

    return {
      walletUse,
      bankAmount: transactionAmount - walletUse
    };
  }

  getExpiryDate(from = new Date()) {
    return new Date(
      from.getTime() + promoWalletRules.expiryDays * 24 * 60 * 60 * 1000
    );
  }
}
