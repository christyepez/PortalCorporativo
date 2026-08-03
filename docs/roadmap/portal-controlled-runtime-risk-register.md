# Portal Controlled Runtime Risk Register

| Risk | Impact | Status | Mitigation |
| --- | --- | --- | --- |
| Generic `/health` returns 404 | Consumers or monitors expecting `/health` may fail readiness gates. | Open | Add or document canonical health contract in next implementation gate. |
| Smoke script not idempotent | Re-running smoke against an already running stack can fail on bound ports. | Open | Update smoke tooling to detect running services or require a clean precondition. |
| Production providers absent | Portal cannot be production-ready without SSO/OIDC, secret provider and real notification providers. | Accepted | Keep `ProductionActivationDecision: NoGo` until dedicated production gates. |
| Frontend shell not buildable | Portal cannot provide complete reusable shell experience. | Open | Execute `PortalSprint10FrontendShellBuildabilityBaseline`. |
| Consumer coupling accidentally enabled | CRM/Financiero could couple to Portal before contracts are production-ready. | Controlled | Guardrails keep consumer runtime disabled and scan compose/gateway. |
| Local placeholder values misunderstood as production | Local-only runtime could be over-promoted. | Controlled | Evidence and docs state non-production only and no secrets committed. |
