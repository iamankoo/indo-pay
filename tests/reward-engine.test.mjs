import assert from "node:assert/strict";

import {
  DEFAULT_RULES,
  calculateCashback,
  calculateWalletRedemption,
  createRewardEntry,
  detectFraudFlags,
  isTransactionEligible
} from "../packages/shared/src/reward-engine.js";

assert.equal(calculateCashback(300), 33);
assert.equal(calculateCashback(149), 16);

const split = calculateWalletRedemption({
  transactionAmount: 300,
  walletBalance: 100
});

assert.deepEqual(split, {
  walletUse: 5,
  bankPay: 295
});

const reward = createRewardEntry(
  {
    amount: 1000,
    category: "MERCHANT_QR",
    isSelfTransfer: false,
    isMerchantPayment: true
  },
  "2026-04-05T00:00:00.000Z"
);

assert.equal(reward.credited, true);
assert.equal(reward.amount, 110);
assert.equal(reward.expiresAt, "2026-05-05T00:00:00.000Z");

const lowAmount = isTransactionEligible({
  amount: 99,
  category: "MERCHANT_QR",
  isSelfTransfer: false,
  isMerchantPayment: true
});

const selfTransfer = isTransactionEligible({
  amount: 1000,
  category: "MERCHANT_QR",
  isSelfTransfer: true,
  isMerchantPayment: true
});

assert.deepEqual(lowAmount, {
  eligible: false,
  reason: "MIN_TRANSACTION_NOT_MET"
});

assert.deepEqual(selfTransfer, {
  eligible: false,
  reason: "SELF_TRANSFER_BLOCKED"
});

const flags = detectFraudFlags({
  sameMerchantCountToday: DEFAULT_RULES.maxRewardedMerchantTransactionsPerDay + 1,
  deviceSeenOnMultipleAccounts: true,
  sameVpaCycleDetected: false,
  samePanClusterDetected: true,
  possibleMerchantCollusion: true
});

assert.deepEqual(flags, [
  "MERCHANT_FREQUENCY_LIMIT",
  "DEVICE_DUPLICATION",
  "PAN_CLUSTER",
  "MERCHANT_COLLUSION"
]);

console.log("Reward engine checks passed.");
