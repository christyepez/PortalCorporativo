# Portal Sprint 14 - Secret Provider Preparation

## Decision

- PortalSprint14SecretProviderPreparationExists: true.
- PortalBaselineClosedReviewed: true.
- Sprint12DockerFullStackReviewed: true.
- Sprint13ControlledAuthReviewed: true.
- ProductionActivationDecision: NoGo.
- PortalProductionReady: false.
- SecretProviderPreparationAttempted: true.
- SecretProviderStrategyPrepared: true.
- SecretNamingConventionPrepared: true.
- SecretLifecyclePrepared: true.
- SecretProviderContractPrepared: true.
- SecretInventoryPrepared: true.
- PlaceholderFallbackDocumented: true.
- RealSecretProviderConfigured: false.
- AzureKeyVaultConfigured: false.
- AwsSecretsManagerConfigured: false.
- GcpSecretManagerConfigured: false.
- HashiCorpVaultConfigured: false.
- RealSecretsPresent: false.
- EnvRealFileCommitted: false.
- ClientSecretRealConfigured: false.
- SsoOidcProductionConfigured: false.
- RealNotificationProvidersConfigured: false.
- DockerFullStackReadiness: ValidatedNonProductionOnly.
- FrontendShellBuildable: true.
- BrowserTokenStorageDetected: false.
- PrivateUrlsPresent: false.
- RealDataPresent: false.
- ExternalModuleRuntimeEnabled: false.
- CrmRuntimeCouplingEnabled: false.
- FinancialRuntimeCouplingEnabled: false.
- SecretProviderReadiness: PreparedNonProductionOnly.
- NextGate: PortalSprint15NotificationProviderPreparation.

## Summary

Sprint 14 prepares the Secret Provider strategy for Portal Corporativo. It documents how real secrets will be sourced in a future gate, while keeping the current runtime limited to local placeholders and untracked environment values.

No real Key Vault, AWS Secrets Manager, GCP Secret Manager or HashiCorp Vault integration is configured in this sprint.

## Secret inventory

| Area | Logical secrets | Sprint 14 status |
| --- | --- | --- |
| Gateway | JWT signing secret, future OIDC client secret | Placeholder only |
| Security | Security DB password, JWT signing secret | Placeholder only |
| Configuration | Configuration DB password, JWT signing secret | Placeholder only |
| Menu | Menu DB password, JWT signing secret | Placeholder only |
| Audit | Audit DB password, JWT signing secret | Placeholder only |
| Notification | Notification DB password, future provider credentials | Placeholder only |
| Workers | Notification/Integration DB password, worker provider credentials | Placeholder only |
| Frontend shell | No secrets allowed in bundle | Not applicable |
| Future SSO/OIDC | client_id reference, client_secret, issuer/authority metadata | Deferred |
| Future CRM/Financiero onboarding | consumer client credentials or trust configuration | Deferred |

## Gate result

Secret Provider strategy is prepared for NonProduction only. Production remains `NoGo`.
