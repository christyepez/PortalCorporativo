# Portal to CRM Contract Compliance Checklist

CRM must provide evidence for each item before any future runtime pilot:

- Module metadata: stable `crm` module code, owner and lifecycle.
- Navigation: relative placeholder route only, permission-bound, no private URL.
- Security/auth: no CRM login, no identity fork, no token storage.
- Permission claims: CRM permissions registered or proposed through Portal Security.
- Audit: CRM events mapped to Portal Audit contract with correlation id.
- Configuration: CRM settings are module-scoped and contain no secrets.
- Notification: CRM delivery requests use Portal Notification contract and idempotency.
- Health: CRM declares logical health endpoint contract for NonProduction validation.
- Observability: CRM propagates or maps Portal correlation id.
- Deployment ownership: CRM owns consumer runtime; Portal owns Gateway boundary.
- Rollback: CRM pilot can be disabled without Portal data loss.
- DB boundary: CRM database remains logically separate from Portal databases.

CrmComplianceChecklistPrepared: true.
