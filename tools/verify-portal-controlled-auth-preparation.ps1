param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'
$failures = @()

function Add-Failure([string]$Message) {
  $script:failures += $Message
}

$paths = @(
  'docs/roadmap/portal-sprint13-controlled-auth-integration-preparation.md',
  'docs/roadmap/portal-controlled-auth-go-no-go.md',
  'docs/roadmap/portal-controlled-auth-risk-register.md',
  'docs/security/portal-controlled-auth-integration-policy.md',
  'docs/security/portal-oidc-sso-future-boundary.md',
  'docs/architecture/portal-controlled-auth-integration-architecture.md',
  'docs/operations/portal-controlled-auth-runbook.md',
  'docs/integration/portal-auth-consumer-contract.md',
  'docs/integration/portal-auth-claims-permissions-contract.md'
)

foreach ($relative in $paths) {
  if (-not (Test-Path (Join-Path $Root $relative))) { Add-Failure "Required Sprint 13 document missing: $relative" }
}

if ($failures.Count -eq 0) {
  $combined = foreach ($relative in $paths) { Get-Content (Join-Path $Root $relative) -Raw }
  $text = $combined -join "`n"

  foreach ($marker in @(
    'PortalSprint13ControlledAuthIntegrationPreparationExists: true',
    'PortalBaselineClosedReviewed: true',
    'Sprint12DockerFullStackReviewed: true',
    'ProductionActivationDecision: NoGo',
    'PortalProductionReady: false',
    'ControlledAuthPreparationAttempted: true',
    'AuthIntegrationContractPrepared: true',
    'ClaimsPermissionsContractPrepared: true',
    'SsoOidcFutureBoundaryPrepared: true',
    'SsoOidcProductionConfigured: false',
    'RealClientIdConfigured: false',
    'RealClientSecretConfigured: false',
    'RealIssuerConfigured: false',
    'RealAuthorityConfigured: false',
    'BrowserTokenStorageDetected: false',
    'TokenStorageInLocalStorageAllowed: false',
    'TokenStorageInSessionStorageAllowed: false',
    'GatewayAuthorizationPolicyPresent: true',
    'SecurityPermissionsFoundationPresent: true',
    'DockerFullStackReadiness: ValidatedNonProductionOnly',
    'FrontendShellBuildable: true',
    'SecretsPresent: false',
    'EnvRealFileCommitted: false',
    'PrivateUrlsPresent: false',
    'RealDataPresent: false',
    'ExternalModuleRuntimeEnabled: false',
    'CrmRuntimeCouplingEnabled: false',
    'FinancialRuntimeCouplingEnabled: false',
    'ControlledAuthReadiness: PreparedNonProductionOnly',
    'NextGate: PortalSprint14SecretProviderPreparation'
  )) {
    if ($text -notmatch [regex]::Escape($marker)) { Add-Failure "Controlled Auth evidence marker missing: $marker" }
  }
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Portal controlled Auth preparation verification OK: contracts, SSO/OIDC boundary, NoGo decision and next gate are documented.'
