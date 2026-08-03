# Portal Controlled Runtime Go / No-Go

## Decision

- ProductionActivationDecision: NoGo.
- PortalProductionReady: false.
- ControlledRuntimeReadiness: PartialBlocked.
- NextGate: PortalSprint10FrontendShellBuildabilityBaseline.

## Go conditions not yet satisfied

- `/health` route is not available; only `/health/live` and `/health/ready` are validated.
- Smoke execution is not idempotent when a stack is already running on the configured SQL port.
- No production SSO/OIDC provider is configured.
- No production secret provider is configured.
- No real notification providers are configured.
- Frontend shell buildability remains outside this Sprint 9 gate.
- CRM and Financiero runtime coupling remain disabled.

## Allowed next work

- Normalize health endpoint contract.
- Harden smoke scripts to detect/reuse a running controlled stack.
- Validate frontend shell buildability in Sprint 10.
- Keep all runtime validation non-production only.

## Not allowed

- Mark Portal as production-ready.
- Enable production routes or private URLs.
- Commit `.env` or secrets.
- Enable CRM/Financiero runtime coupling.
- Enable SSO/OIDC, secret provider or notification production providers.
