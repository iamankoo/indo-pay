# Indo Pay

Indo Pay is a UPI-first Indian payments and rewards platform scaffold designed around a retention-heavy promo wallet:

- 11% cashback on eligible transactions of at least INR 100
- Promo wallet credits expire after 30 days
- Promo wallet is non-withdrawable and non-transferable
- Only 1.6% of a future order can be redeemed from the wallet

This repository is a production-oriented starting point with:

- a NestJS-style backend architecture in `apps/backend`
- a Flutter fintech client architecture in `apps/mobile`
- a Next.js admin and founder dashboard in `apps/admin`
- shared business logic in `packages/shared`
- launch and production docs in `docs`
- a passbook and bank-balance backend module for trust-focused ledger visibility

## Monorepo Layout

```text
indo-pay/
  apps/
    backend/   NestJS-style service structure + Prisma schema
    mobile/    Flutter Android-first fintech client
    admin/     Next.js founder and ops dashboard
  packages/
    shared/    Reward engine reference implementation
  docs/        APIs, webhooks, deployment, security, testing
  tests/       Local validation and reward-engine tests
```

## Core Value Proposition

Indo Pay's operating flywheel is:

> 11% perceived cashback, 1.6% controlled redemption burn.

That keeps rewards visible enough to influence repeat usage while protecting unit economics through expiry and per-order redemption caps.

## Local Validation

The backend and mobile projects are scaffolded but dependencies are not installed automatically in this environment.

You can still validate the core business logic immediately:

```powershell
npm run test:rewards
npm run validate:structure
```

## Next Build Steps

1. Install NestJS backend dependencies inside `apps/backend`
2. Install Flutter locally and run `flutter pub get` inside `apps/mobile`
3. Connect UPI PSP and biller partners behind the payment abstraction layer
4. Back wallet ledger operations with PostgreSQL and Redis
5. Add KYC, risk controls, and signed webhook verification before production

## Backend Checkpoint

The backend now includes:

- Swagger bootstrap at `/api`
- health endpoint at `/api/v1/health`
- Docker Compose for PostgreSQL and Redis in `apps/backend/docker-compose.yml`
- Prisma schema, seed data, and an initial SQL migration
- passbook APIs for wallet ledger, cashback history, balance inquiry, and mini statement
- Redis-backed idempotency, wallet locks, rate limiting, callback replay protection, and dead-letter queues
- merchant onboarding, QR issuance, settlements, payment links, payout settings, and soundbox-ready webhooks
- bank transfer flows for beneficiaries, IFSC validation, smart transfer preview, and transfer execution
- founder analytics payloads for GMV, DAU/WAU, fraud alerts, city adoption, and Imphal beta tracking

See `docs/backend-checkpoint.md` for the runnable backend workflow.
