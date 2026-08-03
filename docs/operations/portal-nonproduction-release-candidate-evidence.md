# Portal NonProduction Release Candidate Evidence

## Evidence summary

- DockerComposeConfigValidated: true.
- DockerFullStackBuildValidated: true.
- DockerFullStackUpValidated: true.
- DockerServicesHealthyValidated: true.
- GenericHealthEndpointValidated: true.
- LiveHealthEndpointValidated: true.
- ReadyHealthEndpointValidated: true.
- CleanStackSmokeValidated: true.
- ExistingStackSmokeValidated: true.
- BackendBuildValidated: true.
- BackendTestsValidated: true.
- FrontendShellBuildable: true.
- FrontendTestValidated: true.
- FrontendLintValidated: true.
- StackStoppedAfterValidation: true.

## Guardrail evidence

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
- BrowserTokenStorageDetected: false.
- SecretsPresent: false.
- EnvRealFileCommitted: false.
- PrivateUrlsPresent: false.
- RealDataPresent: false.

## RC decision

NonProductionReleaseCandidateReadiness: ReadyForControlledNonProductionDeploymentPackage.
