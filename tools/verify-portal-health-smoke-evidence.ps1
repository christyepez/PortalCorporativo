param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'

$requiredFiles = @(
  'docs/roadmap/portal-sprint11-health-smoke-hardening-baseline.md',
  'docs/roadmap/portal-health-smoke-go-no-go.md',
  'docs/roadmap/portal-health-smoke-risk-register.md',
  'docs/operations/portal-health-smoke-hardening-runbook.md',
  'docs/operations/portal-health-smoke-evidence.md',
  'docs/operations/portal-smoke-idempotency-evidence.md',
  'docs/architecture/portal-health-smoke-hardening-architecture.md',
  'docs/security/portal-health-smoke-security-decision.md',
  'tools/check-portal-health-smoke-guardrails.ps1',
  'codex/TASKS.md'
)

foreach ($file in $requiredFiles) {
  if (-not (Test-Path (Join-Path $Root $file))) { throw "Required Sprint 11 file missing: $file" }
}

$decision = Get-Content (Join-Path $Root 'docs/roadmap/portal-sprint11-health-smoke-hardening-baseline.md') -Raw
foreach ($line in @(
  'PortalSprint11HealthSmokeHardeningBaselineExists: true',
  'PortalBaselineClosedReviewed: true',
  'ProductionActivationDecision: NoGo',
  'PortalProductionReady: false',
  'HealthSmokeHardeningAttempted: true',
  'GenericHealthEndpointValidated: true',
  'LiveHealthEndpointValidated: true',
  'ReadyHealthEndpointValidated: true',
  'SmokeScriptIdempotencyAttempted: true',
  'CleanStackSmokeValidated: true',
  'ExistingStackSmokeValidated: true',
  'ProtectedEndpointSmokeHandled: true',
  'SmokeTestsValidated: true',
  'SmokeTestsBlockedReason: none',
  'RuntimeDockerUpValidated: true',
  'RollbackStopValidated: true',
  'FrontendShellBuildable: true',
  'SecretsPresent: false',
  'EnvRealFileCommitted: false',
  'PrivateUrlsPresent: false',
  'SsoOidcProductionConfigured: false',
  'SecretProviderProductionConfigured: false',
  'RealNotificationProvidersConfigured: false',
  'ExternalModuleRuntimeEnabled: false',
  'CrmRuntimeCouplingEnabled: false',
  'FinancialRuntimeCouplingEnabled: false',
  'HealthSmokeReadiness: ValidatedNonProductionOnly',
  'NextGate: PortalSprint12DockerFullStackRuntimeValidation'
)) {
  if ($decision -notmatch [regex]::Escape($line)) { throw "Sprint 11 decision missing: $line" }
}

$evidence = Get-Content (Join-Path $Root 'docs/operations/portal-health-smoke-evidence.md') -Raw
foreach ($line in @(
  'GET /health`: 200',
  'GET /health/live`: 200',
  'GET /health/ready`: 200',
  'CleanStackSmokeValidated: true',
  'ExistingStackSmokeValidated: true',
  'RollbackStopValidated: true'
)) {
  if ($evidence -notmatch [regex]::Escape($line)) { throw "Sprint 11 evidence missing: $line" }
}

$tasks = Get-Content (Join-Path $Root 'codex/TASKS.md') -Raw
if ($tasks -notmatch 'Portal Sprint 11 - Health Smoke Hardening Baseline') {
  throw 'codex/TASKS.md missing Portal Sprint 11 entry.'
}

Write-Host 'Portal health/smoke evidence verification OK: Sprint 11 health, smoke, rollback, NoGo decision and next gate are documented.'
