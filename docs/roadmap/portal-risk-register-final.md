# Portal Final Risk Register

| Risk | Impact | Mitigation | Status |
| --- | --- | --- | --- |
| Baseline closure is mistaken for production approval. | Unsafe deployment. | P8 records `ProductionActivationDecision: NoGo` and `PortalProductionReady: false`. | Open |
| Controlled runtime validation is skipped. | Health/smoke unknowns reach production. | Require PortalSprint9ControlledRuntimeValidation. | Open |
| Frontend shell remains non-buildable. | Consumer UX onboarding blocked. | Add buildable shell in a later approved sprint. | Open |
| SSO/OIDC is enabled without provider and secret governance. | Auth/security exposure. | Keep SSO/OIDC production disabled until a dedicated gate. | Open |
| Secret provider is bypassed with committed values. | Credential leakage. | Guardrails reject real `.env`, secrets, certificates and tokens. | Open |
| CRM/Financiero runtime coupling is enabled too early. | Domain and security drift. | Keep onboarding contract-only until future activation. | Open |
| Real notification providers are configured before approval. | Data leakage or spam. | Keep providers development/internal only. | Open |
