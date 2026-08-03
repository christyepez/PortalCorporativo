param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'

$requiredFiles = @(
  'docs/roadmap/portal-sprint9-controlled-runtime-validation.md',
  'docs/roadmap/portal-controlled-runtime-go-no-go.md',
  'docs/roadmap/portal-controlled-runtime-risk-register.md',
  'docs/operations/portal-controlled-runtime-validation-runbook.md',
  'docs/operations/portal-controlled-runtime-evidence.md',
  'docs/operations/portal-runtime-health-smoke-evidence.md',
  'docs/operations/portal-runtime-rollback-evidence.md',
  'docs/architecture/portal-controlled-runtime-validation-architecture.md',
  'docs/security/portal-controlled-runtime-security-decision.md',
  'tools/check-portal-controlled-runtime-guardrails.ps1',
  'codex/TASKS.md'
)

foreach ($file in $requiredFiles) {
  $path = Join-Path $Root $file
  if (-not (Test-Path $path)) { throw "Required Sprint 9 file missing: $file" }
}

$decision = Get-Content (Join-Path $Root 'docs/roadmap/portal-sprint9-controlled-runtime-validation.md') -Raw
foreach ($line in @(
  'PortalSprint9ControlledRuntimeValidationExists: true',
  'PortalBaselineClosedReviewed: true',
  'ProductionActivationDecision: NoGo',
  'PortalProductionReady: false',
  'ControlledRuntimeValidationAttempted: true',
  'DockerComposeConfigValidated: true',
  'RuntimeDockerUpValidated: true',
  'HealthChecksValidated: false',
  'SmokeTestsValidated: false',
  'GatewayRuntimeValidated: true',
  'PortalApisRuntimeValidated: true',
  'WorkersRuntimeValidated: true',
  'CorrelationLoggingValidated: true',
  'RollbackStopValidated: true',
  'SecretsPresent: false',
  'EnvRealFileCommitted: false',
  'PrivateUrlsPresent: false',
  'SsoOidcProductionConfigured: false',
  'SecretProviderProductionConfigured: false',
  'RealNotificationProvidersConfigured: false',
  'ExternalModuleRuntimeEnabled: false',
  'CrmRuntimeCouplingEnabled: false',
  'FinancialRuntimeCouplingEnabled: false',
  'ControlledRuntimeReadiness: PartialBlocked',
  'NextGate: PortalSprint10FrontendShellBuildabilityBaseline'
)) {
  if ($decision -notmatch [regex]::Escape($line)) { throw "Sprint 9 decision missing: $line" }
}

$evidence = Get-Content (Join-Path $Root 'docs/operations/portal-controlled-runtime-evidence.md') -Raw
foreach ($line in @(
  'RuntimeDockerUpValidated: true',
  'HealthChecksValidated: false',
  'SmokeTestsValidated: false',
  'CorrelationLoggingValidated: true',
  'ControlledRuntimeReadiness: PartialBlocked'
)) {
  if ($evidence -notmatch [regex]::Escape($line)) { throw "Sprint 9 evidence missing: $line" }
}

$rollback = Get-Content (Join-Path $Root 'docs/operations/portal-runtime-rollback-evidence.md') -Raw
if ($rollback -notmatch 'RollbackStopValidated: true') {
  throw 'Rollback evidence missing RollbackStopValidated: true.'
}

$tasks = Get-Content (Join-Path $Root 'codex/TASKS.md') -Raw
if ($tasks -notmatch 'Portal Sprint 9 - Controlled Runtime Validation') {
  throw 'codex/TASKS.md missing Portal Sprint 9 entry.'
}

Write-Host 'Portal controlled runtime evidence verification OK: Sprint 9 documents, NoGo decision, partial blockers and next gate are documented.'
