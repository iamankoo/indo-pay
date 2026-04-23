# Indo Pay Beta Release Checklist

Last updated: 2026-04-23

## Release Gate

- [x] Backend codebase builds with `npm run build` in `apps/backend`
- [x] Reward engine verification passes with `npm run test:rewards`
- [x] Repository structure verification passes with `npm run validate:structure`
- [x] Admin TypeScript verification passes with `npx tsc --noEmit` in `apps/admin`
- [x] Admin cookie auth, route guard, and CSV export route are wired
- [x] Mobile Dart models no longer depend on generated `freezed`/`g.dart` output
- [x] Flutter SDK installed locally and used successfully for release build
- [x] Android project scaffold present under `apps/mobile/android`
- [x] `flutter pub get` completed
- [ ] Production release keystore configured
- [x] `flutter build apk --release` completed
- [x] Installable beta APK copied into the release handoff folder
- [x] Source no longer defaults to emulator loopback URLs
- [x] Android staging and production flavors are wired
- [x] Android release signing hooks are wired to external `key.properties`
- [ ] APK rebuilt against the real hosted backend URL for physical-device beta

## Safety Checks

- [x] Payment flow sends idempotency keys from the mobile client
- [x] Bank transfer flow sends idempotency keys from the mobile client
- [x] Backend payment path uses Redis locking and idempotency service
- [x] Backend wallet split and cashback path runs inside Prisma transactions
- [x] Reward expiry sweep exists in `apps/backend/src/modules/rewards/rewards.expiry.job.ts`
- [x] Merchant and PSP webhooks verify HMAC signatures
- [x] Admin session cookie is signed and httpOnly
- [x] Local backend health and analytics endpoints respond against seeded data
- [ ] End-to-end device testing completed on Android 10+
- [ ] Live payment reconciliation tested against partner systems

## Product Checks

- [x] Home, wallet, payments, passbook, transfer, and merchant flows are connected to live API contracts
- [x] Admin dashboard reads live analytics and health endpoints
- [x] Passbook export action is wired to the backend export API
- [x] Payment success UI surfaces reward earned details
- [x] Transfer form validates IFSC metadata before preview
- [x] Admin login session and dashboard CSV export validated locally
- [ ] Final visual QA completed on real devices
- [ ] Release splash/icon assets verified on the generated APK
- [ ] Placeholder storage URLs replaced with real hosted file endpoints
- [ ] DM Sans and JetBrains Mono bundled and verified on device if custom font packaging is required

## Launch Ops

- [x] Demo user and merchant seed data documented
- [x] Admin environment variables documented
- [x] Mobile runtime `dart-define` values documented
- [x] Known issues documented
- [x] Rollback checklist documented
- [x] Beta tester install instructions documented with the APK handoff
