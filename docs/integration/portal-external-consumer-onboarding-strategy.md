# Portal External Consumer Onboarding Strategy

## Purpose

Prepare a repeatable contract-only onboarding process for external consumers such as CRM and Financiero.

## Strategy

1. Register consumer intent through documentation and architecture review.
2. Define module metadata without enabling runtime navigation.
3. Define Security resources, claims and permissions.
4. Define Menu entries as relative route metadata only.
5. Define Configuration keys without secrets.
6. Define Audit event catalog.
7. Define Notification template/event usage without real sending.
8. Confirm database ownership and separate logical database.
9. Confirm deployment ownership and independent release cadence.
10. Approve a later gate before runtime routing or navigation.

## Contract-only status

CRM and Financiero remain future consumers. They are not embedded in Portal runtime and are not deployed by Portal Docker Compose.

## Forbidden shortcuts

- Direct database access to Portal tables.
- Shared migrations across Portal and consumer domains.
- Consumer-owned copies of Portal Auth, Audit, Configuration or Notification.
- Private Gateway destinations before an approved route gate.
