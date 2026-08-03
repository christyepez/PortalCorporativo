param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'
$failures = @()

function Add-Failure([string]$Message) {
  $script:failures += $Message
}

$decisionPath = Join-Path $Root 'docs/roadmap/portal-sprint12-docker-full-stack-runtime-validation.md'
$goNoGoPath = Join-Path $Root 'docs/roadmap/portal-docker-full-stack-go-no-go.md'
$evidencePath = Join-Path $Root 'docs/operations/portal-docker-full-stack-evidence.md'
$rollbackPath = Join-Path $Root 'docs/operations/portal-docker-full-stack-rollback-evidence.md'
$securityPath = Join-Path $Root 'docs/security/portal-docker-full-stack-security-decision.md'

foreach ($path in @($decisionPath, $goNoGoPath, $evidencePath, $rollbackPath, $securityPath)) {
  if (-not (Test-Path $path)) { Add-Failure "Required evidence document missing: $path" }
}

if ($failures.Count -eq 0) {
  $combined = @(
    Get-Content $decisionPath -Raw
    Get-Content $goNoGoPath -Raw
    Get-Content $evidencePath -Raw
    Get-Content $rollbackPath -Raw
    Get-Content $securityPath -Raw
  ) -join "`n"

  foreach ($marker in @(
    'PortalSprint12DockerFullStackRuntimeValidationExists: true',
    'PortalBaselineClosedReviewed: true',
    'Sprint10FrontendShellReviewed: true',
    'Sprint11HealthSmokeReviewed: true',
    'ProductionActivationDecision: NoGo',
    'PortalProductionReady: false',
    'DockerComposeConfigValidated: true',
    'DockerFullStackBuildValidated: true',
    'DockerFullStackUpValidated: true',
    'DockerServicesHealthyValidated: true',
    'SqlServerContainerValidated: true',
    'SeqContainerValidated: true',
    'SecurityApiContainerValidated: true',
    'ConfigurationApiContainerValidated: true',
    'MenuApiContainerValidated: true',
    'AuditApiContainerValidated: true',
    'NotificationApiContainerValidated: true',
    'NotificationWorkerContainerValidated: true',
    'ApiGatewayContainerValidated: true',
    'GenericHealthEndpointValidated: true',
    'LiveHealthEndpointValidated: true',
    'ReadyHealthEndpointValidated: true',
    'CleanStackSmokeValidated: true',
    'ExistingStackSmokeValidated: true',
    'ProtectedEndpointSmokeHandled: true',
    'LogsReviewed: true',
    'CriticalRuntimeErrorsDetected: false',
    'RollbackStopValidated: true',
    'StackStoppedAfterValidation: true',
    'FrontendShellBuildable: true',
    'FrontendTestValidated: true',
    'FrontendLintValidated: true',
    'SecretsPresent: false',
    'EnvRealFileCommitted: false',
    'PrivateUrlsPresent: false',
    'RealDataPresent: false',
    'SsoOidcProductionConfigured: false',
    'SecretProviderProductionConfigured: false',
    'RealNotificationProvidersConfigured: false',
    'ExternalModuleRuntimeEnabled: false',
    'CrmRuntimeCouplingEnabled: false',
    'FinancialRuntimeCouplingEnabled: false',
    'DockerFullStackReadiness: ValidatedNonProductionOnly',
    'NextGate: PortalSprint13ControlledAuthIntegrationPreparation'
  )) {
    if ($combined -notmatch [regex]::Escape($marker)) { Add-Failure "Evidence marker missing: $marker" }
  }
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Portal Docker full stack evidence verification OK: Sprint 12 runtime, health, smoke, rollback, frontend, NoGo and next gate are documented.'
