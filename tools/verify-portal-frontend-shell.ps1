param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'

$requiredFiles = @(
  'frontend/package.json',
  'frontend/package-lock.json',
  'frontend/angular.json',
  'frontend/tsconfig.json',
  'frontend/tsconfig.app.json',
  'frontend/tsconfig.spec.json',
  'frontend/src/main.ts',
  'frontend/src/app/app.component.ts',
  'frontend/src/app/app.component.html',
  'frontend/src/app/app.component.css',
  'frontend/src/styles.css',
  'frontend/src/index.html',
  'frontend/src/environments/environment.ts',
  'frontend/src/environments/environment.development.ts',
  'docs/roadmap/portal-sprint10-frontend-shell-buildability-baseline.md',
  'docs/roadmap/portal-frontend-shell-go-no-go.md',
  'docs/roadmap/portal-frontend-shell-risk-register.md',
  'docs/architecture/portal-frontend-shell-architecture.md',
  'docs/operations/portal-frontend-shell-runbook.md',
  'docs/security/portal-frontend-shell-security-decision.md',
  'tools/check-portal-frontend-guardrails.ps1',
  'codex/TASKS.md'
)

foreach ($file in $requiredFiles) {
  $path = Join-Path $Root $file
  if (-not (Test-Path $path)) { throw "Required Sprint 10 file missing: $file" }
}

$decision = Get-Content (Join-Path $Root 'docs/roadmap/portal-sprint10-frontend-shell-buildability-baseline.md') -Raw
foreach ($line in @(
  'PortalSprint10FrontendShellBuildabilityBaselineExists: true',
  'PortalBaselineClosedReviewed: true',
  'ProductionActivationDecision: NoGo',
  'PortalProductionReady: false',
  'FrontendShellBuildabilityAttempted: true',
  'FrontendPackageManifestPresent: true',
  'FrontendShellBuildable: true',
  'FrontendShellBuildBlockedReason: none',
  'FrontendTestValidated: true',
  'FrontendLintValidated: true',
  'TokenStorageInLocalStorageAllowed: false',
  'TokenStorageInSessionStorageAllowed: false',
  'BrowserTokenStorageDetected: false',
  'ProductiveExternalNavigationEnabled: false',
  'CrmNavigationRuntimeEnabled: false',
  'FinancialNavigationRuntimeEnabled: false',
  'SsoOidcProductionConfigured: false',
  'SecretProviderProductionConfigured: false',
  'RealPrivateApiUrlsPresent: false',
  'ExternalModuleRuntimeEnabled: false',
  'FrontendShellReadiness: BuildableNonProductionShell',
  'NextGate: PortalSprint11HealthSmokeHardeningBaseline'
)) {
  if ($decision -notmatch [regex]::Escape($line)) { throw "Sprint 10 decision missing: $line" }
}

$package = Get-Content (Join-Path $Root 'frontend/package.json') -Raw
foreach ($script in @('"build"', '"test"', '"lint"')) {
  if ($package -notmatch [regex]::Escape($script)) { throw "frontend/package.json missing script $script." }
}

$tasks = Get-Content (Join-Path $Root 'codex/TASKS.md') -Raw
if ($tasks -notmatch 'Portal Sprint 10 - Frontend Shell Buildability Baseline') {
  throw 'codex/TASKS.md missing Portal Sprint 10 entry.'
}

Write-Host 'Portal frontend shell verification OK: Angular shell baseline, documents, NoGo decision and next gate are documented.'
