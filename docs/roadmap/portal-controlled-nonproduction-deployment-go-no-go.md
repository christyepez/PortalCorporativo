# Portal Controlled NonProduction Deployment GO/NO-GO

## GO

GO for preparing and executing a controlled NonProduction deployment package using local placeholder configuration derived from `.env.example`.

## NO-GO

NoGo for production activation.

## Explicit markers

- ProductionActivationDecision: NoGo.
- PortalProductionReady: false.
- ControlledNonProductionDeploymentReadiness: PackagePreparedNonProductionOnly.
- SsoOidcProductionConfigured: false.
- RealSecretProviderConfigured: false.
- RealNotificationProvidersConfigured: false.
- RealNotificationSendingEnabled: false.
- ProductiveExternalNavigationEnabled: false.
- ProductiveExternalGatewayRoutesEnabled: false.
- ExternalModuleRuntimeEnabled: false.
- CrmRuntimeCouplingEnabled: false.
- FinancialRuntimeCouplingEnabled: false.
- SharedDatabaseWithConsumersPresent: false.
- NextGate: PortalSprint19OperationalObservabilityPreparation.

## Required before any future production gate

Production requires approved SSO/OIDC, runtime Secret Provider, production Notification Provider, consumer runtime gates, observability ownership, incident response and production rollback evidence.
