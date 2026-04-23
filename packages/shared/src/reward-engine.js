export const DEFAULT_RULES = Object.freeze({
  cashbackPercent: 0.11,
  redemptionPercent: 0.016,
  minTransactionAmount: 100,
  expiryDays: 30,
  dailyCashbackCap: 500,
  maxRewardedMerchantTransactionsPerDay: 3,
  excludedCategories: ["P2P_SELF_TRANSFER", "WALLET_WITHDRAWAL"]
});

export function roundToNearestRupee(value) {
  return Math.round(value);
}

export function addDays(dateLike, days) {
  const date = new Date(dateLike);
  date.setUTCDate(date.getUTCDate() + days);
  return date;
}

export function isTransactionEligible(transaction, rules = DEFAULT_RULES) {
  if (transaction.amount < rules.minTransactionAmount) {
    return { eligible: false, reason: "MIN_TRANSACTION_NOT_MET" };
  }

  if (rules.excludedCategories.includes(transaction.category)) {
    return { eligible: false, reason: "CATEGORY_EXCLUDED" };
  }

  if (transaction.isSelfTransfer) {
    return { eligible: false, reason: "SELF_TRANSFER_BLOCKED" };
  }

  if (!transaction.isMerchantPayment) {
    return { eligible: false, reason: "ONLY_P2M_REWARDED" };
  }

  return { eligible: true, reason: "ELIGIBLE" };
}

export function calculateCashback(amount, rules = DEFAULT_RULES) {
  return roundToNearestRupee(amount * rules.cashbackPercent);
}

export function calculateWalletRedemption({
  transactionAmount,
  walletBalance,
  rules = DEFAULT_RULES
}) {
  const walletLimit = roundToNearestRupee(
    transactionAmount * rules.redemptionPercent
  );
  const walletUse = Math.min(walletBalance, walletLimit);

  return {
    walletUse,
    bankPay: transactionAmount - walletUse
  };
}

export function createRewardEntry(transaction, now = new Date(), rules = DEFAULT_RULES) {
  const eligibility = isTransactionEligible(transaction, rules);

  if (!eligibility.eligible) {
    return {
      credited: false,
      reason: eligibility.reason,
      amount: 0,
      expiresAt: null
    };
  }

  return {
    credited: true,
    reason: "CASHBACK_CREDITED",
    amount: calculateCashback(transaction.amount, rules),
    expiresAt: addDays(now, rules.expiryDays).toISOString()
  };
}

export function detectFraudFlags(context, rules = DEFAULT_RULES) {
  const flags = [];

  if (context.sameMerchantCountToday > rules.maxRewardedMerchantTransactionsPerDay) {
    flags.push("MERCHANT_FREQUENCY_LIMIT");
  }

  if (context.deviceSeenOnMultipleAccounts) {
    flags.push("DEVICE_DUPLICATION");
  }

  if (context.sameVpaCycleDetected) {
    flags.push("VPA_LOOP");
  }

  if (context.samePanClusterDetected) {
    flags.push("PAN_CLUSTER");
  }

  if (context.possibleMerchantCollusion) {
    flags.push("MERCHANT_COLLUSION");
  }

  return flags;
}

