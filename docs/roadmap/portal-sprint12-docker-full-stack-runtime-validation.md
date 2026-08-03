# Portal Sprint 12 - Docker Full Stack Runtime Validation

## Decision

- PortalSprint12DockerFullStackRuntimeValidationExists: true.
- PortalBaselineClosedReviewed: true.
- Sprint10FrontendShellReviewed: true.
- Sprint11HealthSmokeReviewed: true.
- ProductionActivationDecision: NoGo.
- PortalProductionReady: false.
- DockerComposeConfigValidated: true.
- DockerFullStackBuildAttempted: true.
- DockerFullStackBuildValidated: true.
- DockerFullStackUpValidated: true.
- DockerServicesHealthyValidated: true.
- SqlServerContainerValidated: true.
- SeqContainerValidated: true.
- SecurityApiContainerValidated: true.
- ConfigurationApiContainerValidated: true.
- MenuApiContainerValidated: true.
- AuditApiContainerValidated: true.
- NotificationApiContainerValidated: true.
- NotificationWorkerContainerValidated: true.
- ApiGatewayContainerValidated: true.
- GenericHealthEndpointValidated: true.
- LiveHealthEndpointValidated: true.
- ReadyHealthEndpointValidated: true.
- CleanStackSmokeValidated: true.
- ExistingStackSmokeValidated: true.
- ProtectedEndpointSmokeHandled: true.
- LogsReviewed: true.
- CriticalRuntimeErrorsDetected: false.
- RollbackStopValidated: true.
- StackStoppedAfterValidation: true.
- FrontendShellBuildable: true.
- FrontendTestValidated: true.
- FrontendLintValidated: true.
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
- DockerFullStackReadiness: ValidatedNonProductionOnly.
- NextGate: PortalSprint13ControlledAuthIntegrationPreparation.

## Summary

Sprint 12 formalizes the full Docker Compose runtime validation for Portal Corporativo in controlled NonProduction mode. It builds on Sprint 10 frontend shell buildability and Sprint 11 health/smoke hardening.

The validation covers Docker Compose configuration, full-stack build/startup, required service health, Gateway health endpoints, clean-stack smoke, existing-stack smoke, startup logs, rollback stop and frontend build/test/lint.

## Scope

Validated services:

- sqlserver.
- seq.
- security-api.
- configuration-api.
- menu-api.
- audit-api.
- notification-api.
- notification-worker.
- api-gateway.

Additional Portal services may run as part of the full stack, but CRM and Financiero services must not be present in the Portal compose.

## Gate result

Full stack runtime is validated for controlled NonProduction only. Production remains `NoGo`.
