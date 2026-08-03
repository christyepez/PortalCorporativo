param([string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$requiredFiles = @(
  'docs/roadmap/portal-sprint21-portal-to-crm-contract-alignment-gate.md',
  'docs/roadmap/portal-to-crm-contract-alignment-go-no-go.md',
  'docs/roadmap/portal-to-crm-contract-alignment-risk-register.md',
  'docs/integration/portal-to-crm-contract-alignment-matrix.md',
  'docs/integration/portal-to-crm-contract-compliance-checklist.md',
  'docs/integration/portal-to-crm-known-gaps.md',
  'docs/integration/portal-to-crm-entry-criteria-for-crm-p2.md',
  'docs/integration/portal-to-crm-future-runtime-pilot-exit-criteria.md',
  'docs/integration/portal-to-crm-handoff-plan.md',
  'docs/security/portal-to-crm-contract-alignment-security-decision.md',
  'docs/operations/portal-to-crm-contract-alignment-runbook.md',
  'tools/check-portal-to-crm-contract-alignment-guardrails.ps1'
)

foreach ($relative in $requiredFiles) {
  if (-not (Test-Path (Join-Path $Root $relative))) {
    throw "Missing required Sprint 21 file: $relative"
  }
}

$contents = @()
foreach ($relative in $requiredFiles) {
  $contents += Get-Content (Join-Path $Root $relative) -Raw
}
$text = $contents -join "`n"

$requiredMarkers = @(
  'PortalSprint21PortalToCrmContractAlignmentGateExists: true',
  'PortalBaselineClosedReviewed: true',
  'Sprint20ControlledConsumerRuntimePilotReviewed: true',
  'ProductionActivationDecision: NoGo',
  'PortalProductionReady: false',
  'PortalToCrmContractAlignmentAttempted: true',
  'PortalToCrmAlignmentMatrixPrepared: true',
  'CrmComplianceChecklistPrepared: true',
  'PortalToCrmKnownGapsPrepared: true',
  'CrmP2EntryCriteriaPrepared: true',
  'FutureRuntimePilotExitCriteriaPrepared: true',
  'PortalToCrmHandoffPlanPrepared: true',
  'CrmRepositoryModified: false',
  'ProductiveCrmGatewayRoutesEnabled: false',
  'ProductiveCrmNavigationEnabled: false',
  'CrmRuntimeCouplingEnabled: false',
  'CrmServiceInPortalCompose: false',
  'SharedDatabaseWithCrmPresent: false',
  'CrossDomainMigrationsPresent: false',
  'RealCrmPrivateUrlsPresent: false',
  'SsoOidcProductionConfigured: false',
  'RealSecretProviderConfigured: false',
  'RealNotificationProvidersConfigured: false',
  'RealObservabilityProviderConfigured: false',
  'BrowserTokenStorageDetected: false',
  'SecretsPresent: false',
  'EnvRealFileCommitted: false',
  'RealDataPresent: false',
  'ControlledNonProductionDeploymentReadiness: PackagePreparedNonProductionOnly',
  'OperationalObservabilityReadiness: PreparedNonProductionOnly',
  'PortalToCrmContractAlignmentReadiness: ReadyForCrmP2Planning',
  'NextGate: CrmSprint10P2CommonDbControlledActivationPlan'
)

foreach ($marker in $requiredMarkers) {
  if ($text -notmatch [regex]::Escape($marker)) {
    throw "Missing Sprint 21 marker: $marker"
  }
}

$compose = Get-Content (Join-Path $Root 'docker-compose.yml') -Raw
if ($compose -match '(?im)^\s{2}crm[-_a-z0-9]*\s*:') {
  throw 'Docker Compose contains CRM services before CRM P2 planning.'
}

Write-Host 'Portal to CRM contract alignment verification OK: matrix, checklist, gaps, CRM P2 entry criteria, future pilot exit criteria, handoff, NoGo and next gate are documented.'
