# Locker Lending Dashboard

Offline-first loan servicing dashboard for LockerLending, LLC.

## Scope
- Loan portfolio overview
- Borrower and collateral records
- Payment tracking
- Maturity and delinquency alerts
- Payoff calculations
- Brokered vs. direct-funded classification
- Installable PWA with offline support
- JSON export/import backup

## Deployment target
This app is designed to be hosted at `https://lockerlending.com/dashboard/` behind authentication.

## Security note
The current build is a functional offline-first prototype. Before production use with sensitive borrower information, add server-side authentication, an encrypted database, role-based access, audit logging, and secure document storage. Do not store SSNs, bank credentials, credit reports, or unredacted identity documents in the browser-only version.
