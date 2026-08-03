# Roadmap técnico

## Sprint 1 Foundation — cerrado

- [x] P1 Platform Bootstrap: solución, Compose, Gateway, health y logging.
- [x] P2 Security Foundation: usuarios, roles, recursos, permisos y autorización.
- [x] P3 Audit + SQL Outbox/Inbox + Worker Foundation.
- [x] P4 Configuration + Menu Foundation.
- [x] P5 Notification API + Worker Foundation.
- [x] P6 QA integrado y policies backend por permiso.
- [x] Build limpio, 50/50 pruebas y smoke integrado.

## Sprint 2 propuesto

- [ ] Catalog API Foundation.
- [ ] Content/File API Foundation.
- [ ] Reporting API Foundation.
- [ ] Integration API y transporte productivos.
- [ ] Portal Angular Shell integrado con Security/Menu/Configuration.
- [ ] IdP productivo con OIDC/OAuth2.
- [ ] Revocación de permisos y automatización E2E JWT.
- [ ] Jobs de archivo/purga Audit después de 365 días.
- [ ] Evaluar Kafka/RabbitMQ mediante ADR; no introducir broker por defecto.

## Riesgos diferidos

- IdP y SSO productivos; multi-tenant real y aislamiento formal.
- Revocación/latencia de claims y diseño de roles de mínimo privilegio.
- Proveedor productivo de notificaciones y gobierno avanzado de plantillas.
- Outbox transaccional en cada contexto, leasing distribuido y broker productivo.
- Retención automatizada de Audit, HA/observabilidad avanzada y E2E completos.

Detalle y orden: `docs/coordination/sprint-02-roadmap.md`.

## Portal Sprint 9 - Controlled Runtime Validation

Status: implemented in branch `portal-sprint9-controlled-runtime-validation`.

- Task: validación runtime controlada no productiva después del cierre P1-P8.
- Base main commit: `2f83b0c4271fc23326afd8d1c8c3bd0552e12e8a`.
- PortalBaselineClosedReviewed: `true`.
- ProductionActivationDecision: `NoGo`.
- PortalProductionReady: `false`.
- ControlledRuntimeValidationAttempted: `true`.
- DockerComposeConfigValidated: `true`.
- RuntimeDockerUpValidated: `true`.
- HealthChecksValidated: `false`.
- HealthChecksBlockedReason: `/health/live` y `/health/ready` responden 200, pero `/health` responde 404.
- SmokeTestsValidated: `false`.
- SmokeTestsBlockedReason: smoke Sprint 1 no es idempotente con stack ya levantado y reportó fallo de autorización en endpoint protegido.
- GatewayRuntimeValidated: `true`.
- PortalApisRuntimeValidated: `true`.
- WorkersRuntimeValidated: `true`.
- CorrelationLoggingValidated: `true`.
- RollbackStopValidated: `true`.
- SecretsPresent: `false`.
- EnvRealFileCommitted: `false`.
- PrivateUrlsPresent: `false`.
- SsoOidcProductionConfigured: `false`.
- SecretProviderProductionConfigured: `false`.
- RealNotificationProvidersConfigured: `false`.
- ExternalModuleRuntimeEnabled: `false`.
- CrmRuntimeCouplingEnabled: `false`.
- FinancialRuntimeCouplingEnabled: `false`.
- ControlledRuntimeReadiness: `PartialBlocked`.
- NextGate: `PortalSprint10FrontendShellBuildabilityBaseline`.
- PR title: `docs: add portal sprint9 controlled runtime validation`.

## Portal Sprint 10 - Frontend Shell Buildability Baseline

Status: implemented in branch `portal-sprint10-frontend-shell-buildability-baseline`.

- Task: crear baseline Angular buildable para el Frontend Shell del Portal.
- Base main commit: `bbbd135ce4645595a4d82a0ccb49d0e292876de9`.
- PortalBaselineClosedReviewed: `true`.
- ProductionActivationDecision: `NoGo`.
- PortalProductionReady: `false`.
- FrontendShellBuildabilityAttempted: `true`.
- FrontendPackageManifestPresent: `true`.
- FrontendShellBuildable: `true`.
- FrontendShellBuildBlockedReason: `none`.
- FrontendTestValidated: `true`.
- FrontendLintValidated: `true`.
- TokenStorageInLocalStorageAllowed: `false`.
- TokenStorageInSessionStorageAllowed: `false`.
- BrowserTokenStorageDetected: `false`.
- ProductiveExternalNavigationEnabled: `false`.
- CrmNavigationRuntimeEnabled: `false`.
- FinancialNavigationRuntimeEnabled: `false`.
- SsoOidcProductionConfigured: `false`.
- SecretProviderProductionConfigured: `false`.
- RealPrivateApiUrlsPresent: `false`.
- ExternalModuleRuntimeEnabled: `false`.
- FrontendShellReadiness: `BuildableNonProductionShell`.
- NextGate: `PortalSprint11HealthSmokeHardeningBaseline`.
- PR title: `feat: add portal sprint10 frontend shell buildability baseline`.

## Portal Sprint 11 - Health Smoke Hardening Baseline

Status: implemented in branch `portal-sprint11-health-smoke-hardening-baseline`.

- Task: normalizar health y endurecer smoke runtime NonProduction.
- Base main commit: `436e0a499939e0b14a8cd85523d0d88dfcb41940`.
- PortalBaselineClosedReviewed: `true`.
- ProductionActivationDecision: `NoGo`.
- PortalProductionReady: `false`.
- HealthSmokeHardeningAttempted: `true`.
- GenericHealthEndpointValidated: `true`.
- LiveHealthEndpointValidated: `true`.
- ReadyHealthEndpointValidated: `true`.
- SmokeScriptIdempotencyAttempted: `true`.
- CleanStackSmokeValidated: `true`.
- ExistingStackSmokeValidated: `true`.
- ProtectedEndpointSmokeHandled: `true`.
- SmokeTestsValidated: `true`.
- SmokeTestsBlockedReason: `none`.
- RuntimeDockerUpValidated: `true`.
- RollbackStopValidated: `true`.
- FrontendShellBuildable: `true`.
- SecretsPresent: `false`.
- EnvRealFileCommitted: `false`.
- PrivateUrlsPresent: `false`.
- SsoOidcProductionConfigured: `false`.
- SecretProviderProductionConfigured: `false`.
- RealNotificationProvidersConfigured: `false`.
- ExternalModuleRuntimeEnabled: `false`.
- CrmRuntimeCouplingEnabled: `false`.
- FinancialRuntimeCouplingEnabled: `false`.
- HealthSmokeReadiness: `ValidatedNonProductionOnly`.
- NextGate: `PortalSprint12DockerFullStackRuntimeValidation`.
- PR title: `feat: add portal sprint11 health smoke hardening baseline`.

## Portal Sprint 12 - Docker Full Stack Runtime Validation

Status: implemented in branch `portal-sprint12-docker-full-stack-runtime-validation`.

- Task: validar full stack Docker completo del Portal en modo NonProduction controlado.
- Base main commit: `299a41a16f138eab6c326cb4ce18dc80fa36ab15`.
- PortalBaselineClosedReviewed: `true`.
- Sprint10FrontendShellReviewed: `true`.
- Sprint11HealthSmokeReviewed: `true`.
- ProductionActivationDecision: `NoGo`.
- PortalProductionReady: `false`.
- DockerComposeConfigValidated: `true`.
- DockerFullStackBuildAttempted: `true`.
- DockerFullStackBuildValidated: `true`.
- DockerFullStackUpValidated: `true`.
- DockerServicesHealthyValidated: `true`.
- SqlServerContainerValidated: `true`.
- SeqContainerValidated: `true`.
- SecurityApiContainerValidated: `true`.
- ConfigurationApiContainerValidated: `true`.
- MenuApiContainerValidated: `true`.
- AuditApiContainerValidated: `true`.
- NotificationApiContainerValidated: `true`.
- NotificationWorkerContainerValidated: `true`.
- ApiGatewayContainerValidated: `true`.
- GenericHealthEndpointValidated: `true`.
- LiveHealthEndpointValidated: `true`.
- ReadyHealthEndpointValidated: `true`.
- CleanStackSmokeValidated: `true`.
- ExistingStackSmokeValidated: `true`.
- ProtectedEndpointSmokeHandled: `true`.
- LogsReviewed: `true`.
- CriticalRuntimeErrorsDetected: `false`.
- RollbackStopValidated: `true`.
- StackStoppedAfterValidation: `true`.
- FrontendShellBuildable: `true`.
- FrontendTestValidated: `true`.
- FrontendLintValidated: `true`.
- SecretsPresent: `false`.
- EnvRealFileCommitted: `false`.
- PrivateUrlsPresent: `false`.
- RealDataPresent: `false`.
- SsoOidcProductionConfigured: `false`.
- SecretProviderProductionConfigured: `false`.
- RealNotificationProvidersConfigured: `false`.
- ExternalModuleRuntimeEnabled: `false`.
- CrmRuntimeCouplingEnabled: `false`.
- FinancialRuntimeCouplingEnabled: `false`.
- DockerFullStackReadiness: `ValidatedNonProductionOnly`.
- NextGate: `PortalSprint13ControlledAuthIntegrationPreparation`.
- PR title: `feat: add portal sprint12 docker full stack runtime validation`.

## Portal Sprint 13 - Controlled Auth Integration Preparation

Status: implemented in branch `portal-sprint13-controlled-auth-integration-preparation`.

- Task: preparar integración Auth controlada NonProduction sin activar SSO/OIDC real.
- Base main commit: `99ff5191560655cf686922286a5f320c51e2c0b0`.
- PortalBaselineClosedReviewed: `true`.
- Sprint12DockerFullStackReviewed: `true`.
- ProductionActivationDecision: `NoGo`.
- PortalProductionReady: `false`.
- ControlledAuthPreparationAttempted: `true`.
- AuthIntegrationContractPrepared: `true`.
- ClaimsPermissionsContractPrepared: `true`.
- SsoOidcFutureBoundaryPrepared: `true`.
- SsoOidcProductionConfigured: `false`.
- RealClientIdConfigured: `false`.
- RealClientSecretConfigured: `false`.
- RealIssuerConfigured: `false`.
- RealAuthorityConfigured: `false`.
- BrowserTokenStorageDetected: `false`.
- TokenStorageInLocalStorageAllowed: `false`.
- TokenStorageInSessionStorageAllowed: `false`.
- GatewayAuthorizationPolicyPresent: `true`.
- SecurityPermissionsFoundationPresent: `true`.
- DockerFullStackReadiness: `ValidatedNonProductionOnly`.
- FrontendShellBuildable: `true`.
- SecretsPresent: `false`.
- EnvRealFileCommitted: `false`.
- PrivateUrlsPresent: `false`.
- RealDataPresent: `false`.
- ExternalModuleRuntimeEnabled: `false`.
- CrmRuntimeCouplingEnabled: `false`.
- FinancialRuntimeCouplingEnabled: `false`.
- ControlledAuthReadiness: `PreparedNonProductionOnly`.
- NextGate: `PortalSprint14SecretProviderPreparation`.
- PR title: `docs: add portal sprint13 controlled auth integration preparation`.

## Portal Sprint 14 - Secret Provider Preparation

Status: implemented in branch `portal-sprint14-secret-provider-preparation`.

- Task: preparar estrategia y contratos de Secret Provider NonProduction sin activar proveedor real.
- Base main commit: `9da10d7c5c4c4d2bca542bea40e2e8f2d609beae`.
- PortalBaselineClosedReviewed: `true`.
- Sprint12DockerFullStackReviewed: `true`.
- Sprint13ControlledAuthReviewed: `true`.
- ProductionActivationDecision: `NoGo`.
- PortalProductionReady: `false`.
- SecretProviderPreparationAttempted: `true`.
- SecretProviderStrategyPrepared: `true`.
- SecretNamingConventionPrepared: `true`.
- SecretLifecyclePrepared: `true`.
- SecretProviderContractPrepared: `true`.
- SecretInventoryPrepared: `true`.
- PlaceholderFallbackDocumented: `true`.
- RealSecretProviderConfigured: `false`.
- AzureKeyVaultConfigured: `false`.
- AwsSecretsManagerConfigured: `false`.
- GcpSecretManagerConfigured: `false`.
- HashiCorpVaultConfigured: `false`.
- RealSecretsPresent: `false`.
- EnvRealFileCommitted: `false`.
- ClientSecretRealConfigured: `false`.
- SsoOidcProductionConfigured: `false`.
- RealNotificationProvidersConfigured: `false`.
- DockerFullStackReadiness: `ValidatedNonProductionOnly`.
- FrontendShellBuildable: `true`.
- BrowserTokenStorageDetected: `false`.
- PrivateUrlsPresent: `false`.
- RealDataPresent: `false`.
- ExternalModuleRuntimeEnabled: `false`.
- CrmRuntimeCouplingEnabled: `false`.
- FinancialRuntimeCouplingEnabled: `false`.
- SecretProviderReadiness: `PreparedNonProductionOnly`.
- NextGate: `PortalSprint15NotificationProviderPreparation`.
- PR title: `docs: add portal sprint14 secret provider preparation`.

## Portal Sprint 15 - Notification Provider Preparation

Status: implemented in branch `portal-sprint15-notification-provider-preparation`.

- Task: preparar estrategia y contratos de Notification Provider NonProduction sin activar envio real.
- Base main commit: `e77477e75a4619445b6abad468d62216ecffe546`.
- PortalBaselineClosedReviewed: `true`.
- Sprint12DockerFullStackReviewed: `true`.
- Sprint14SecretProviderReviewed: `true`.
- ProductionActivationDecision: `NoGo`.
- PortalProductionReady: `false`.
- NotificationProviderPreparationAttempted: `true`.
- NotificationProviderStrategyPrepared: `true`.
- NotificationProviderBoundaryPrepared: `true`.
- NotificationProviderContractPrepared: `true`.
- NotificationConsumerDeliveryContractPrepared: `true`.
- NotificationSecretBoundaryPrepared: `true`.
- PlaceholderNotificationProviderDocumented: `true`.
- NotificationLifecyclePrepared: `true`.
- NotificationIdempotencyPrepared: `true`.
- NotificationRetryPolicyPrepared: `true`.
- RealEmailProviderConfigured: `false`.
- RealSmtpConfigured: `false`.
- RealSmsProviderConfigured: `false`.
- RealPushProviderConfigured: `false`.
- RealWebhookProviderConfigured: `false`.
- RealNotificationProviderCredentialsPresent: `false`.
- RealNotificationSendingEnabled: `false`.
- ExternalApiCallsEnabled: `false`.
- SecretProviderReadiness: `PreparedNonProductionOnly`.
- DockerFullStackReadiness: `ValidatedNonProductionOnly`.
- FrontendShellBuildable: `true`.
- BrowserTokenStorageDetected: `false`.
- SecretsPresent: `false`.
- EnvRealFileCommitted: `false`.
- PrivateUrlsPresent: `false`.
- RealDataPresent: `false`.
- ExternalModuleRuntimeEnabled: `false`.
- CrmRuntimeCouplingEnabled: `false`.
- FinancialRuntimeCouplingEnabled: `false`.
- NotificationProviderReadiness: `PreparedNonProductionOnly`.
- NextGate: `PortalSprint16ExternalConsumerOnboardingPreparation`.
- PR title: `docs: add portal sprint15 notification provider preparation`.

## Portal Sprint 16 - External Consumer Onboarding Preparation

Status: implemented in branch `portal-sprint16-external-consumer-onboarding-preparation`.

- Task: preparar onboarding externo contract-only para CRM, Financiero y futuros consumidores.
- Base main commit: `0f17995230377180b54183730ee028c409df9852`.
- PortalBaselineClosedReviewed: `true`.
- Sprint12DockerFullStackReviewed: `true`.
- Sprint13ControlledAuthReviewed: `true`.
- Sprint14SecretProviderReviewed: `true`.
- Sprint15NotificationProviderReviewed: `true`.
- ProductionActivationDecision: `NoGo`.
- PortalProductionReady: `false`.
- ExternalConsumerOnboardingPreparationAttempted: `true`.
- ExternalConsumerOnboardingStrategyPrepared: `true`.
- CrmOnboardingChecklistPrepared: `true`.
- FinancialOnboardingChecklistPrepared: `true`.
- ConsumerModuleContractPrepared: `true`.
- ConsumerNavigationContractPrepared: `true`.
- ConsumerSecurityContractPrepared: `true`.
- ConsumerAuditConfigurationNotificationContractPrepared: `true`.
- ConsumerDatabaseBoundaryPrepared: `true`.
- ConsumerDeploymentBoundaryPrepared: `true`.
- ProductiveExternalNavigationEnabled: `false`.
- ProductiveExternalGatewayRoutesEnabled: `false`.
- ExternalModuleRuntimeEnabled: `false`.
- CrmRuntimeCouplingEnabled: `false`.
- FinancialRuntimeCouplingEnabled: `false`.
- SharedDatabaseWithConsumersPresent: `false`.
- CrmRepositoryModified: `false`.
- FinancialRepositoryModified: `false`.
- RealPrivateUrlsPresent: `false`.
- SecretsPresent: `false`.
- EnvRealFileCommitted: `false`.
- RealDataPresent: `false`.
- SsoOidcProductionConfigured: `false`.
- SecretProviderReadiness: `PreparedNonProductionOnly`.
- NotificationProviderReadiness: `PreparedNonProductionOnly`.
- DockerFullStackReadiness: `ValidatedNonProductionOnly`.
- FrontendShellBuildable: `true`.
- ExternalConsumerOnboardingReadiness: `PreparedContractOnly`.
- NextGate: `PortalSprint17NonProductionReleaseCandidateGate`.
- PR title: `docs: add portal sprint16 external consumer onboarding preparation`.

## Portal Sprint 17 - NonProduction Release Candidate Gate

Status: implemented in branch `portal-sprint17-nonproduction-release-candidate-gate`.

- Task: cerrar Release Candidate Gate para despliegue NonProduction controlado.
- Base main commit: `df38eb2f4e41365e9a2ab5b3bdf348341aa5c8be`.
- PortalBaselineClosedReviewed: `true`.
- Sprint9ControlledRuntimeReviewed: `true`.
- Sprint10FrontendShellReviewed: `true`.
- Sprint11HealthSmokeReviewed: `true`.
- Sprint12DockerFullStackReviewed: `true`.
- Sprint13ControlledAuthReviewed: `true`.
- Sprint14SecretProviderReviewed: `true`.
- Sprint15NotificationProviderReviewed: `true`.
- Sprint16ExternalConsumerOnboardingReviewed: `true`.
- ProductionActivationDecision: `NoGo`.
- PortalProductionReady: `false`.
- NonProductionReleaseCandidateAttempted: `true`.
- DockerComposeConfigValidated: `true`.
- DockerFullStackBuildValidated: `true`.
- DockerFullStackUpValidated: `true`.
- DockerServicesHealthyValidated: `true`.
- GenericHealthEndpointValidated: `true`.
- LiveHealthEndpointValidated: `true`.
- ReadyHealthEndpointValidated: `true`.
- CleanStackSmokeValidated: `true`.
- ExistingStackSmokeValidated: `true`.
- RollbackStopValidated: `true`.
- StackStoppedAfterValidation: `true`.
- BackendBuildValidated: `true`.
- BackendTestsValidated: `true`.
- FrontendShellBuildable: `true`.
- FrontendTestValidated: `true`.
- FrontendLintValidated: `true`.
- ControlledAuthReadiness: `PreparedNonProductionOnly`.
- SecretProviderReadiness: `PreparedNonProductionOnly`.
- NotificationProviderReadiness: `PreparedNonProductionOnly`.
- ExternalConsumerOnboardingReadiness: `PreparedContractOnly`.
- SsoOidcProductionConfigured: `false`.
- RealSecretProviderConfigured: `false`.
- RealNotificationProvidersConfigured: `false`.
- RealNotificationSendingEnabled: `false`.
- ProductiveExternalNavigationEnabled: `false`.
- ProductiveExternalGatewayRoutesEnabled: `false`.
- ExternalModuleRuntimeEnabled: `false`.
- CrmRuntimeCouplingEnabled: `false`.
- FinancialRuntimeCouplingEnabled: `false`.
- SharedDatabaseWithConsumersPresent: `false`.
- BrowserTokenStorageDetected: `false`.
- SecretsPresent: `false`.
- EnvRealFileCommitted: `false`.
- PrivateUrlsPresent: `false`.
- RealDataPresent: `false`.
- NonProductionReleaseCandidateReadiness: `ReadyForControlledNonProductionDeploymentPackage`.
- NextGate: `PortalSprint18ControlledNonProductionDeploymentPackage`.
- PR title: `docs: add portal sprint17 nonproduction release candidate gate`.

## Portal Sprint 18 - Controlled NonProduction Deployment Package

Status: implemented in branch `portal-sprint18-controlled-nonproduction-deployment-package`.

- Task: preparar paquete controlado de despliegue NonProduction basado en el Release Candidate Sprint 17.
- Base main commit: `395624a0f998655d75be269af0d8c5b6a684813e`.
- PortalBaselineClosedReviewed: `true`.
- Sprint17NonProductionReleaseCandidateReviewed: `true`.
- ProductionActivationDecision: `NoGo`.
- PortalProductionReady: `false`.
- ControlledNonProductionDeploymentPackageAttempted: `true`.
- DeploymentPackagePrepared: `true`.
- DeploymentRunbookPrepared: `true`.
- ValidationRunbookPrepared: `true`.
- RollbackRunbookPrepared: `true`.
- EnvGuidePrepared: `true`.
- ServicePortMatrixPrepared: `true`.
- CommandMatrixPrepared: `true`.
- OptionalWrapperScriptsPrepared: `true`.
- DockerComposeConfigValidated: `true`.
- DockerFullStackBuildValidated: `true`.
- DockerFullStackUpValidated: `true`.
- DockerServicesHealthyValidated: `true`.
- GenericHealthEndpointValidated: `true`.
- LiveHealthEndpointValidated: `true`.
- ReadyHealthEndpointValidated: `true`.
- ExistingStackSmokeValidated: `true`.
- RollbackStopValidated: `true`.
- StackStoppedAfterValidation: `true`.
- BackendBuildValidated: `true`.
- BackendTestsValidated: `true`.
- FrontendShellBuildable: `true`.
- FrontendTestValidated: `true`.
- FrontendLintValidated: `true`.
- SsoOidcProductionConfigured: `false`.
- RealSecretProviderConfigured: `false`.
- RealNotificationProvidersConfigured: `false`.
- RealNotificationSendingEnabled: `false`.
- ProductiveExternalNavigationEnabled: `false`.
- ProductiveExternalGatewayRoutesEnabled: `false`.
- ExternalModuleRuntimeEnabled: `false`.
- CrmRuntimeCouplingEnabled: `false`.
- FinancialRuntimeCouplingEnabled: `false`.
- SharedDatabaseWithConsumersPresent: `false`.
- BrowserTokenStorageDetected: `false`.
- SecretsPresent: `false`.
- EnvRealFileCommitted: `false`.
- PrivateUrlsPresent: `false`.
- RealDataPresent: `false`.
- ControlledNonProductionDeploymentReadiness: `PackagePreparedNonProductionOnly`.
- NextGate: `PortalSprint19OperationalObservabilityPreparation`.
- PR title: `docs: add portal sprint18 controlled nonproduction deployment package`.

## Portal Sprint 19 - Operational Observability Preparation

Status: implemented in branch `portal-sprint19-operational-observability-preparation`.

- Task: preparar observabilidad operativa NonProduction controlada.
- Base main commit: `20234fe094d57841884243dfddb6d4cfd1295b12`.
- PortalBaselineClosedReviewed: `true`.
- Sprint18ControlledNonProductionDeploymentReviewed: `true`.
- ProductionActivationDecision: `NoGo`.
- PortalProductionReady: `false`.
- OperationalObservabilityPreparationAttempted: `true`.
- ObservabilityStrategyPrepared: `true`.
- LoggingCorrelationPrepared: `true`.
- MetricsPrepared: `true`.
- FutureTracingPrepared: `true`.
- HealthMonitoringPrepared: `true`.
- LogReviewChecklistPrepared: `true`.
- FutureAlertingPrepared: `true`.
- IncidentTriageRunbookPrepared: `true`.
- NonProductionSloSlaPrepared: `true`.
- FutureDashboardPrepared: `true`.
- LocalSeqObservabilityValidated: `true`.
- RealApplicationInsightsConfigured: `false`.
- RealDatadogConfigured: `false`.
- RealNewRelicConfigured: `false`.
- RealPrometheusGrafanaConfigured: `false`.
- RealSiemConfigured: `false`.
- RealExternalAlertsConfigured: `false`.
- ObservabilityConnectionStringsPresent: `false`.
- ControlledNonProductionDeploymentReadiness: `PackagePreparedNonProductionOnly`.
- DockerFullStackReadiness: `ValidatedNonProductionOnly`.
- BackendBuildValidated: `true`.
- BackendTestsValidated: `true`.
- FrontendShellBuildable: `true`.
- FrontendTestValidated: `true`.
- FrontendLintValidated: `true`.
- SsoOidcProductionConfigured: `false`.
- RealSecretProviderConfigured: `false`.
- RealNotificationProvidersConfigured: `false`.
- ProductiveExternalNavigationEnabled: `false`.
- ProductiveExternalGatewayRoutesEnabled: `false`.
- ExternalModuleRuntimeEnabled: `false`.
- CrmRuntimeCouplingEnabled: `false`.
- FinancialRuntimeCouplingEnabled: `false`.
- SharedDatabaseWithConsumersPresent: `false`.
- BrowserTokenStorageDetected: `false`.
- SecretsPresent: `false`.
- EnvRealFileCommitted: `false`.
- PrivateUrlsPresent: `false`.
- RealDataPresent: `false`.
- OperationalObservabilityReadiness: `PreparedNonProductionOnly`.
- NextGate: `PortalSprint20ControlledConsumerRuntimePilotPlanning`.
- PR title: `docs: add portal sprint19 operational observability preparation`.

## Portal Sprint 20 - Controlled Consumer Runtime Pilot Planning

Status: implemented in branch `portal-sprint20-controlled-consumer-runtime-pilot-planning`.

- Task: planificar piloto controlado runtime consumidor con CRM como candidato y Financiero como consumidor futuro.
- Base main commit: `7f2ea8ae0ddbac32481f9883886b2c65b5e5a69b`.
- PortalBaselineClosedReviewed: `true`.
- Sprint18ControlledNonProductionDeploymentReviewed: `true`.
- Sprint19OperationalObservabilityReviewed: `true`.
- ProductionActivationDecision: `NoGo`.
- PortalProductionReady: `false`.
- ControlledConsumerRuntimePilotPlanningAttempted: `true`.
- CrmRuntimePilotPlanPrepared: `true`.
- CrmRuntimePilotChecklistPrepared: `true`.
- CrmRuntimePilotExitCriteriaPrepared: `true`.
- ConsumerRuntimePilotRollbackPrepared: `true`.
- ConsumerRuntimePilotObservabilityPrepared: `true`.
- ConsumerRuntimePilotContractMinimumsPrepared: `true`.
- FinancialFutureConsumerDecisionPrepared: `true`.
- CrmRepositoryModified: `false`.
- FinancialRepositoryModified: `false`.
- ProductiveExternalGatewayRoutesEnabled: `false`.
- ProductiveExternalNavigationEnabled: `false`.
- ExternalModuleRuntimeEnabled: `false`.
- CrmRuntimeCouplingEnabled: `false`.
- FinancialRuntimeCouplingEnabled: `false`.
- SharedDatabaseWithConsumersPresent: `false`.
- SsoOidcProductionConfigured: `false`.
- RealSecretProviderConfigured: `false`.
- RealNotificationProvidersConfigured: `false`.
- RealObservabilityProviderConfigured: `false`.
- BrowserTokenStorageDetected: `false`.
- SecretsPresent: `false`.
- EnvRealFileCommitted: `false`.
- PrivateUrlsPresent: `false`.
- RealDataPresent: `false`.
- ControlledNonProductionDeploymentReadiness: `PackagePreparedNonProductionOnly`.
- OperationalObservabilityReadiness: `PreparedNonProductionOnly`.
- ControlledConsumerRuntimePilotReadiness: `PlannedContractOnly`.
- NextGate: `PortalSprint21PortalToCrmContractAlignmentGate`.
- PR title: `docs: add portal sprint20 controlled consumer runtime pilot planning`.

## Portal Sprint 21 - Portal to CRM Contract Alignment Gate

Status: implemented in branch `portal-sprint21-portal-to-crm-contract-alignment-gate`.

- Task: cerrar gate documental de alineación contractual Portal↔CRM sin activar runtime.
- Base main commit: `ebdedcb309182c23abfc9a294e80bcb0ec002631`.
- PortalBaselineClosedReviewed: `true`.
- Sprint20ControlledConsumerRuntimePilotReviewed: `true`.
- ProductionActivationDecision: `NoGo`.
- PortalProductionReady: `false`.
- PortalToCrmContractAlignmentAttempted: `true`.
- PortalToCrmAlignmentMatrixPrepared: `true`.
- CrmComplianceChecklistPrepared: `true`.
- PortalToCrmKnownGapsPrepared: `true`.
- CrmP2EntryCriteriaPrepared: `true`.
- FutureRuntimePilotExitCriteriaPrepared: `true`.
- PortalToCrmHandoffPlanPrepared: `true`.
- CrmRepositoryModified: `false`.
- ProductiveCrmGatewayRoutesEnabled: `false`.
- ProductiveCrmNavigationEnabled: `false`.
- CrmRuntimeCouplingEnabled: `false`.
- CrmServiceInPortalCompose: `false`.
- SharedDatabaseWithCrmPresent: `false`.
- CrossDomainMigrationsPresent: `false`.
- RealCrmPrivateUrlsPresent: `false`.
- SsoOidcProductionConfigured: `false`.
- RealSecretProviderConfigured: `false`.
- RealNotificationProvidersConfigured: `false`.
- RealObservabilityProviderConfigured: `false`.
- BrowserTokenStorageDetected: `false`.
- SecretsPresent: `false`.
- EnvRealFileCommitted: `false`.
- RealDataPresent: `false`.
- ControlledNonProductionDeploymentReadiness: `PackagePreparedNonProductionOnly`.
- OperationalObservabilityReadiness: `PreparedNonProductionOnly`.
- PortalToCrmContractAlignmentReadiness: `ReadyForCrmP2Planning`.
- NextGate: `CrmSprint10P2CommonDbControlledActivationPlan`.
- PR title: `docs: add portal sprint21 portal to crm contract alignment gate`.

## Portal Sprint P1 - Current State Gate

Status: implemented in branch `portal-sprint-p1-current-state-gate`.

- Task: Current State Gate y preparación de despliegue.
- Base main commit: `c9963b20020fc78014949cf3e29a58235ac260c6`.
- ProductionActivationDecision: `NoGo`.
- PortalDeploymentReadiness: `NotReady`.
- AuthReadiness: `PendingValidation`.
- SsoReadiness: `PendingValidation`.
- MenuReadiness: `PendingValidation`.
- PermissionsReadiness: `PendingValidation`.
- AuditReadiness: `PendingValidation`.
- NotificationReadiness: `PendingValidation`.
- ConfigurationReadiness: `PendingValidation`.
- DockerReadiness: `PendingValidation`.
- HealthCheckReadiness: `PendingValidation`.
- BuildReadiness: `PendingValidation`.
- TestReadiness: `PendingValidation`.
- CrmIntegrationReadiness: `PendingPortalBaseline`.
- FinancialIntegrationReadiness: `PendingPortalBaseline`.
- NextGate: `PortalSprintP2ControlledDeploymentBaseline`.
- PR title: `docs: add portal sprint p1 current state gate`.

## Portal Sprint P2 - Controlled Deployment Baseline

Status: implemented in branch `portal-sprint-p2-controlled-deployment-baseline`.

- Task: baseline controlado de despliegue local/NonProduction.
- Base main commit: `572d792b0e195024895f0156790ef344745ff6f0`.
- ProductionActivationDecision: `NoGo`.
- NonProductionDeploymentBaselineApproved: `true`.
- PortalDeploymentReadiness: `BaselinePreparedNotProductionReady`.
- DockerComposeConfigValidated: `true`.
- DotnetBuildValidated: `true`.
- DotnetTestsValidated: `true`.
- FrontendBuildValidated: `false`.
- FrontendBuildBlockedReason: `No buildable frontend package manifest found`.
- RuntimeDockerUpValidated: `PendingValidation`.
- HealthChecksValidated: `PendingRuntime`.
- SmokeTestsValidated: `PendingRuntime`.
- CrmIntegrationReadiness: `PendingPortalRuntimeBaseline`.
- FinancialIntegrationReadiness: `PendingPortalRuntimeBaseline`.
- NextGate: `PortalSprintP3AuthSsoSessionBaseline`.
- PR title: `docs: add portal sprint p2 controlled deployment baseline`.

## Portal Sprint P3 - Auth / SSO / Session Baseline

Status: implemented in branch `portal-sprint-p3-auth-sso-session-baseline`.

- Task: baseline documental y validación controlada de Auth, SSO y sesión.
- Base main commit: `948101a7ba14b810b5b0b627e4a21fa48e0d51d3`.
- ProductionActivationDecision: `NoGo`.
- SsoProductionActivationDecision: `NoGo`.
- JwtFoundationPresent: `true`.
- PermissionPoliciesPresent: `true`.
- OidcProviderConfiguredForProduction: `false`.
- RealClientSecretsPresent: `false`.
- RealTokensPresent: `false`.
- RealCertificatesPresent: `false`.
- PrivateUrlsPresent: `false`.
- TokenStorageInLocalStorageAllowed: `false`.
- TokenStorageInSessionStorageAllowed: `false`.
- CookiesPolicyPendingValidation: `true`.
- SessionTimeoutPolicyPendingValidation: `true`.
- LogoutFlowPendingValidation: `true`.
- CrmAuthIntegrationReadiness: `PendingPortalAuthContract`.
- FinancialAuthIntegrationReadiness: `PendingPortalAuthContract`.
- AuthSsoReadiness: `BaselinePreparedNotProductionReady`.
- NextGate: `PortalSprintP4MenuPermissionsNavigationBaseline`.
- PR title: `docs: add portal sprint p3 auth sso session baseline`.

## Portal Sprint P4 - Menu / Permissions / Navigation Baseline

Status: implemented in branch `portal-sprint-p4-menu-permissions-navigation-baseline`.

- Task: baseline documental y validación controlada de menú, permisos y navegación.
- Base main commit: `43fe3fba7acebcf64f25c099de63b5f1890f13ba`.
- ProductionActivationDecision: `NoGo`.
- MenuBaselineReviewed: `true`.
- PermissionsBaselineReviewed: `true`.
- NavigationBaselineReviewed: `true`.
- MenuFoundationPresent: `true`.
- SecurityPermissionsFoundationPresent: `true`.
- PermissionPoliciesPresent: `true`.
- GatewayAuthorizationPolicyPresent: `true`.
- ConsumerModuleNavigationContractPrepared: `true`.
- CrmNavigationReadiness: `PendingPortalConsumerContract`.
- FinancialNavigationReadiness: `PendingPortalConsumerContract`.
- ProductiveExternalModuleNavigationEnabled: `false`.
- RealRoutesPresent: `false`.
- PrivateUrlsPresent: `false`.
- RealUserRoleDataPresent: `false`.
- MenuPermissionReadiness: `BaselinePreparedNotProductionReady`.
- NextGate: `PortalSprintP5AuditConfigurationNotificationBaseline`.
- PR title: `docs: add portal sprint p4 menu permissions navigation baseline`.

## Portal Sprint P5 - Audit / Configuration / Notification Baseline

Status: implemented in branch `portal-sprint-p5-audit-configuration-notification-baseline`.

- Task: baseline documental y validación controlada de auditoría, configuración y notificaciones.
- Base main commit: `506ed3d8588b9952680563afadfa254d9b2d9e56`.
- ProductionActivationDecision: `NoGo`.
- AuditBaselineReviewed: `true`.
- ConfigurationBaselineReviewed: `true`.
- NotificationBaselineReviewed: `true`.
- AuditFoundationPresent: `true`.
- ConfigurationFoundationPresent: `true`.
- NotificationFoundationPresent: `true`.
- NotificationWorkerPresent: `true`.
- IntegrationWorkerPresent: `true`.
- CorrelationLoggingFoundationPresent: `true`.
- RealNotificationSendingEnabled: `false`.
- RealSmtpConfigured: `false`.
- RealSmsProviderConfigured: `false`.
- RealPushProviderConfigured: `false`.
- CrmCrosscuttingReadiness: `PendingPortalConsumerContract`.
- FinancialCrosscuttingReadiness: `PendingPortalConsumerContract`.
- AuditConfigurationNotificationReadiness: `BaselinePreparedNotProductionReady`.
- NextGate: `PortalSprintP6IntegrationShellExternalModulesBaseline`.
- PR title: `docs: add portal sprint p5 audit configuration notification baseline`.

## Portal Sprint P6 - Integration Shell / External Modules Baseline

Status: implemented in branch `portal-sprint-p6-integration-shell-external-modules-baseline`.

- Task: baseline documental y validación controlada de Integration Shell / módulos externos.
- Base main commit: `47b2dd75b2640527d1c28e23748eebfb4509ff5a`.
- PortalSprintP6IntegrationShellExternalModulesBaselineExists: `true`.
- IntegrationShellBaselineReviewed: `true`.
- ExternalModuleOnboardingContractPrepared: `true`.
- GatewayExternalModuleBoundaryReviewed: `true`.
- ConsumerModuleBoundaryReviewed: `true`.
- ProductionActivationDecision: `NoGo`.
- ProductiveExternalModuleRuntimeEnabled: `false`.
- ProductiveExternalNavigationEnabled: `false`.
- ProductiveExternalGatewayRoutesEnabled: `false`.
- RealCrmRuntimeCouplingPresent: `false`.
- RealFinancialRuntimeCouplingPresent: `false`.
- SharedDatabaseWithConsumersPresent: `false`.
- CrmModuleOnboardingReadiness: `ContractPreparedNotRuntimeEnabled`.
- FinancialModuleOnboardingReadiness: `ContractPreparedNotRuntimeEnabled`.
- IntegrationShellReadiness: `BaselinePreparedNotProductionReady`.
- NextGate: `PortalSprintP7DeploymentHardeningBaseline`.
- PR title: `docs: add portal sprint p6 integration shell external modules baseline`.

## Portal Sprint P7 - Deployment Hardening Baseline

Status: implemented in branch `portal-sprint-p7-deployment-hardening-baseline`.

- Task: baseline documental y validación controlada de hardening de despliegue.
- Base main commit: `1728e52d813308914c137b81b103b0600b4d3e86`.
- PortalSprintP7DeploymentHardeningBaselineExists: `true`.
- DeploymentHardeningBaselineReviewed: `true`.
- ProductionActivationDecision: `NoGo`.
- ProductionReadinessChecklistPrepared: `true`.
- RollbackRunbookPrepared: `true`.
- RecoveryRunbookPrepared: `true`.
- ObservabilityRunbookPrepared: `true`.
- HealthReadinessRunbookPrepared: `true`.
- DockerComposeConfigValidated: `true`.
- DotnetBuildValidated: `true`.
- DotnetTestsValidated: `true`.
- RuntimeDockerUpValidated: `PendingControlledEnvironment`.
- HealthChecksValidated: `PendingControlledEnvironment`.
- SmokeTestsValidated: `PendingControlledEnvironment`.
- SecretsPresent: `false`.
- EnvRealFileCreated: `false`.
- RealCertificatesPresent: `false`.
- PrivateUrlsPresent: `false`.
- RealDataPresent: `false`.
- ExternalModuleRuntimeEnabled: `false`.
- ProductionDeploymentReadiness: `HardeningPreparedNotProductionReady`.
- NextGate: `PortalSprintP8PortalClosureGate`.
- PR title: `docs: add portal sprint p7 deployment hardening baseline`.

## Portal Sprint P8 - Portal Closure Gate

Status: implemented in branch `portal-sprint-p8-portal-closure-gate`.

- Task: cierre formal de baseline Portal P1-P8 y decision GO/NO-GO.
- Base main commit: `2a806ef06ed5eac98670d9542763e1d3e6dadd45`.
- PortalSprintP8ClosureGateExists: `true`.
- PortalBaselineClosed: `true`.
- PortalP1CurrentStateGateComplete: `true`.
- PortalP2DeploymentBaselineComplete: `true`.
- PortalP3AuthSsoSessionBaselineComplete: `true`.
- PortalP4MenuPermissionsNavigationBaselineComplete: `true`.
- PortalP5AuditConfigurationNotificationBaselineComplete: `true`.
- PortalP6IntegrationShellExternalModulesBaselineComplete: `true`.
- PortalP7DeploymentHardeningBaselineComplete: `true`.
- ProductionActivationDecision: `NoGo`.
- PortalProductionReady: `false`.
- PortalBaselineReadyForControlledRuntimeValidation: `true`.
- RuntimeDockerUpValidated: `PendingControlledEnvironment`.
- HealthChecksValidated: `PendingControlledEnvironment`.
- SmokeTestsValidated: `PendingControlledEnvironment`.
- FrontendShellBuildable: `false`.
- FrontendShellBuildBlockedReason: `No buildable frontend package manifest found`.
- SsoOidcProductionConfigured: `false`.
- SecretProviderProductionConfigured: `false`.
- RealNotificationProvidersConfigured: `false`.
- ExternalModuleRuntimeEnabled: `false`.
- CrmOnboardingReadiness: `ContractPreparedNotRuntimeEnabled`.
- FinancialOnboardingReadiness: `ContractPreparedNotRuntimeEnabled`.
- RecommendedNextStage: `PortalControlledRuntimeValidation`.
- NextGate: `PortalSprint9ControlledRuntimeValidation`.
- PR title: `docs: close portal baseline with sprint p8 closure gate`.
