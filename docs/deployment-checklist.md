# Deployment Checklist

## Backend

- Set `DATABASE_URL`, `REDIS_URL`, `PSP_WEBHOOK_SECRET`, and `MERCHANT_WEBHOOK_SECRET`
- Run `npm run prisma:generate` and apply migrations in `apps/backend`
- Provision Redis with persistence and alerting for fallback, queue depth, and lock saturation
- Confirm HTTPS, WAF rules, and webhook allowlists before traffic cutover
- Verify Swagger contract, callback signatures, and DLQ monitoring

## Flutter Mobile

- Install Flutter SDK and run `flutter pub get` in `apps/mobile`
- Run `dart run build_runner build --delete-conflicting-outputs` for Freezed/JSON outputs
- Point `INDO_PAY_API_BASE_URL` at the deployed API
- Validate token refresh, retry middleware, and passbook offline cache on real devices
- Confirm Android signing, deep links, and release build settings

## Admin

- Install dependencies in `apps/admin`
- Set `INDO_PAY_API_URL`, `INDO_PAY_ADMIN_SECRET`, `INDO_PAY_ADMIN_USERNAME`, `INDO_PAY_ADMIN_PASSWORD`
- Build with `next build`
- Verify secure cookie behavior on the final admin domain
- Gate access behind company network controls if required

## Release Gates

- Backend `npm run build` passes
- Structure validation and shared reward tests pass
- Monitoring, incident playbooks, and rollback steps are documented
