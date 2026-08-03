param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'

$requiredFiles = @{
  GatewayProgram = 'backend/api-gateway/src/Portal.ApiGateway/Program.cs'
  GatewaySettings = 'backend/api-gateway/src/Portal.ApiGateway/appsettings.json'
  MenuEndpoints = 'backend/menu-api/src/Portal.Menu.Api/MenuEndpoints.cs'
  SecurityEndpoints = 'backend/security-api/src/Portal.Security.Api/SecurityEndpoints.cs'
  AuditProgram = 'backend/audit-api/src/Portal.Audit.Api/Program.cs'
  ConfigurationProgram = 'backend/configuration-api/src/Portal.Configuration.Api/Program.cs'
  NotificationProgram = 'backend/notification-api/src/Portal.Notification.Api/Program.cs'
  IntegrationWorker = 'backend/workers/src/Portal.Integration.Worker/Program.cs'
  Foundation = 'backend/building-blocks/src/Portal.BuildingBlocks/FoundationExtensions.cs'
  P6Roadmap = 'docs/roadmap/portal-sprint-p6-integration-shell-external-modules-baseline.md'
  ExternalContract = 'docs/integration/portal-external-module-onboarding-contract.md'
  GatewayBoundary = 'docs/integration/portal-gateway-external-module-boundary.md'
  SecurityPolicy = 'docs/security/portal-external-module-security-policy.md'
}

foreach ($entry in $requiredFiles.GetEnumerator()) {
  $path = Join-Path $Root $entry.Value
  if (-not (Test-Path $path)) { throw "Required integration shell foundation file missing: $($entry.Value)" }
}

$gatewaySettings = Get-Content (Join-Path $Root $requiredFiles.GatewaySettings) -Raw
if ($gatewaySettings -notmatch 'ReverseProxy') { throw 'Gateway ReverseProxy settings not found.' }
if ($gatewaySettings -notmatch 'AuthorizationPolicy') { throw 'Gateway authorization policy not found.' }
if ($gatewaySettings -match '"(crm|financiero|financial)"') { throw 'External consumer route found in gateway before P6 activation gate.' }
foreach ($cluster in @('security','configuration','menu','audit','notification')) {
  if ($gatewaySettings -notmatch "`"$cluster`"") { throw "Portal gateway cluster missing: $cluster" }
}

$menuText = Get-Content (Join-Path $Root $requiredFiles.MenuEndpoints) -Raw
if ($menuText -notmatch 'RequireAuthorization') { throw 'Menu endpoints are missing authorization.' }

$securityText = Get-Content (Join-Path $Root $requiredFiles.SecurityEndpoints) -Raw
if ($securityText -notmatch 'check-permission') { throw 'Security permission decision endpoint not found.' }

$foundationText = Get-Content (Join-Path $Root $requiredFiles.Foundation) -Raw
if ($foundationText -notmatch 'CorrelationIdMiddleware' -or $foundationText -notmatch 'Seq') { throw 'Correlation or structured logging foundation not found.' }

$p6Text = Get-Content (Join-Path $Root $requiredFiles.P6Roadmap) -Raw
foreach ($decision in @(
  'PortalSprintP6IntegrationShellExternalModulesBaselineExists: true',
  'ExternalModuleOnboardingContractPrepared: true',
  'ProductionActivationDecision: NoGo',
  'ProductiveExternalGatewayRoutesEnabled: false',
  'CrmModuleOnboardingReadiness: ContractPreparedNotRuntimeEnabled',
  'FinancialModuleOnboardingReadiness: ContractPreparedNotRuntimeEnabled'
)) {
  if ($p6Text -notmatch [regex]::Escape($decision)) { throw "P6 decision missing: $decision" }
}

Write-Host 'Portal integration shell foundation verification OK: contracts, gateway boundary, security policy and disabled external runtime status are present.'
