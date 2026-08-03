# Portal Sprint 11 - Health Smoke Hardening Baseline

## Decision

- PortalSprint11HealthSmokeHardeningBaselineExists: true.
- PortalBaselineClosedReviewed: true.
- ProductionActivationDecision: NoGo.
- PortalProductionReady: false.
- HealthSmokeHardeningAttempted: true.
- GenericHealthEndpointValidated: true.
- LiveHealthEndpointValidated: true.
- ReadyHealthEndpointValidated: true.
- SmokeScriptIdempotencyAttempted: true.
- CleanStackSmokeValidated: true.
- ExistingStackSmokeValidated: true.
- ProtectedEndpointSmokeHandled: true.
- SmokeTestsValidated: true.
- SmokeTestsBlockedReason: none.
- RuntimeDockerUpValidated: true.
- RollbackStopValidated: true.
- FrontendShellBuildable: true.
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
- HealthSmokeReadiness: ValidatedNonProductionOnly.
- NextGate: PortalSprint12DockerFullStackRuntimeValidation.

## Summary

Sprint 11 closes the Sprint 9 health and smoke blockers for controlled NonProduction runtime validation.

- `/health` now maps through the common Portal foundation.
- `/health/live` and `/health/ready` remain available.
- `scripts/smoke/sprint1-smoke.ps1` detects an already running stack and reuses it.
- The smoke script only stops Docker Compose when it started the stack itself.
- Protected endpoints now treat 401/403 as valid protected behavior when a local placeholder token is not accepted by a pre-existing stack.

## Evidence

- Clean-stack smoke: passed; script started the stack, validated health, sent a development notification and stopped the stack.
- Existing-stack smoke: passed; script reused the running stack, validated health and handled protected endpoints returning 401.
- Docker Compose full stack: passed; all Portal services reached running/healthy state.
- `tools/check-portal-health.ps1 -BaseUrl http://localhost:8082`: passed for `/health`, `/health/live` and `/health/ready`.
- Rollback: passed via `docker compose --env-file .env.example down`.

## Gate result

Proceed to `PortalSprint12DockerFullStackRuntimeValidation`. Production remains `NoGo`.
