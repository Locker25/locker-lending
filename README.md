# Locker Lending Dashboard

Offline-first loan servicing dashboard for LockerLending, LLC.

## Current capabilities
- Branded portfolio overview
- Loan register with direct, brokered and syndicated classifications
- Payment tracking with principal reduction
- Maturity and delinquency alerts
- Installable PWA with offline support
- Encrypted local vault using PBKDF2-derived AES-GCM encryption
- Passphrase unlock, manual lock and 15-minute inactivity auto-lock
- Encrypted backup/import files
- Migration away from plaintext localStorage
- Mobile and desktop responsive layout

## Security model
Loan servicing data is encrypted before being stored locally in IndexedDB. The vault passphrase is not stored. Sensitive borrower documents such as SSNs, credit reports, bank statements, driver licenses and unredacted identity documents should not be cached by this application.

The first vault setup automatically imports any records from the original browser prototype and removes those plaintext localStorage records after the encrypted vault is written.

## Cloud/database foundation
`database/schema.sql` contains the production PostgreSQL foundation for users, borrowers, loans, payments, loan events and audit logging. Every production API operation must enforce authenticated ownership/role access before cloud synchronization is enabled.

`config.example.js` is only a deployment template. Production configuration belongs in `config.js`, which is excluded from Git so credentials and environment configuration are not committed to the public repository.

## Deployment target
The intended production location is `https://lockerlending.com/dashboard/` behind authentication. The public Locker Lending marketing site should remain separate from the authenticated servicing application.

## Production gate
Before real borrower data is cloud-synchronized, add the authenticated backend/API, server-side authorization, TLS-only transport, database backups, audit logging and secure document storage. Do not commit API secrets or service-role credentials to this repository.
