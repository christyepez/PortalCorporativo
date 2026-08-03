# Portal Financial Crosscutting Contract

## P5 Status

FinancialCrosscuttingReadiness: PendingPortalConsumerContract.

## Intended Integration

- Audit: Financiero submits allowlisted audit events through Portal Audit API.
- Configuration: Financiero reads module-scoped configuration using module code `financial`.
- Notification: Financiero requests Portal-managed notifications after provider and template approval.

## Rules

Financiero must not duplicate Audit, Configuration or Notification ownership, must not share Portal databases and must not activate production notification delivery through P5.
