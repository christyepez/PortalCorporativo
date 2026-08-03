param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'

$requiredFiles = @{
  P7Roadmap = 'docs/roadmap/portal-sprint-p7-deployment-hardening-baseline.md'
  RiskRegister = 'docs/roadmap/portal-deployment-hardening-risk-register.md'
  ReadinessChecklist = 'docs/operations/portal-production-readiness-checklist.md'
  DeploymentRunbook = 'docs/operations/portal-deployment-hardening-runbook.md'
  RollbackRunbook = 'docs/operations/portal-rollback-recovery-runbook.md'
  ObservabilityRunbook = 'docs/operations/portal-observability-health-readiness-runbook.md'
  SecurityPolicy = 'docs/security/portal-deployment-security-hardening-policy.md'
  Architecture = 'docs/architecture/portal-deployment-hardening-architecture.md'
  Compose = 'docker-compose.yml'
  EnvExample = '.env.example'
  Foundation = 'backend/building-blocks/src/Portal.BuildingBlocks/FoundationExtensions.cs'
  GatewaySettings = 'backend/api-gateway/src/Portal.ApiGateway/appsettings.json'
}

foreach ($entry in $requiredFiles.GetEnumerator()) {
  $path = Join-Path $Root $entry.Value
  if (-not (Test-Path $path)) { throw "Required deployment hardening file missing: $($entry.Value)" }
}

$p7 = Get-Content (Join-Path $Root $requiredFiles.P7Roadmap) -Raw
foreach ($decision in @(
  'PortalSprintP7DeploymentHardeningBaselineExists: true',
  'ProductionActivationDecision: NoGo',
  'ProductionReadinessChecklistPrepared: true',
  'RollbackRunbookPrepared: true',
  'RecoveryRunbookPrepared: true',
  'ObservabilityRunbookPrepared: true',
  'HealthReadinessRunbookPrepared: true',
  'RuntimeDockerUpValidated: PendingControlledEnvironment',
  'ProductionDeploymentReadiness: HardeningPreparedNotProductionReady',
  'NextGate: PortalSprintP8PortalClosureGate'
)) {
  if ($p7 -notmatch [regex]::Escape($decision)) { throw "P7 decision missing: $decision" }
}

$foundation = Get-Content (Join-Path $Root $requiredFiles.Foundation) -Raw
if ($foundation -notmatch 'MapHealthChecks\("/health/live"' -or $foundation -notmatch 'MapHealthChecks\("/health/ready"' -or $foundation -notmatch 'WriteTo\.Seq') {
  throw 'Health/live/ready or Seq logging foundation not found.'
}

$compose = Get-Content (Join-Path $Root $requiredFiles.Compose) -Raw
foreach ($service in @('sqlserver','redis','minio','seq','api-gateway','notification-worker','integration-worker')) {
  if ($compose -notmatch "(?m)^\s{2}$service\s*:") { throw "Compose service missing: $service" }
}

$envExample = Get-Content (Join-Path $Root $requiredFiles.EnvExample) -Raw
if ($envExample -notmatch 'CHANGE_ME' -or $envExample -match 'BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY|BEGIN CERTIFICATE') {
  throw '.env.example must contain placeholders and no certificate/key material.'
}

$gateway = Get-Content (Join-Path $Root $requiredFiles.GatewaySettings) -Raw
if ($gateway -notmatch 'ReverseProxy' -or $gateway -notmatch 'AuthorizationPolicy') {
  throw 'Gateway ReverseProxy authorization baseline not found.'
}

Write-Host 'Portal deployment hardening foundation verification OK: P7 docs, health/readiness, observability, compose services, placeholders and gateway policy are present.'
