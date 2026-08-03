# Portal External Consumer Onboarding Risk Register

| Risk | Impact | Sprint 16 status | Mitigation |
| --- | --- | --- | --- |
| CRM or Financiero runtime is coupled too early | Domain and deployment drift | Guarded | Guardrails scan Docker Compose and Gateway for consumer services/routes |
| External navigation becomes productive accidentally | Users reach incomplete modules | Guarded | Navigation remains contract-only and relative |
| Consumers share Portal databases or tables | Ownership and migration conflicts | Guarded | Database boundary forbids shared tables and cross-domain migrations |
| Private URLs or secrets are committed | Security exposure | Guarded | Secret/private URL scans remain mandatory |
| Consumers duplicate Portal Auth/Audit/Config/Notification | Fragmented crosscutting ownership | Guarded | Contracts require reuse of Portal APIs and adapters |
| Baseline is mistaken for production approval | Unsafe promotion | Blocked | Production remains NoGo until Sprint 17 or later gates |
