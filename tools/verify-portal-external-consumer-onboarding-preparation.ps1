param([string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$requiredFiles = @(
  'docs/roadmap/portal-sprint16-external-consumer-onboarding-preparation.md',
  'docs/roadmap/portal-external-consumer-onboarding-go-no-go.md',
  'docs/roadmap/portal-external-consumer-onboarding-risk-register.md',
  'docs/integration/portal-external-consumer-onboarding-strategy.md',
  'docs/integration/portal-external-consumer-checklist-crm.md',
  'docs/integration/portal-external-consumer-checklist-financial.md',
  'docs/integration/portal-external-consumer-module-contract.md',
  'docs/integration/portal-external-consumer-navigation-contract.md',
  'docs/integration/portal-external-consumer-security-contract.md',
  'docs/integration/portal-external-consumer-audit-configuration-notification-contract.md',
  'docs/architecture/portal-external-consumer-onboarding-architecture.md',
  'docs/security/portal-external-consumer-boundary-policy.md',
  'docs/operations/portal-external-consumer-onboarding-runbook.md',
  'tools/check-portal-external-consumer-guardrails.ps1'
)

foreach ($relative in $requiredFiles) {
  if (-not (Test-Path (Join-Path $Root $relative))) {
    throw "Missing required Sprint 16 file: $relative"
  }
}

$contents = @()
foreach ($relative in $requiredFiles) {
  $contents += Get-Content (Join-Path $Root $relative) -Raw
}
$text = $contents -join "`n"

$requiredMarkers = @(
  'PortalSprint16ExternalConsumerOnboardingPreparationExists: true',
  'PortalBaselineClosedReviewed: true',
  'Sprint12DockerFullStackReviewed: true',
  'Sprint13ControlledAuthReviewed: true',
  'Sprint14SecretProviderReviewed: true',
  'Sprint15NotificationProviderReviewed: true',
  'ProductionActivationDecision: NoGo',
  'PortalProductionReady: false',
  'ExternalConsumerOnboardingPreparationAttempted: true',
  'ExternalConsumerOnboardingStrategyPrepared: true',
  'CrmOnboardingChecklistPrepared: true',
  'FinancialOnboardingChecklistPrepared: true',
  'ConsumerModuleContractPrepared: true',
  'ConsumerNavigationContractPrepared: true',
  'ConsumerSecurityContractPrepared: true',
  'ConsumerAuditConfigurationNotificationContractPrepared: true',
  'ConsumerDatabaseBoundaryPrepared: true',
  'ConsumerDeploymentBoundaryPrepared: true',
  'ProductiveExternalNavigationEnabled: false',
  'ProductiveExternalGatewayRoutesEnabled: false',
  'ExternalModuleRuntimeEnabled: false',
  'CrmRuntimeCouplingEnabled: false',
  'FinancialRuntimeCouplingEnabled: false',
  'SharedDatabaseWithConsumersPresent: false',
  'CrmRepositoryModified: false',
  'FinancialRepositoryModified: false',
  'RealPrivateUrlsPresent: false',
  'SecretsPresent: false',
  'EnvRealFileCommitted: false',
  'RealDataPresent: false',
  'SsoOidcProductionConfigured: false',
  'SecretProviderReadiness: PreparedNonProductionOnly',
  'NotificationProviderReadiness: PreparedNonProductionOnly',
  'DockerFullStackReadiness: ValidatedNonProductionOnly',
  'FrontendShellBuildable: true',
  'ExternalConsumerOnboardingReadiness: PreparedContractOnly',
  'NextGate: PortalSprint17NonProductionReleaseCandidateGate'
)

foreach ($marker in $requiredMarkers) {
  if ($text -notmatch [regex]::Escape($marker)) {
    throw "Missing Sprint 16 marker: $marker"
  }
}

foreach ($term in @('no DB compartida','no tablas compartidas','no migraciones cruzadas','Portal and consumers deploy independently','CRM','Financiero')) {
  if ($text -notmatch [regex]::Escape($term)) {
    throw "Missing Sprint 16 boundary term: $term"
  }
}

Write-Host 'Portal External Consumer onboarding verification OK: strategy, CRM/Financiero checklists, module, navigation, security, crosscutting, database, deployment, NoGo and next gate are documented.'
