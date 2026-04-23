# Backend Runnable Checkpoint

## What Is Ready

- NestJS backend compiles successfully
- Swagger is wired in `apps/backend/src/main.ts`
- environment file and Docker Compose are present
- Prisma schema, seed script, and `prisma/migrations/0001_init/migration.sql` are included
- passbook, bank balance, and statement export modules are added

## Local Commands

Run from `apps/backend`:

```powershell
npm install
npx prisma generate
npm run build
```

If PostgreSQL and Redis are available:

```powershell
docker compose up -d
npx prisma migrate dev --name init
npm run prisma:seed
npm run start:dev
```

## Expected URLs

- API: `http://localhost:4000/api/v1`
- Swagger: `http://localhost:4000/api`
- Health: `http://localhost:4000/api/v1/health`

## First Verification Flow

### OTP

`POST /api/v1/auth/login`

```json
{
  "mobile": "9876543210"
}
```

`POST /api/v1/auth/verify-otp`

```json
{
  "mobile": "9876543210",
  "otp": "112233",
  "deviceFingerprint": "android-demo-device"
}
```

### Merchant Payment

`POST /api/v1/payments/pay`

```json
{
  "userId": "usr_demo_001",
  "merchantId": "mrc_demo_001",
  "amount": 1000,
  "category": "QR_PAYMENT",
  "rail": "UPI"
}
```

Expected:

- `walletAmount = 16`
- `bankAmount = 984`
- `cashback.cashbackAmount = 110`
- cashback credit with 30-day expiry is written to the wallet ledger

### Wallet Split

`POST /api/v1/payments/pay`

```json
{
  "userId": "usr_demo_001",
  "amount": 300,
  "category": "RECHARGE",
  "rail": "UPI"
}
```

Expected:

- `walletAmount = 5`
- `bankAmount = 295`

### Passbook

- `GET /api/v1/passbook?userId=usr_demo_001&tab=all&page=1`
- `GET /api/v1/passbook/wallet?userId=usr_demo_001`
- `GET /api/v1/passbook/cashback?userId=usr_demo_001`
- `GET /api/v1/passbook/balance/bank_demo_001?userId=usr_demo_001`
- `GET /api/v1/passbook/mini-statement/bank_demo_001?userId=usr_demo_001`

## Current Local Limitation In This Workspace

This machine does not currently have Docker or PostgreSQL installed, and port `5432` is not serving a database. The codebase is ready for a real PostgreSQL-backed run, but the server cannot be started successfully until a Postgres instance is available.
