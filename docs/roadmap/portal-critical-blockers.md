# Portal Critical Blockers

## Production blockers

- RuntimeDockerUpValidated: PendingControlledEnvironment.
- HealthChecksValidated: PendingControlledEnvironment.
- SmokeTestsValidated: PendingControlledEnvironment.
- FrontendShellBuildable: false.
- SsoOidcProductionConfigured: false.
- SecretProviderProductionConfigured: false.
- RealNotificationProvidersConfigured: false.
- ExternalModuleRuntimeEnabled: false.

## Consumer blockers

- CRM onboarding is contract-only and not runtime-enabled.
- Financiero onboarding is contract-only and not runtime-enabled.
- No productive CRM/Financiero gateway routes are approved.
- No productive external navigation is approved.

## Security blockers

- Production identity provider is not selected.
- Runtime secret source is not selected.
- Token/session policy is not production-validated.
- Notification provider secrets are not configured through an approved store.

## Closure decision

These blockers do not prevent baseline closure, but they prevent production readiness.
