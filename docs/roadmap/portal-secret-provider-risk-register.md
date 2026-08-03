# Portal Secret Provider Risk Register

| Risk | Impact | Status | Mitigation |
| --- | --- | --- | --- |
| Secret values are committed accidentally | Credential leakage. | Guarded | Guardrails scan for `.env`, private keys, certificates, bearer tokens and obvious secret literals. |
| Provider is selected before operational readiness | Production runtime can fail or leak. | Open | Defer real provider activation to a future explicit gate. |
| Secret names are inconsistent | Rotation and incident response become error-prone. | Controlled | Use logical naming convention documented in Sprint 14. |
| Frontend receives secrets | Secrets could be exposed in browser bundles. | Guarded | Frontend shell must not contain secrets or browser token storage. |
| Consumers duplicate secret management | CRM/Financiero can drift from Portal governance. | Guarded | Contract requires consumer onboarding through Portal-owned secret provider policy. |
