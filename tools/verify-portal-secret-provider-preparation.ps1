param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'
$failures = @()

function Add-Failure([string]$Message) {
  $script:failures += $Message
}

$paths = @(
  'docs/roadmap/portal-sprint14-secret-provider-preparation.md',
  'docs/roadmap/portal-secret-provider-go-no-go.md',
  'docs/roadmap/portal-secret-provider-risk-register.md',
  'docs/security/portal-secret-provider-policy.md',
  'docs/security/portal-secret-naming-convention.md',
  'docs/security/portal-secret-lifecycle.md',
  'docs/architecture/portal-secret-provider-architecture.md',
  'docs/operations/portal-secret-provider-runbook.md',
  'docs/operations/portal-secret-provider-placeholder-evidence.md',
  'docs/integration/portal-secret-provider-contract.md'
)

foreach ($relative in $paths) {
  if (-not (Test-Path (Join-Path $Root $relative))) { Add-Failure "Required Sprint 14 document missing: $relative" }
}

if ($failures.Count -eq 0) {
  $contents = @()
  foreach ($relative in $paths) {
    $contents += Get-Content (Join-Path $Root $relative) -Raw
  }
  $text = $contents -join "`n"
  foreach ($marker in @(
    'PortalSprint14SecretProviderPreparationExists: true',
    'PortalBaselineClosedReviewed: true',
    'Sprint12DockerFullStackReviewed: true',
    'Sprint13ControlledAuthReviewed: true',
    'ProductionActivationDecision: NoGo',
    'PortalProductionReady: false',
    'SecretProviderPreparationAttempted: true',
    'SecretProviderStrategyPrepared: true',
    'SecretNamingConventionPrepared: true',
    'SecretLifecyclePrepared: true',
    'SecretProviderContractPrepared: true',
    'SecretInventoryPrepared: true',
    'PlaceholderFallbackDocumented: true',
    'RealSecretProviderConfigured: false',
    'AzureKeyVaultConfigured: false',
    'AwsSecretsManagerConfigured: false',
    'GcpSecretManagerConfigured: false',
    'HashiCorpVaultConfigured: false',
    'RealSecretsPresent: false',
    'EnvRealFileCommitted: false',
    'ClientSecretRealConfigured: false',
    'SsoOidcProductionConfigured: false',
    'RealNotificationProvidersConfigured: false',
    'DockerFullStackReadiness: ValidatedNonProductionOnly',
    'FrontendShellBuildable: true',
    'BrowserTokenStorageDetected: false',
    'PrivateUrlsPresent: false',
    'RealDataPresent: false',
    'ExternalModuleRuntimeEnabled: false',
    'CrmRuntimeCouplingEnabled: false',
    'FinancialRuntimeCouplingEnabled: false',
    'SecretProviderReadiness: PreparedNonProductionOnly',
    'NextGate: PortalSprint15NotificationProviderPreparation'
  )) {
    if ($text -notmatch [regex]::Escape($marker)) { Add-Failure "Secret Provider evidence marker missing: $marker" }
  }
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Portal Secret Provider preparation verification OK: strategy, inventory, naming, lifecycle, placeholders, NoGo and next gate are documented.'
