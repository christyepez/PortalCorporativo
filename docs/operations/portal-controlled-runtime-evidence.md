# Portal Controlled Runtime Evidence

## Runtime

- ControlledRuntimeValidationAttempted: true.
- DockerComposeConfigValidated: true.
- RuntimeDockerUpValidated: true.
- RuntimeDockerUpBlockedReason: none.
- Runtime services observed: API Gateway, Security API, Configuration API, Menu API, Audit API, Notification API, Catalog API, Content API, Integration API, Reporting API, Notification Worker, Integration Worker, SQL Server, Redis, Seq and MinIO.
- SQL Server service observed: `sqlserver`.
- SQL Server local port observed: `21433`.
- Duplicate SQL Server in Portal compose: false.

## Health

- HealthChecksValidated: false.
- HealthChecksBlockedReason: `/health/live` and `/health/ready` returned 200, but `/health` returned 404.
- `/health/live`: 200.
- `/health/ready`: 200.
- `/health`: 404.

## Smoke

- SmokeTestsValidated: false.
- SmokeTestsBlockedReason: `scripts/smoke/sprint1-smoke.ps1` failed during controlled rerun because SQL port 21433 was already allocated while the stack was already running; after cleanup, the protected endpoint smoke reported authorization failure.

## Logs

- CorrelationLoggingValidated: true.
- Gateway log evidence: structured JSON includes `CorrelationId`, `Service`, `Environment`, `RequestPath` and status.
- Worker log evidence: Notification and Integration workers exposed `/health/ready` with structured JSON and `CorrelationId`.

## Guardrails

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

## Readiness

- ControlledRuntimeReadiness: PartialBlocked.
- ProductionActivationDecision: NoGo.
- PortalProductionReady: false.
- NextGate: PortalSprint10FrontendShellBuildabilityBaseline.
