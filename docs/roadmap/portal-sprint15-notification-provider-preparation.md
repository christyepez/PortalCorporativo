# Portal Sprint 15 - Notification Provider Preparation

## Decision

- PortalSprint15NotificationProviderPreparationExists: true.
- PortalBaselineClosedReviewed: true.
- Sprint12DockerFullStackReviewed: true.
- Sprint14SecretProviderReviewed: true.
- ProductionActivationDecision: NoGo.
- PortalProductionReady: false.
- NotificationProviderPreparationAttempted: true.
- NotificationProviderStrategyPrepared: true.
- NotificationProviderBoundaryPrepared: true.
- NotificationProviderContractPrepared: true.
- NotificationConsumerDeliveryContractPrepared: true.
- NotificationSecretBoundaryPrepared: true.
- PlaceholderNotificationProviderDocumented: true.
- NotificationLifecyclePrepared: true.
- NotificationIdempotencyPrepared: true.
- NotificationRetryPolicyPrepared: true.
- RealEmailProviderConfigured: false.
- RealSmtpConfigured: false.
- RealSmsProviderConfigured: false.
- RealPushProviderConfigured: false.
- RealWebhookProviderConfigured: false.
- RealNotificationProviderCredentialsPresent: false.
- RealNotificationSendingEnabled: false.
- ExternalApiCallsEnabled: false.
- SecretProviderReadiness: PreparedNonProductionOnly.
- DockerFullStackReadiness: ValidatedNonProductionOnly.
- FrontendShellBuildable: true.
- BrowserTokenStorageDetected: false.
- SecretsPresent: false.
- EnvRealFileCommitted: false.
- PrivateUrlsPresent: false.
- RealDataPresent: false.
- ExternalModuleRuntimeEnabled: false.
- CrmRuntimeCouplingEnabled: false.
- FinancialRuntimeCouplingEnabled: false.
- NotificationProviderReadiness: PreparedNonProductionOnly.
- NextGate: PortalSprint16ExternalConsumerOnboardingPreparation.

## Summary

Sprint 15 prepares the Notification Provider strategy for Portal Corporativo. It keeps the current runtime limited to development/log/internal providers and documents how future real email, SMTP, SMS, push and webhook adapters must be introduced behind a later approval gate.

No real provider, credential, external API call or production delivery path is configured in this sprint.

## Current runtime posture

| Component | Current mode | Sprint 15 decision |
| --- | --- | --- |
| Notification API | Receives templates, requests, schedule, retry and cancel commands | Keep existing NonProduction foundation |
| Notification Worker | Processes due messages with configured retry policy | Keep development processing only |
| Provider adapter | `InternalDev`, `EmailDev`, `LogDev` | Placeholder providers only |
| Secret Provider | Strategy prepared in Sprint 14 | Real provider resolution deferred |
| CRM/Financiero consumers | Contract-only | No runtime coupling |

## Provider boundary

Future real delivery must be implemented as adapter plugins behind `INotificationProvider` or an equivalent provider port. Provider adapters must not own notification state, templates, retry scheduling, idempotency or audit policy.

Supported future provider families:

- email or SMTP adapter.
- SMS adapter.
- push adapter.
- webhook adapter for controlled integrations.

## Lifecycle

The prepared lifecycle is:

`requested -> queued -> sent | failed -> retry -> sent | failed | cancelled`

Existing domain statuses map to this lifecycle through `Pending`, `Processing`, `Sent`, `Failed`, `Cancelled` and `DeadLetter`.

## Gate result

Notification Provider strategy is prepared for NonProduction only. Production remains `NoGo`.
