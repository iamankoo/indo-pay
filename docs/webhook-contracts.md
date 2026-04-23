# Webhook Contracts

## PSP Callback: Payment Status

Endpoint:

`POST /api/v1/webhooks/psp/payment-status`

Headers:

- `x-indo-signature`: HMAC SHA-256 signature
- `x-psp-event-id`: provider event id
- `x-psp-timestamp`: UNIX epoch seconds

Payload:

```json
{
  "providerRef": "psp_txn_001",
  "transactionId": "txn_001",
  "status": "SUCCESS",
  "amount": 300,
  "vpa": "merchant@bank",
  "utr": "123456789012",
  "eventTime": "2026-04-05T10:20:00.000Z"
}
```

Processing rules:

1. Verify signature before parsing business fields.
2. Enforce idempotency on `providerRef` plus `status`.
3. Retry downstream ledger and notification writes on transient failure.
4. Persist every receipt in `WebhookDelivery`.

## Recharge or Biller Callback

Endpoint:

`POST /api/v1/webhooks/billers/order-status`

Payload:

```json
{
  "orderId": "bill_001",
  "providerOrderId": "vendor_001",
  "status": "SUCCESS",
  "operatorCode": "AIRTEL_PREPAID",
  "amount": 299,
  "eventTime": "2026-04-05T10:30:00.000Z"
}
```

## Merchant Settlement Callback

Endpoint:

`POST /api/v1/webhooks/settlements/merchant`

Payload:

```json
{
  "merchantId": "mrc_001",
  "settlementBatchId": "stl_001",
  "grossAmount": 25000,
  "netAmount": 24850,
  "status": "SETTLED",
  "eventTime": "2026-04-05T18:00:00.000Z"
}
```

