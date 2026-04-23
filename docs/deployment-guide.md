# Deployment Guide

## Environments

- local: mocked PSP and biller integrations
- staging: signed webhook verification and sandbox partners
- production: hardened secrets, isolated VPC, managed databases, and WAF

## Backend Deployment

1. Containerize `apps/backend`.
2. Inject `DATABASE_URL`, Redis URL, JWT keys, PSP keys, and HMAC secrets through a secrets manager.
3. Run Prisma migrations before traffic cutover.
4. Expose APIs behind HTTPS only.
5. Route async events to Kafka topics for analytics and notifications.

## Mobile Delivery

1. Install Flutter locally.
2. Run `flutter pub get` in `apps/mobile`.
3. Configure Android signing, PSP SDKs, camera access, and biometric permissions.
4. Release first to internal testers and campus pilot merchants.

## Local Dev Bootstrap

1. Start PostgreSQL and Redis with `docker compose up -d` from `apps/backend`.
2. Run `npx prisma migrate dev --name init`.
3. Run `npm run prisma:seed`.
4. Start the API with `npm run start:dev`.

## Suggested AWS Shape

- API containers on ECS Fargate
- PostgreSQL on RDS
- Redis on ElastiCache
- Kafka via MSK or managed event bus
- S3 for exports and statements
- CloudFront for static assets
- WAF plus Cloudflare for edge protection

## Operational Readiness

- enable structured logs with trace ids
- track webhook retries and payment reconciliation backlog
- alert on fraud spikes, cashback issue anomalies, and expiry job failures
- keep nightly ledger reconciliation reports
