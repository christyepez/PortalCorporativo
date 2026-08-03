param([string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$requiredFiles = @(
  'docs/roadmap/portal-sprint19-operational-observability-preparation.md',
  'docs/roadmap/portal-operational-observability-go-no-go.md',
  'docs/roadmap/portal-operational-observability-risk-register.md',
  'docs/operations/portal-operational-observability-strategy.md',
  'docs/operations/portal-operational-logging-correlation.md',
  'docs/operations/portal-operational-metrics.md',
  'docs/operations/portal-operational-tracing-future.md',
  'docs/operations/portal-operational-health-monitoring.md',
  'docs/operations/portal-operational-log-review-checklist.md',
  'docs/operations/portal-operational-alerting-future.md',
  'docs/operations/portal-operational-incident-triage-runbook.md',
  'docs/operations/portal-operational-slo-sla-nonproduction.md',
  'docs/operations/portal-operational-dashboard-future.md',
  'docs/security/portal-operational-observability-security-decision.md',
  'tools/check-portal-operational-observability-guardrails.ps1',
  'tools/portal-nonproduction-logs.ps1'
)

foreach ($relative in $requiredFiles) {
  if (-not (Test-Path (Join-Path $Root $relative))) {
    throw "Missing required Sprint 19 file: $relative"
  }
}

$contents = @()
foreach ($relative in $requiredFiles) {
  $contents += Get-Content (Join-Path $Root $relative) -Raw
}
$text = $contents -join "`n"

$requiredMarkers = @(
  'PortalSprint19OperationalObservabilityPreparationExists: true',
  'PortalBaselineClosedReviewed: true',
  'Sprint18ControlledNonProductionDeploymentReviewed: true',
  'ProductionActivationDecision: NoGo',
  'PortalProductionReady: false',
  'OperationalObservabilityPreparationAttempted: true',
  'ObservabilityStrategyPrepared: true',
  'LoggingCorrelationPrepared: true',
  'MetricsPrepared: true',
  'FutureTracingPrepared: true',
  'HealthMonitoringPrepared: true',
  'LogReviewChecklistPrepared: true',
  'FutureAlertingPrepared: true',
  'IncidentTriageRunbookPrepared: true',
  'NonProductionSloSlaPrepared: true',
  'FutureDashboardPrepared: true',
  'LocalSeqObservabilityValidated: true',
  'RealApplicationInsightsConfigured: false',
  'RealDatadogConfigured: false',
  'RealNewRelicConfigured: false',
  'RealPrometheusGrafanaConfigured: false',
  'RealSiemConfigured: false',
  'RealExternalAlertsConfigured: false',
  'ObservabilityConnectionStringsPresent: false',
  'ControlledNonProductionDeploymentReadiness: PackagePreparedNonProductionOnly',
  'DockerFullStackReadiness: ValidatedNonProductionOnly',
  'BackendBuildValidated: true',
  'BackendTestsValidated: true',
  'FrontendShellBuildable: true',
  'FrontendTestValidated: true',
  'FrontendLintValidated: true',
  'SsoOidcProductionConfigured: false',
  'RealSecretProviderConfigured: false',
  'RealNotificationProvidersConfigured: false',
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
  'OperationalObservabilityReadiness: PreparedNonProductionOnly',
  'NextGate: PortalSprint20ControlledConsumerRuntimePilotPlanning'
)

foreach ($marker in $requiredMarkers) {
  if ($text -notmatch [regex]::Escape($marker)) {
    throw "Missing Sprint 19 marker: $marker"
  }
}

$compose = Get-Content (Join-Path $Root 'docker-compose.yml') -Raw
if ($compose -notmatch 'seq:' -or $compose -notmatch 'Seq__ServerUrl') {
  throw 'Local Seq service or Seq server URL is not configured.'
}

Write-Host 'Portal operational observability preparation verification OK: strategy, logging/correlation, metrics, health, alerting future, triage, SLO/SLA, dashboard, local Seq and next gate are documented.'
