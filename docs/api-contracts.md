# REST API Contracts

All APIs are assumed under `/api/v1`.

## Auth

### `POST /auth/otp/request`

Request:

```json
{
  "mobile": "9876543210"
}
```

Response:

```json
{
  "mobile": "9876543210",
  "challengeId": "otp_1712294400000",
  "expiresInSeconds": 120,
  "channel": "SMS"
}
```

### `POST /auth/otp/verify`

Request:

```json
{
  "mobile": "9876543210",
  "otp": "112233",
  "deviceFingerprint": "android-device-hash"
}
```

### `POST /auth/refresh`

Request:

```json
{
  "refreshToken": "refresh_placeholder"
}
```

Response:

```json
{
  "refreshToken": "refresh_placeholder",
  "sessionToken": "jwt_1712294400000",
  "refreshTokenExpiresInSeconds": 604800
}
```

Response:

```json
{
  "userId": "usr_demo_001",
  "mobile": "9876543210",
  "sessionToken": "jwt_placeholder",
  "refreshToken": "refresh_placeholder",
  "mpinRequired": true,
  "deviceBound": true
}
```

## Payments

### `POST /payments/merchant`

Use for merchant QR or VPA merchant payments.

Request:

```json
{
  "userId": "usr_demo_001",
  "merchantId": "mrc_001",
  "amount": 300,
  "category": "MERCHANT_QR",
  "walletBalance": 120,
  "sameMerchantCountToday": 1,
  "deviceSeenOnMultipleAccounts": false,
  "merchantLoopDetected": false,
  "sameVpaCycleDetected": false
}
```

Response:

```json
{
  "transactionId": "txn_1712294400000",
  "status": "SUCCESS",
  "userId": "usr_demo_001",
  "merchantId": "mrc_001",
  "amount": 300,
  "bankAmount": 295,
  "walletAmount": 5,
  "cashback": {
    "eligible": true,
    "reason": "ELIGIBLE",
    "cashbackAmount": 33,
    "expiresAt": "2026-05-05T00:00:00.000Z"
  },
  "fraudFlags": []
}
```

### `POST /payments/bills`

Request:

```json
{
  "userId": "usr_demo_001",
  "billerType": "ELECTRICITY",
  "amount": 850
}
```

Response:

```json
{
  "orderId": "bill_1712294400000",
  "userId": "usr_demo_001",
  "billerType": "ELECTRICITY",
  "amount": 850,
  "status": "PENDING_PROVIDER_CONFIRMATION"
}
```

### `POST /payments/pay`

Primary payment endpoint for the new runnable backend checkpoint.

Request:

```json
{
  "userId": "usr_demo_001",
  "merchantId": "mrc_demo_001",
  "amount": 1000,
  "category": "QR_PAYMENT",
  "rail": "UPI"
}
```

Response:

```json
{
  "transactionId": "txn_xxx",
  "status": "SUCCESS",
  "userId": "usr_demo_001",
  "merchantId": "mrc_demo_001",
  "amount": 1000,
  "bankAmount": 984,
  "walletAmount": 16,
  "cashback": {
    "eligible": true,
    "reason": "ELIGIBLE",
    "cashbackAmount": 110,
    "expiresAt": "2026-05-05T00:00:00.000Z"
  },
  "walletBalanceAfterTxn": 204,
  "fraudFlags": []
}
```

## Wallet

### `GET /wallet/:userId`

Response:

```json
{
  "userId": "usr_demo_001",
  "promoWalletBalance": 284,
  "expiringIn7Days": 110,
  "monthlyRedeemed": 42,
  "monthlyExpired": 76
}
```

### `POST /wallet/preview-redemption`

Request:

```json
{
  "transactionAmount": 300,
  "walletBalance": 100
}
```

Response:

```json
{
  "walletUse": 5,
  "bankAmount": 295
}
```

## Merchants

### `POST /merchants/onboard`

- starts merchant onboarding and KYC
- city-first rollout can begin in Imphal, campuses, and local retail clusters

### `POST /merchants/qr`

- returns static or dynamic QR payloads
- dynamic QRs should carry order amount and expiry metadata

### `GET /merchants/:merchantId/profile`

- returns merchant identity, KYC state, profile metadata, and payout settings

### `GET /merchants/:merchantId/settlements`

- returns a daily settlement timeline with PDF URLs

### `POST /merchants/:merchantId/payout-settings`

- stores payout bank configuration

### `POST /merchants/:merchantId/payment-links`

- creates a shareable collection link for remote merchant payments

### `POST /merchants/:merchantId/invoices`

- generates invoice metadata plus a downloadable PDF URL

### `GET /merchants/:merchantId/analytics`

- returns sales, order count, average order value, and settlement readiness

### `POST /merchants/webhooks/soundbox`

- verifies HMAC signatures for merchant event abstractions such as soundbox devices

## Gift Cards

### `GET /gift-cards/catalog`

- lists supported brands and value ranges
- supports launch partners such as Amazon, Flipkart, and Myntra-style prepaid products

### `POST /gift-cards/purchase`

Request:

```json
{
  "userId": "usr_demo_001",
  "brandCode": "AMAZON",
  "amount": 1000,
  "walletBalance": 284
}
```

Response:

```json
{
  "orderId": "gc_1712294400000",
  "userId": "usr_demo_001",
  "brandCode": "AMAZON",
  "amount": 1000,
  "walletAmount": 16,
  "bankAmount": 984,
  "status": "ISSUANCE_PENDING"
}
```

## Analytics

### `GET /analytics/dashboard`

- GMV
- DAU / WAU
- recharge volume
- merchant volume
- cashback issued, redeemed, and expired
- wallet liability
- reward burn %
- top merchants
- fraud alerts
- transaction success rate
- bank transfer volume
- retention cohorts
- city-wise adoption
- Imphal beta cohort analytics

## Passbook

### `GET /passbook?tab=all&page=1&userId=usr_demo_001`

- fetches the merged passbook timeline
- supports `category`, `minAmount`, and `maxAmount` filters

### `GET /passbook/wallet?userId=usr_demo_001`

- fetches wallet ledger rows only

### `GET /passbook/cashback?userId=usr_demo_001`

- fetches cashback credit, usage, and expiry history

### `GET /passbook/balance/:accountId?userId=usr_demo_001`

- creates a fresh balance snapshot and returns masked account plus balances

### `GET /passbook/mini-statement/:accountId?userId=usr_demo_001`

- returns the latest five bank-transfer style transactions

### `POST /passbook/export`

Request:

```json
{
  "userId": "usr_demo_001",
  "fromDate": "2026-04-01T00:00:00.000Z",
  "toDate": "2026-04-30T23:59:59.000Z"
}
```

Response:

```json
{
  "id": "stmt_xxx",
  "userId": "usr_demo_001",
  "fromDate": "2026-04-01T00:00:00.000Z",
  "toDate": "2026-04-30T23:59:59.000Z",
  "fileUrl": "https://files.indo-pay.local/statements/usr_demo_001-1712294400000.pdf",
  "createdAt": "2026-04-05T10:00:00.000Z"
}
```

- supports `format: PDF | CSV`
- list endpoints now return `hasMore` and `nextPage`

## Bank Transfers

### `POST /bank-transfers/beneficiaries`

- saves a beneficiary after account re-entry and IFSC validation

### `GET /bank-transfers/beneficiaries?userId=usr_demo_001`

- returns recent beneficiaries for quick transfer reuse

### `POST /bank-transfers/validate-ifsc`

- validates IFSC and resolves bank metadata

### `POST /bank-transfers/name-enquiry`

- fetches beneficiary name for account number + IFSC

### `POST /bank-transfers/preview`

- resolves IMPS / NEFT / RTGS / smart quick transfer rail and ETA

### `POST /bank-transfers/transfer`

- executes the transfer with idempotency and duplicate protection

## Reliability Headers

For money-moving `POST` APIs, send:

```http
x-idempotency-key: unique-client-generated-key
```
