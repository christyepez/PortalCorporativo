param([string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$requiredFiles = @(
  'docs/roadmap/portal-sprint15-notification-provider-preparation.md',
  'docs/roadmap/portal-notification-provider-go-no-go.md',
  'docs/roadmap/portal-notification-provider-risk-register.md',
  'docs/security/portal-notification-provider-policy.md',
  'docs/security/portal-notification-provider-secret-boundary.md',
  'docs/architecture/portal-notification-provider-architecture.md',
  'docs/operations/portal-notification-provider-runbook.md',
  'docs/operations/portal-notification-provider-placeholder-evidence.md',
  'docs/integration/portal-notification-provider-contract.md',
  'docs/integration/portal-notification-consumer-delivery-contract.md',
  'tools/check-portal-notification-provider-guardrails.ps1'
)

foreach ($relative in $requiredFiles) {
  if (-not (Test-Path (Join-Path $Root $relative))) {
    throw "Missing required Sprint 15 file: $relative"
  }
}

$contents = @()
foreach ($relative in $requiredFiles) {
  $contents += Get-Content (Join-Path $Root $relative) -Raw
}
$text = $contents -join "`n"

$requiredMarkers = @(
  'PortalSprint15NotificationProviderPreparationExists: true',
  'PortalBaselineClosedReviewed: true',
  'Sprint12DockerFullStackReviewed: true',
  'Sprint14SecretProviderReviewed: true',
  'ProductionActivationDecision: NoGo',
  'PortalProductionReady: false',
  'NotificationProviderPreparationAttempted: true',
  'NotificationProviderStrategyPrepared: true',
  'NotificationProviderBoundaryPrepared: true',
  'NotificationProviderContractPrepared: true',
  'NotificationConsumerDeliveryContractPrepared: true',
  'NotificationSecretBoundaryPrepared: true',
  'PlaceholderNotificationProviderDocumented: true',
  'NotificationLifecyclePrepared: true',
  'NotificationIdempotencyPrepared: true',
  'NotificationRetryPolicyPrepared: true',
  'RealEmailProviderConfigured: false',
  'RealSmtpConfigured: false',
  'RealSmsProviderConfigured: false',
  'RealPushProviderConfigured: false',
  'RealWebhookProviderConfigured: false',
  'RealNotificationProviderCredentialsPresent: false',
  'RealNotificationSendingEnabled: false',
  'ExternalApiCallsEnabled: false',
  'SecretProviderReadiness: PreparedNonProductionOnly',
  'DockerFullStackReadiness: ValidatedNonProductionOnly',
  'FrontendShellBuildable: true',
  'BrowserTokenStorageDetected: false',
  'SecretsPresent: false',
  'EnvRealFileCommitted: false',
  'PrivateUrlsPresent: false',
  'RealDataPresent: false',
  'ExternalModuleRuntimeEnabled: false',
  'CrmRuntimeCouplingEnabled: false',
  'FinancialRuntimeCouplingEnabled: false',
  'NotificationProviderReadiness: PreparedNonProductionOnly',
  'NextGate: PortalSprint16ExternalConsumerOnboardingPreparation'
)

foreach ($marker in $requiredMarkers) {
  if ($text -notmatch [regex]::Escape($marker)) {
    throw "Missing Sprint 15 marker: $marker"
  }
}

$architecture = Get-Content (Join-Path $Root 'docs/architecture/portal-notification-provider-architecture.md') -Raw
foreach ($term in @('Notification API','Notification Worker','Provider adapter','Secret Provider','CRM','Financiero')) {
  if ($architecture -notmatch [regex]::Escape($term)) {
    throw "Architecture document missing component boundary: $term"
  }
}

$contract = Get-Content (Join-Path $Root 'docs/integration/portal-notification-provider-contract.md') -Raw
foreach ($term in @('idempotency','retry','provider family','logical credential','correlation id')) {
  if ($contract -notmatch $term) {
    throw "Provider contract missing required term: $term"
  }
}

Write-Host 'Portal Notification Provider preparation verification OK: strategy, provider boundary, consumer delivery contract, secret boundary, lifecycle, idempotency, retry, NoGo and next gate are documented.'
