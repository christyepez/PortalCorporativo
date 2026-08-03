# Portal to CRM Contract Alignment Security Decision

## Decision

Sprint 21 permits contract handoff to CRM planning. It does not permit runtime access.

- ProductionActivationDecision: NoGo.
- PortalProductionReady: false.
- CrmRepositoryModified: false.
- ProductiveCrmGatewayRoutesEnabled: false.
- ProductiveCrmNavigationEnabled: false.
- CrmRuntimeCouplingEnabled: false.
- CrmServiceInPortalCompose: false.
- SharedDatabaseWithCrmPresent: false.
- CrossDomainMigrationsPresent: false.
- RealCrmPrivateUrlsPresent: false.
- SsoOidcProductionConfigured: false.
- RealSecretProviderConfigured: false.
- RealNotificationProvidersConfigured: false.
- RealObservabilityProviderConfigured: false.
- BrowserTokenStorageDetected: false.
- SecretsPresent: false.
- EnvRealFileCommitted: false.
- RealDataPresent: false.

## Security boundary

CRM must consume Portal contracts for authentication boundary, permissions, audit, configuration and notifications. CRM must not introduce its own login, role platform, browser token storage, global provider credentials or production runtime route before a later gate.
