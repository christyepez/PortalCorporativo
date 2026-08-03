# Portal CRM Crosscutting Contract

## P5 Status

CrmCrosscuttingReadiness: PendingPortalConsumerContract.

## Intended Integration

- Audit: CRM submits allowlisted audit events through Portal Audit API.
- Configuration: CRM reads module-scoped configuration using module code `crm`.
- Notification: CRM requests Portal-managed notifications after provider and template approval.

## Rules

CRM must not duplicate Audit, Configuration or Notification ownership, must not share Portal databases and must not activate production notification delivery through P5.
