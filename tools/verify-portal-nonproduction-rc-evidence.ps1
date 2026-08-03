param([string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$requiredFiles = @(
  'docs/roadmap/portal-sprint17-nonproduction-release-candidate-gate.md',
  'docs/roadmap/portal-nonproduction-release-candidate-go-no-go.md',
  'docs/roadmap/portal-nonproduction-release-candidate-risk-register.md',
  'docs/roadmap/portal-nonproduction-release-candidate-checklist.md',
  'docs/operations/portal-nonproduction-release-candidate-runbook.md',
  'docs/operations/portal-nonproduction-release-candidate-evidence.md',
  'docs/operations/portal-nonproduction-release-candidate-rollback-evidence.md',
  'docs/architecture/portal-nonproduction-release-candidate-architecture.md',
  'docs/security/portal-nonproduction-release-candidate-security-decision.md',
  'docs/integration/portal-nonproduction-release-candidate-consumer-status.md',
  'tools/check-portal-nonproduction-rc-guardrails.ps1'
)

foreach ($relative in $requiredFiles) {
  if (-not (Test-Path (Join-Path $Root $relative))) {
    throw "Missing required Sprint 17 file: $relative"
  }
}

$contents = @()
foreach ($relative in $requiredFiles) {
  $contents += Get-Content (Join-Path $Root $relative) -Raw
}
$text = $contents -join "`n"

$requiredMarkers = @(
  'PortalSprint17NonProductionReleaseCandidateGateExists: true',
  'PortalBaselineClosedReviewed: true',
  'Sprint9ControlledRuntimeReviewed: true',
  'Sprint10FrontendShellReviewed: true',
  'Sprint11HealthSmokeReviewed: true',
  'Sprint12DockerFullStackReviewed: true',
  'Sprint13ControlledAuthReviewed: true',
  'Sprint14SecretProviderReviewed: true',
  'Sprint15NotificationProviderReviewed: true',
  'Sprint16ExternalConsumerOnboardingReviewed: true',
  'ProductionActivationDecision: NoGo',
  'PortalProductionReady: false',
  'NonProductionReleaseCandidateAttempted: true',
  'DockerComposeConfigValidated: true',
  'DockerFullStackBuildValidated: true',
  'DockerFullStackUpValidated: true',
  'DockerServicesHealthyValidated: true',
  'GenericHealthEndpointValidated: true',
  'LiveHealthEndpointValidated: true',
  'ReadyHealthEndpointValidated: true',
  'CleanStackSmokeValidated: true',
  'ExistingStackSmokeValidated: true',
  'RollbackStopValidated: true',
  'StackStoppedAfterValidation: true',
  'BackendBuildValidated: true',
  'BackendTestsValidated: true',
  'FrontendShellBuildable: true',
  'FrontendTestValidated: true',
  'FrontendLintValidated: true',
  'ControlledAuthReadiness: PreparedNonProductionOnly',
  'SecretProviderReadiness: PreparedNonProductionOnly',
  'NotificationProviderReadiness: PreparedNonProductionOnly',
  'ExternalConsumerOnboardingReadiness: PreparedContractOnly',
  'SsoOidcProductionConfigured: false',
  'RealSecretProviderConfigured: false',
  'RealNotificationProvidersConfigured: false',
  'RealNotificationSendingEnabled: false',
  'ProductiveExternalNavigationEnabled: false',
  'ProductiveExternalGatewayRoutesEnabled: false',
  'ExternalModuleRuntimeEnabled: false',
  'CrmRuntimeCouplingEnabled: false',
  'FinancialRuntimeCouplingEnabled: false',
  'SharedDatabaseWithConsumersPresent: false',
  'BrowserTokenStorageDetected: false',
  'SecretsPresent: false',
  'EnvRealFileCommitted: false',
  'PrivateUrlsPresent: false',
  'RealDataPresent: false',
  'NonProductionReleaseCandidateReadiness: ReadyForControlledNonProductionDeploymentPackage',
  'NextGate: PortalSprint18ControlledNonProductionDeploymentPackage'
)

foreach ($marker in $requiredMarkers) {
  if ($text -notmatch [regex]::Escape($marker)) {
    throw "Missing Sprint 17 marker: $marker"
  }
}

Write-Host 'Portal NonProduction RC evidence verification OK: P1-P16 evidence, GO/NO-GO, checklist, risks, rollback, security, consumer status and next gate are documented.'
