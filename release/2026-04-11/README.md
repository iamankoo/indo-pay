# Indo Pay Beta Handoff

Date: 2026-04-11

## Artifacts

- APK: `indo-pay-beta-v0.2.0+2.apk`
- Backend URL for current local validation: `http://127.0.0.1:4000/api/v1`
- Admin URL for current local validation: `http://127.0.0.1:3000`

## Admin Access

- username: `admin`
- password: `indo-pay-admin`

## Demo Accounts

- demo user id: `usr_demo_001`
- demo merchant id: `mrc_demo_001`
- demo mobile: `9876543210`
- demo OTP: `112233`

## Install Notes

1. This APK installs on Android as a release-built beta artifact.
2. The current build is wired to `http://10.0.2.2:4000/api/v1`.
3. Use it for emulator or local-stack validation only.
4. Before sharing with real device testers, rebuild with the real hosted backend URL.

## Remaining Release Blockers

- production signing keystore not provided yet
- real hosted backend URL not provided in this workspace
- placeholder file URLs still exist for statement and settlement downloads

See `docs/beta-release-package.md` and `docs/beta-release-checklist.md` for the full beta handoff.
