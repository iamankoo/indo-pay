# Indo Pay Beta Release Package

Last updated: 2026-04-23

## Current Status

This repository is now in a local beta-candidate state:

- backend builds successfully and now responds locally on `http://127.0.0.1:4000/api/v1/health`
- analytics, wallet, passbook, merchant, bank transfer preview, IFSC validation, and statement export smoke checks all return live data
- admin runs locally on `http://127.0.0.1:3000`, enforces signed cookie auth, and exports dashboard CSV against the live backend
- Android release APK has been built and copied into the handoff folder
- mobile Dart models no longer require `build_runner`, `freezed`, or generated `g.dart` files
- payment, passbook, and bank transfer screens were hardened for safer idempotent live flows

The remaining blockers are deployment-facing, not workstation setup:

1. A real hosted staging or production API URL still needs to be supplied through Dart defines or flavors before physical-device rollout.
2. A production signing keystore has not been supplied yet, so release-signing is now wired but cannot be completed on this workstation yet.
3. Merchant settlement and statement export URLs still return `files.indo-pay.local` placeholder links until a real storage host is configured.
4. Flutter release verification and physical-device QA still need to be re-run after the new flavor and signing setup.

## Release Artifacts

- release APK: `release\2026-04-11\indo-pay-beta-v0.2.0+2.apk`
- raw Flutter output: `apps/mobile/build/app/outputs/flutter-apk/app-release.apk`
- local backend URL: `http://127.0.0.1:4000/api/v1`
- local admin URL: `http://127.0.0.1:3000`
- admin login: `admin` / `indo-pay-admin`

## Demo Credentials

### Admin Dashboard

- URL: `http://127.0.0.1:3000` after running `npm run dev` inside `apps/admin`
- username env: `INDO_PAY_ADMIN_USERNAME`
- password env: `INDO_PAY_ADMIN_PASSWORD`
- local default fallback username: `admin`
- local default fallback password: `indo-pay-admin`

### Demo User

- mobile: `9876543210`
- OTP verification value used in docs: `112233`
- seeded user id: `usr_demo_001`
- seeded bank account id: `bank_demo_001`
- seeded VPA: `ananya@indopay`

### Merchant Demo

- merchant id: `mrc_demo_001`
- merchant name: `Imphal Campus Cafe`
- city: `Imphal`
- settlement VPA: `merchant@upi`

## Environment Config

### Admin

Use `apps/admin/.env.example` as the starting point. Actual variables:

- `INDO_PAY_API_URL=http://127.0.0.1:4000/api/v1`
- `INDO_PAY_ADMIN_SECRET=<strong-random-secret>`
- `INDO_PAY_ADMIN_USERNAME=<ops-username>`
- `INDO_PAY_ADMIN_PASSWORD=<ops-password>`

### Mobile

Build-time values are injected with Dart defines:

```powershell
flutter run `
  --dart-define=INDO_PAY_API_BASE_URL=https://your-backend-host/api/v1 `
  --dart-define=INDO_PAY_USER_ID=usr_demo_001 `
  --dart-define=INDO_PAY_MERCHANT_ID=mrc_demo_001
```

Default source configuration now avoids local loopback URLs. If no explicit hosted URL is supplied, mobile falls back to:

- staging: `https://staging-api.indo-pay.invalid/api/v1`
- production: `https://api.indo-pay.invalid/api/v1`

That keeps local-only addresses out of release source while still forcing a real hosted endpoint before distribution.

### Backend

Primary variables from `apps/backend/.env.example`:

- `PORT`
- `DATABASE_URL`
- `JWT_SECRET`
- `REDIS_URL`
- `NODE_ENV`

## Seed Data Guide

From `apps/backend`:

```powershell
docker compose up -d
npx prisma migrate dev --name init
npm run prisma:seed
```

Seeded records created by `prisma/seed.js`:

- demo user: `usr_demo_001`
- demo bank account: `bank_demo_001`
- demo merchant: `mrc_demo_001`
- cashback rule: `rule_default_001`
- seed transaction: `txn_seed_001`
- seed wallet credit: `wallet_seed_credit_001`

## Android Build Status

This workstation is now configured with:

- Flutter stable SDK at `C:\Users\iaman\flutter`
- Android SDK directory at `C:\Users\iaman\AppData\Local\Android\Sdk`
- Android Studio JBR at `C:\Program Files\Android\Android Studio\jbr`

The Android scaffold has been generated under `apps/mobile/android`. Android flavors and release-signing hooks are now wired for:

- `staging`
- `production`

Rebuild requirement for physical-device beta:

```powershell
flutter build apk --release --flavor staging `
  --dart-define=INDO_PAY_APP_FLAVOR=staging `
  --dart-define=INDO_PAY_API_BASE_URL=https://your-staging-host/api/v1 `
  --dart-define=INDO_PAY_USER_ID=usr_demo_001 `
  --dart-define=INDO_PAY_MERCHANT_ID=mrc_demo_001
```

Production build command:

```powershell
flutter build apk --release --flavor production `
  --dart-define=INDO_PAY_APP_FLAVOR=production `
  --dart-define=INDO_PAY_API_BASE_URL=https://your-live-backend-host/api/v1 `
  --dart-define=INDO_PAY_USER_ID=usr_demo_001 `
  --dart-define=INDO_PAY_MERCHANT_ID=mrc_demo_001
```

## Release Notes Draft

### Beta Highlights

- live wallet, passbook, payment, bank transfer, and merchant API wiring
- admin dashboard with real analytics fetch and CSV export
- retry-safe payment and transfer requests through mobile idempotency keys
- reward-aware payment success experience
- passbook statement export flow

### Beta Scope

- recharge
- QR pay
- cashback visibility
- bank transfer
- merchant collection demo

## Beta Tester Install Instructions

1. Install `release\2026-04-11\indo-pay-beta-v0.2.0+2.apk` on Android 10 or newer.
2. Allow app installation from your chosen source if Android prompts.
3. For emulator testing, ensure the local backend is running and the APK build uses `10.0.2.2`.
4. For physical-device testing, do not distribute the current APK. Rebuild it first with the real hosted backend URL.
5. Use the provided demo mobile number and OTP if you are on the shared demo environment.
6. Report any failed payment, balance mismatch, or passbook inconsistency immediately with timestamp and screen recording.

## Known Issues

- No physical-device release APK has been rebuilt yet after the new flavor-safe configuration.
- The current Android project no longer points to emulator loopback by default, but a real hosted URL still has to be injected for staging or production builds.
- The current APK on disk is still the older debug-signed artifact until a production keystore is supplied and a new release build is produced.
- `next dev` in `apps/admin` still requires running outside the sandbox on this Windows machine due to a `spawn EPERM` limitation.
- Backend auth still uses scaffold-style session token strings and should be upgraded before public production, even if this beta uses controlled demo access.
- Some backend integrations such as invoice PDFs, settlement PDFs, and statement files still point at placeholder storage hostnames and must be replaced before a wider rollout.

## Rollback Checklist

1. Pause beta distribution and stop sharing the current APK.
2. Disable admin access by rotating `INDO_PAY_ADMIN_SECRET` and admin credentials.
3. Roll back backend deployment to the last known stable image or commit.
4. Re-run ledger sanity checks for wallet credits, debits, and expiries.
5. Freeze merchant settlements if any reconciliation mismatch is detected.
6. Rotate webhook secrets if callback integrity is in doubt.
7. Re-seed the demo environment only after database integrity is verified.
