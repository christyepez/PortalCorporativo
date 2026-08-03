# Portal Sprint P2 - Controlled Deployment Baseline

## Decision

- PortalSprintP2ControlledDeploymentBaselineExists: true.
- PortalDeploymentBaselineReviewed: true.
- ProductionActivationDecision: NoGo.
- NonProductionDeploymentBaselineApproved: true.
- DockerComposeConfigValidated: true.
- DotnetBuildValidated: true.
- DotnetTestsValidated: true.
- FrontendBuildValidated: false.
- FrontendBuildBlockedReason: No buildable frontend package manifest found.
- RuntimeDockerUpValidated: PendingValidation.
- HealthChecksValidated: PendingRuntime.
- SmokeTestsValidated: PendingRuntime.
- SecretsPresent: false.
- EnvRealFileCreated: false.
- PrivateUrlsPresent: false.
- RealDataPresent: false.
- CrmIntegrationReadiness: PendingPortalRuntimeBaseline.
- FinancialIntegrationReadiness: PendingPortalRuntimeBaseline.
- PortalDeploymentReadiness: BaselinePreparedNotProductionReady.
- NextGate: PortalSprintP3AuthSsoSessionBaseline.

## Scope

P2 creates a controlled local/NonProduction deployment baseline for Portal Corporativo. It documents how to validate Docker Compose, backend build/test, health endpoints, smoke checks and security guardrails without enabling production.

No runtime production activation, real `.env`, real tokens, certificates, private URLs, real data, CRM runtime coupling or Financiero runtime coupling are introduced.

## Evidence Plan

- Validate `docker compose --env-file .env.example config`.
- Build `backend/PortalCorporativo.sln`.
- Test with `DOTNET_ROLL_FORWARD=Major`.
- Run safe scripts under `tools/`.
- Keep runtime Docker startup, health and smoke execution pending unless explicitly executed in a controlled local runtime.

## Gate Result

NonProduction baseline is approved as preparation only. Production remains NoGo until Auth/SSO/session handling, runtime health, smoke flows and promotion controls are validated.
