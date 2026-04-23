# Architecture Overview

## Monorepo

- `apps/backend`: NestJS API surface and domain modules
- `apps/mobile`: Flutter Android-first client shell
- `packages/shared`: reward formulas and reusable business logic
- `docs`: build guidance, contracts, launch and security notes

## Core Services

### Auth Service

- OTP login
- JWT and refresh tokens
- device binding
- MPIN and biometric enforcement hooks

### UPI Payment Service

- collect, intent, VPA, and QR flows
- PSP callback verification
- webhook retries and idempotency
- merchant transaction orchestration

### Wallet Ledger Service

- promo wallet credits
- capped debits at 1.6 percent of order value
- expiry jobs
- transaction to wallet mapping
- immutable ledger trail

### Passbook Service

- merged transaction and wallet timeline
- cashback history
- balance snapshot storage
- mini statement view
- future statement export pipeline

### Rewards Service

- validates minimum transaction threshold
- calculates 11 percent cashback
- applies daily and monthly policy caps
- assigns 30-day expiry
- blocks excluded categories and self-transfer abuse

### Fraud Service

- self-transfer suppression
- same merchant overuse checks
- duplicate device detection
- VPA cycle and merchant loop detection
- merchant collusion scoring

### Analytics Service

- GMV tracking
- cashback issue, redemption, and expiry analysis
- merchant funnel conversion
- user retention cohorts

## Recommended Runtime Topology

1. Mobile app calls API gateway.
2. Auth and device validation run before protected actions.
3. Payment service orchestrates PSP requests and callbacks.
4. Wallet ledger records debit and credit events immutably.
5. Fraud service screens transactions synchronously and asynchronously.
6. Notification service emits reward, expiry, and failure alerts.
7. Analytics service consumes Kafka events for reporting.
8. Passbook queries compose transaction, wallet, and bank balance views for trust and retention.

## Infra Path

- day 1: ECS or simple container deployment with managed PostgreSQL and Redis
- growth: split services across Kubernetes and event-driven workers
- storage: S3 for reports and exports, CloudFront for assets
- edge: Cloudflare and WAF in front of APIs
