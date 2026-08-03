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
