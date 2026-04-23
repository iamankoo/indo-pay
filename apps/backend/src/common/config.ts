export const promoWalletRules = {
  cashbackPercent: 0.11,
  redemptionPercent: 0.016,
  minTransactionAmount: 100,
  expiryDays: 30,
  dailyCashbackCap: 500,
  rewardedTransactionType: "P2M_ONLY"
} as const;

export const productScope = {
  supportedBillers: [
    "MOBILE",
    "DTH",
    "ELECTRICITY",
    "WATER",
    "GAS",
    "FASTAG",
    "OTT"
  ],
  supportedGiftCards: ["AMAZON", "FLIPKART", "MYNTRA"],
  supportedPaymentFlows: ["UPI_COLLECT", "UPI_INTENT", "VPA", "QR_MERCHANT"]
} as const;

