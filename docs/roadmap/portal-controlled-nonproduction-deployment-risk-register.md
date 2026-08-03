# Portal Controlled NonProduction Deployment Risk Register

| Risk | Impact | Status | Mitigation |
| --- | --- | --- | --- |
| NonProduction package is mistaken for production readiness | Unsafe release | Blocked | `ProductionActivationDecision: NoGo` and `PortalProductionReady: false` remain explicit |
| Local `.env` placeholders are reused outside controlled environments | Weak credentials | Guarded | `.env` is not versioned; `.env.example` documents placeholders only |
| Real SSO/OIDC or Secret Provider is enabled prematurely | Credential exposure | Guarded | Guardrail script scans for production markers, secrets, private URLs and certificates |
| Real Notification Provider sends email/SMS/push/webhooks | External side effects | Guarded | Provider readiness remains preparation-only and real sending is disabled |
| CRM/Financiero are coupled at runtime before consumer gates | Cross-domain drift | Guarded | Consumer routes and runtime coupling remain disabled |
| Stack is left running after validation | Local resource drift | Guarded | Stop wrapper and rollback runbook require `docker compose down` |
| Observability is insufficient for production | Incident response gap | Open | Deferred to `PortalSprint19OperationalObservabilityPreparation` |
