# Portal Frontend Shell Risk Register

| Risk | Impact | Status | Mitigation |
| --- | --- | --- | --- |
| Frontend has only structural tests | UI regressions may not be fully covered yet. | Accepted for baseline | Add component tests in a later frontend sprint. |
| npm audit reports dependency vulnerabilities | Tooling dependencies may require future upgrades. | Open | Review Angular/dev tooling upgrades in a dedicated dependency hardening task. |
| Shell could be mistaken as production-ready | Premature activation of navigation or auth would violate guardrails. | Controlled | Docs and guardrails keep production NoGo and external modules disabled. |
| Dynamic API integration absent | Shell does not yet render live Menu/Configuration from Portal APIs. | Deferred | Add controlled API integration after health/smoke hardening. |
| Sprint 9 smoke blockers remain | Runtime confidence remains partial. | Open | Execute `PortalSprint11HealthSmokeHardeningBaseline`. |
