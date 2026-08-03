# Portal Frontend Shell Go / No-Go

## Decision

- ProductionActivationDecision: NoGo.
- PortalProductionReady: false.
- FrontendShellReadiness: BuildableNonProductionShell.
- NextGate: PortalSprint11HealthSmokeHardeningBaseline.

## Go for next baseline

- Package manifest exists.
- Angular shell builds.
- Non-interactive test and lint scripts exist and pass.
- Browser credential storage is not used.
- Productive external navigation remains disabled.

## No-Go for production

- No real SSO/OIDC runtime is configured.
- No production secret provider is configured.
- No real notification providers are configured.
- CRM and Financiero navigation are not enabled.
- Sprint 9 health/smoke blockers remain open.

## Allowed next work

- Harden health endpoint and smoke scripts.
- Add real frontend tests once UI behavior grows beyond baseline.
- Wire dynamic Menu/Configuration APIs only through a later controlled gate.
