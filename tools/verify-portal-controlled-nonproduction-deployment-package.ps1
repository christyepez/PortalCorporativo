param([string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$requiredFiles = @(
  'docs/roadmap/portal-sprint18-controlled-nonproduction-deployment-package.md',
  'docs/roadmap/portal-controlled-nonproduction-deployment-go-no-go.md',
  'docs/roadmap/portal-controlled-nonproduction-deployment-risk-register.md',
  'docs/operations/portal-controlled-nonproduction-deployment-package.md',
  'docs/operations/portal-controlled-nonproduction-deployment-runbook.md',
  'docs/operations/portal-controlled-nonproduction-validation-runbook.md',
  'docs/operations/portal-controlled-nonproduction-rollback-runbook.md',
  'docs/operations/portal-controlled-nonproduction-env-guide.md',
  'docs/operations/portal-controlled-nonproduction-service-port-matrix.md',
  'docs/operations/portal-controlled-nonproduction-command-matrix.md',
  'docs/security/portal-controlled-nonproduction-deployment-security-decision.md',
  'tools/check-portal-controlled-nonproduction-deployment-guardrails.ps1',
  'tools/portal-nonproduction-deploy.ps1',
  'tools/portal-nonproduction-validate.ps1',
  'tools/portal-nonproduction-stop.ps1'
)

foreach ($relative in $requiredFiles) {
  if (-not (Test-Path (Join-Path $Root $relative))) {
    throw "Missing required Sprint 18 file: $relative"
  }
}

$contents = @()
foreach ($relative in $requiredFiles) {
  $contents += Get-Content (Join-Path $Root $relative) -Raw
}
$text = $contents -join "`n"

$requiredMarkers = @(
  'PortalSprint18ControlledNonProductionDeploymentPackageExists: true',
  'PortalBaselineClosedReviewed: true',
  'Sprint17NonProductionReleaseCandidateReviewed: true',
  'ProductionActivationDecision: NoGo',
  'PortalProductionReady: false',
  'ControlledNonProductionDeploymentPackageAttempted: true',
  'DeploymentPackagePrepared: true',
  'DeploymentRunbookPrepared: true',
  'ValidationRunbookPrepared: true',
  'RollbackRunbookPrepared: true',
  'EnvGuidePrepared: true',
  'ServicePortMatrixPrepared: true',
  'CommandMatrixPrepared: true',
  'OptionalWrapperScriptsPrepared: true',
  'DockerComposeConfigValidated: true',
  'DockerFullStackBuildValidated: true',
  'DockerFullStackUpValidated: true',
  'DockerServicesHealthyValidated: true',
  'GenericHealthEndpointValidated: true',
  'LiveHealthEndpointValidated: true',
  'ReadyHealthEndpointValidated: true',
  'ExistingStackSmokeValidated: true',
  'RollbackStopValidated: true',
  'StackStoppedAfterValidation: true',
  'BackendBuildValidated: true',
  'BackendTestsValidated: true',
  'FrontendShellBuildable: true',
  'FrontendTestValidated: true',
  'FrontendLintValidated: true',
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
  'ControlledNonProductionDeploymentReadiness: PackagePreparedNonProductionOnly',
  'NextGate: PortalSprint19OperationalObservabilityPreparation'
)

foreach ($marker in $requiredMarkers) {
  if ($text -notmatch [regex]::Escape($marker)) {
    throw "Missing Sprint 18 marker: $marker"
  }
}

Write-Host 'Portal controlled NonProduction deployment package verification OK: package, runbooks, env guide, matrices, wrappers, guardrails, NoGo and next gate are documented.'
