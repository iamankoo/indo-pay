# Production Security Checklist

## Platform

- enforce HTTPS and HSTS
- store secrets in a dedicated secret manager
- rotate PSP keys and webhook HMAC secrets
- segment production and staging environments
- enable WAF and rate limits

## Auth and Sessions

- OTP rate limiting by mobile, IP, and device fingerprint
- device binding before high-risk actions
- MPIN hashing with a strong password KDF
- short-lived access tokens and revocable refresh tokens
- biometric unlock only as a local convenience layer

## Wallet and Ledger

- immutable ledger entries
- dual control for manual adjustments
- balance reconstruction from ledger instead of mutable totals
- expiry jobs must be idempotent
- bank and wallet split calculations must be server-authoritative

## Webhooks and Integrations

- sign and verify every callback
- reject replayed events using event ids and timestamps
- keep reconciliation jobs for PSP and biller mismatches
- never trust merchant-provided QR metadata without parsing and validation

## Fraud

- block self-transfers from cashback
- cap same merchant rewarded usage per day
- flag duplicate devices and VPA cycles
- review merchant collusion clusters
- maintain operator-side allowlists and blocklists

## Compliance and Data

- encrypt sensitive data at rest and in transit
- tokenize bank references where possible
- redact PII in logs
- define retention and deletion policies
- align rollout with RBI, NPCI, and partner bank obligations before launch

