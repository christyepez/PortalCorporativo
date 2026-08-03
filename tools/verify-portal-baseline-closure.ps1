param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'

$requiredFiles = @{
  P1 = 'docs/roadmap/portal-sprint-p1-current-state-gate.md'
  P2 = 'docs/roadmap/portal-sprint-p2-controlled-deployment-baseline.md'
  P3 = 'docs/roadmap/portal-sprint-p3-auth-sso-session-baseline.md'
  P4 = 'docs/roadmap/portal-sprint-p4-menu-permissions-navigation-baseline.md'
  P5 = 'docs/roadmap/portal-sprint-p5-audit-configuration-notification-baseline.md'
  P6 = 'docs/roadmap/portal-sprint-p6-integration-shell-external-modules-baseline.md'
  P7 = 'docs/roadmap/portal-sprint-p7-deployment-hardening-baseline.md'
  P8 = 'docs/roadmap/portal-sprint-p8-portal-closure-gate.md'
  Evidence = 'docs/roadmap/portal-baseline-evidence-summary.md'
  GoNoGo = 'docs/roadmap/portal-go-no-go.md'
  Roadmap = 'docs/roadmap/portal-post-baseline-roadmap.md'
  Blockers = 'docs/roadmap/portal-critical-blockers.md'
  FinalRisks = 'docs/roadmap/portal-risk-register-final.md'
  ClosureRunbook = 'docs/operations/portal-baseline-closure-runbook.md'
  RuntimeNextSteps = 'docs/operations/portal-controlled-runtime-next-steps.md'
  Architecture = 'docs/architecture/portal-baseline-closure-architecture.md'
  SecurityDecision = 'docs/security/portal-baseline-security-decision.md'
  Tasks = 'codex/TASKS.md'
}

foreach ($entry in $requiredFiles.GetEnumerator()) {
  $path = Join-Path $Root $entry.Value
  if (-not (Test-Path $path)) { throw "Required baseline closure file missing: $($entry.Value)" }
}

$p8 = Get-Content (Join-Path $Root $requiredFiles.P8) -Raw
foreach ($decision in @(
  'PortalSprintP8ClosureGateExists: true',
  'PortalBaselineClosed: true',
  'PortalP1CurrentStateGateComplete: true',
  'PortalP2DeploymentBaselineComplete: true',
  'PortalP3AuthSsoSessionBaselineComplete: true',
  'PortalP4MenuPermissionsNavigationBaselineComplete: true',
  'PortalP5AuditConfigurationNotificationBaselineComplete: true',
  'PortalP6IntegrationShellExternalModulesBaselineComplete: true',
  'PortalP7DeploymentHardeningBaselineComplete: true',
  'ProductionActivationDecision: NoGo',
  'PortalProductionReady: false',
  'PortalBaselineReadyForControlledRuntimeValidation: true',
  'RuntimeDockerUpValidated: PendingControlledEnvironment',
  'FrontendShellBuildable: false',
  'SsoOidcProductionConfigured: false',
  'SecretProviderProductionConfigured: false',
  'ExternalModuleRuntimeEnabled: false',
  'RecommendedNextStage: PortalControlledRuntimeValidation',
  'NextGate: PortalSprint9ControlledRuntimeValidation'
)) {
  if ($p8 -notmatch [regex]::Escape($decision)) { throw "P8 closure decision missing: $decision" }
}

$tasks = Get-Content (Join-Path $Root $requiredFiles.Tasks) -Raw
foreach ($sprint in 1..8) {
  if ($tasks -notmatch "Portal Sprint P$sprint") { throw "codex/TASKS.md missing Portal Sprint P$sprint entry." }
}

Write-Host 'Portal baseline closure verification OK: P1-P8 evidence, NoGo decision, blockers, roadmap and next controlled runtime gate are documented.'
