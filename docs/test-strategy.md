# Test Strategy

## Unit Tests

- reward eligibility for transactions below INR 100
- cashback calculation at 11 percent
- wallet redemption cap at 1.6 percent
- 30-day expiry calculation
- fraud flag emission for merchant overuse and duplicate devices

## Integration Tests

- OTP request and verification flow
- merchant payment flow with wallet plus bank split
- reward credit ledger entry creation
- bill payment provider callback handling
- merchant QR issuance and settlement update ingestion
- passbook timeline merge across transactions and wallet entries
- bank balance snapshot creation and mini statement retrieval

## End-to-End Tests

- user signs in, scans QR, pays merchant, and earns cashback
- user redeems wallet on the next purchase with a capped split
- user receives expiry reminders before wallet credits lapse
- merchant onboarding to QR acceptance journey
- user opens passbook and verifies transaction, cashback, and bank balance views in one place

## Non-Functional Tests

- webhook replay resistance
- load testing around peak recharge windows
- fraud rule false-positive review
- ledger reconciliation integrity
