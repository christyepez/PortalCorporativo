param([string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$requiredFiles = @(
  'docs/roadmap/portal-sprint20-controlled-consumer-runtime-pilot-planning.md',
  'docs/roadmap/portal-consumer-runtime-pilot-go-no-go.md',
  'docs/roadmap/portal-consumer-runtime-pilot-risk-register.md',
  'docs/integration/portal-consumer-runtime-pilot-plan-crm.md',
  'docs/integration/portal-consumer-runtime-pilot-checklist-crm.md',
  'docs/integration/portal-consumer-runtime-pilot-exit-criteria-crm.md',
  'docs/integration/portal-consumer-runtime-pilot-rollback-plan.md',
  'docs/integration/portal-consumer-runtime-pilot-observability-requirements.md',
  'docs/integration/portal-consumer-runtime-pilot-contract-minimums.md',
  'docs/integration/portal-consumer-runtime-pilot-financial-future.md',
  'docs/security/portal-consumer-runtime-pilot-security-decision.md',
  'docs/operations/portal-consumer-runtime-pilot-runbook.md',
  'tools/check-portal-consumer-runtime-pilot-guardrails.ps1'
)

foreach ($relative in $requiredFiles) {
  if (-not (Test-Path (Join-Path $Root $relative))) {
    throw "Missing required Sprint 20 file: $relative"
  }
}

$contents = @()
foreach ($relative in $requiredFiles) {
  $contents += Get-Content (Join-Path $Root $relative) -Raw
}
$text = $contents -join "`n"

$requiredMarkers = @(
  'PortalSprint20ControlledConsumerRuntimePilotPlanningExists: true',
  'PortalBaselineClosedReviewed: true',
  'Sprint18ControlledNonProductionDeploymentReviewed: true',
  'Sprint19OperationalObservabilityReviewed: true',
  'ProductionActivationDecision: NoGo',
  'PortalProductionReady: false',
  'ControlledConsumerRuntimePilotPlanningAttempted: true',
  'CrmRuntimePilotPlanPrepared: true',
  'CrmRuntimePilotChecklistPrepared: true',
  'CrmRuntimePilotExitCriteriaPrepared: true',
  'ConsumerRuntimePilotRollbackPrepared: true',
  'ConsumerRuntimePilotObservabilityPrepared: true',
  'ConsumerRuntimePilotContractMinimumsPrepared: true',
  'FinancialFutureConsumerDecisionPrepared: true',
  'CrmRepositoryModified: false',
  'FinancialRepositoryModified: false',
  'ProductiveExternalGatewayRoutesEnabled: false',
  'ProductiveExternalNavigationEnabled: false',
  'ExternalModuleRuntimeEnabled: false',
  'CrmRuntimeCouplingEnabled: false',
  'FinancialRuntimeCouplingEnabled: false',
  'SharedDatabaseWithConsumersPresent: false',
  'SsoOidcProductionConfigured: false',
  'RealSecretProviderConfigured: false',
  'RealNotificationProvidersConfigured: false',
  'RealObservabilityProviderConfigured: false',
  'BrowserTokenStorageDetected: false',
  'SecretsPresent: false',
  'EnvRealFileCommitted: false',
  'PrivateUrlsPresent: false',
  'RealDataPresent: false',
  'ControlledNonProductionDeploymentReadiness: PackagePreparedNonProductionOnly',
  'OperationalObservabilityReadiness: PreparedNonProductionOnly',
  'ControlledConsumerRuntimePilotReadiness: PlannedContractOnly',
  'NextGate: PortalSprint21PortalToCrmContractAlignmentGate'
)

foreach ($marker in $requiredMarkers) {
  if ($text -notmatch [regex]::Escape($marker)) {
    throw "Missing Sprint 20 marker: $marker"
  }
}

$compose = Get-Content (Join-Path $Root 'docker-compose.yml') -Raw
if ($compose -match '(?im)^\s{2}(crm|financiero|financial)[-_a-z0-9]*\s*:') {
  throw 'Docker Compose contains consumer services before Sprint 21 alignment.'
}

Write-Host 'Portal consumer runtime pilot planning verification OK: CRM plan, checklist, exit criteria, rollback, observability, contract minimums, Financiero future decision, NoGo and next gate are documented.'
