# Portal Critical Blockers

## Current PROD-local state

The controlled local runtime is closed and validated on `trabajo`.

- RuntimeDockerUpValidated: true.
- HealthChecksValidated: true.
- SmokeTestsValidated: true.
- FrontendShellBuildable: true.
- MultiTenantIsolationValidated: true.
- ObservabilityScanValidated: true.
- DriftCheckValidated: true.
- CRM, Financiero, HistoriasPaolin and Talento Humano are runtime-enabled behind the Portal Gateway.

## External production blockers

- SsoOidcProductionConfigured: false.
- SecretProviderProductionConfigured: false.
- RealNotificationProvidersConfigured: false.
- External/cloud production activation is not approved.

## Security / operations blockers

- Production identity provider and registration metadata are not approved.
- Runtime secret provider and rotation ownership are not approved.
- Token/session policy requires validation against the selected production IdP.
- Notification provider credentials must come from an approved external secret store.
- Architecture, Security and Operations approvals remain required by `ExternalProductionActivationInputs`.

## Closure decision

These blockers do not affect the closed PROD-local objective. They intentionally prevent external production activation until approved inputs and ownership are supplied.
