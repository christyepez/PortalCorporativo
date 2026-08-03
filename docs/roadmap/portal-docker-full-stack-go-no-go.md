# Portal Docker Full Stack Go/NoGo

## Decision

- DockerFullStackReadiness: ValidatedNonProductionOnly.
- ProductionActivationDecision: NoGo.
- PortalProductionReady: false.
- NextGate: PortalSprint13ControlledAuthIntegrationPreparation.

## Go for controlled NonProduction

Portal may continue to the next controlled preparation gate because:

- Docker Compose config validates.
- Full stack build/startup validates.
- Required services reach running or healthy state.
- `/health`, `/health/live` and `/health/ready` return 200 through the Gateway.
- Clean-stack smoke and existing-stack smoke pass.
- Rollback stop leaves the stack down.
- Frontend shell remains buildable, testable and lintable.

## NoGo for production

Production remains blocked because Sprint 12 does not activate:

- production SSO/OIDC.
- real secret provider.
- real notification providers.
- production external navigation.
- CRM or Financiero runtime coupling.
- production deployment promotion controls.
