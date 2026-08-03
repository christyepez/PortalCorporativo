# Portal Sprint 9 - Controlled Runtime Validation

## Decision

- PortalSprint9ControlledRuntimeValidationExists: true.
- PortalBaselineClosedReviewed: true.
- ProductionActivationDecision: NoGo.
- PortalProductionReady: false.
- ControlledRuntimeValidationAttempted: true.
- DockerComposeConfigValidated: true.
- RuntimeDockerUpValidated: true.
- RuntimeDockerUpBlockedReason: none.
- HealthChecksValidated: false.
- HealthChecksBlockedReason: `/health/live` and `/health/ready` returned 200, but `/health` returned 404.
- SmokeTestsValidated: false.
- SmokeTestsBlockedReason: `scripts/smoke/sprint1-smoke.ps1` failed during controlled rerun: SQL port 21433 was already allocated while stack was already running, then protected endpoint smoke returned authorization failure.
- GatewayRuntimeValidated: true.
- PortalApisRuntimeValidated: true.
- WorkersRuntimeValidated: true.
- CorrelationLoggingValidated: true.
- RollbackStopValidated: true.
- SecretsPresent: false.
- EnvRealFileCommitted: false.
- PrivateUrlsPresent: false.
- RealDataPresent: false.
- SsoOidcProductionConfigured: false.
- SecretProviderProductionConfigured: false.
- RealNotificationProvidersConfigured: false.
- ExternalModuleRuntimeEnabled: false.
- CrmRuntimeCouplingEnabled: false.
- FinancialRuntimeCouplingEnabled: false.
- ControlledRuntimeReadiness: PartialBlocked.
- NextGate: PortalSprint10FrontendShellBuildabilityBaseline.

## Summary

PortalCorporativo Sprint 9 attempted controlled runtime validation against the P1-P8 closed baseline. Docker Compose can build and start the non-production Portal stack using `.env.example`; API Gateway, Portal APIs, workers and infrastructure containers reached Docker healthy state.

This gate does not approve production. Runtime evidence is partial because the generic `/health` endpoint is not exposed while `/health/live` and `/health/ready` are healthy, and the legacy Sprint 1 smoke script is not idempotent when the stack is already running.

## Evidence captured

- `docker compose --env-file .env.example up -d --build`: completed successfully in the controlled runtime attempt.
- `docker compose --env-file .env.example ps`: Gateway, APIs, workers, SQL Server, Redis and Seq showed running/healthy state.
- Health routes:
  - `/health`: 404.
  - `/health/live`: 200.
  - `/health/ready`: 200.
- Correlation ID:
  - `/health/ready` returned `X-Correlation-ID`.
  - Gateway and worker logs include `CorrelationId` in structured JSON logs.
- Rollback:
  - `docker compose down` was executed by the smoke script cleanup path and later by the controlled rollback validation.

## Gate result

Proceed to `PortalSprint10FrontendShellBuildabilityBaseline` only as a non-production baseline continuation. Do not activate production, SSO/OIDC production, real notification providers, secret providers, external module runtime, CRM coupling or Financial coupling from Sprint 9.
