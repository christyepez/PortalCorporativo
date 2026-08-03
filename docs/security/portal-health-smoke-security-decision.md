# Portal Health Smoke Security Decision

## Decision

- ProductionActivationDecision: NoGo.
- PortalProductionReady: false.
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

## Security posture

Sprint 11 uses local-only placeholder JWT secrets passed at execution time. No real token, certificate, private URL, `.env`, SSO/OIDC configuration, secret provider or notification provider is committed.

Protected endpoint smoke explicitly accepts 401/403 when reusing a stack configured with a different local placeholder secret. This confirms the endpoint remains protected without requiring real credentials.

## Not approved

- Production authentication.
- Production notification delivery.
- Real secret provider.
- CRM/Financiero runtime activation.
- Browser token storage.
