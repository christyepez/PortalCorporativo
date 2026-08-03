param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'

$menuProgram = Join-Path $Root 'backend/menu-api/src/Portal.Menu.Api/Program.cs'
$menuEndpoints = Join-Path $Root 'backend/menu-api/src/Portal.Menu.Api/MenuEndpoints.cs'
$menuPersistence = Join-Path $Root 'backend/menu-api/src/Portal.Menu.Infrastructure/MenuPersistence.cs'
$securityEndpoints = Join-Path $Root 'backend/security-api/src/Portal.Security.Api/SecurityEndpoints.cs'
$authorization = Join-Path $Root 'backend/building-blocks/src/Portal.BuildingBlocks/PortalAuthorization.cs'
$gatewaySettings = Join-Path $Root 'backend/api-gateway/src/Portal.ApiGateway/appsettings.json'

foreach ($path in @($menuProgram, $menuEndpoints, $menuPersistence, $securityEndpoints, $authorization, $gatewaySettings)) {
  if (-not (Test-Path $path)) { throw "Required Menu/Permissions foundation file missing: $path" }
}

$menuProgramText = Get-Content $menuProgram -Raw
$menuEndpointsText = Get-Content $menuEndpoints -Raw
$menuPersistenceText = Get-Content $menuPersistence -Raw
$securityEndpointsText = Get-Content $securityEndpoints -Raw
$authorizationText = Get-Content $authorization -Raw
$gatewaySettingsText = Get-Content $gatewaySettings -Raw

if ($menuProgramText -notmatch 'AddPortalPermissionAuthorization') { throw 'Menu API permission authorization not found.' }
if ($menuEndpointsText -notmatch 'RequireAuthorization\(PortalPermissions\.Menu') { throw 'Menu endpoints are not protected by Portal menu permissions.' }
if ($menuPersistenceText -notmatch 'SecurityPermissionChecker') { throw 'Menu visibility does not reference Security permission checking.' }
if ($securityEndpointsText -notmatch 'check-permission') { throw 'Security permission decision endpoint not found.' }
if ($authorizationText -notmatch 'MenuManage' -or $authorizationText -notmatch 'MenuRead') { throw 'Menu permission policies not found in building blocks.' }
if ($gatewaySettingsText -notmatch '"menu"\s*:\s*\{' -or $gatewaySettingsText -notmatch '"AuthorizationPolicy"\s*:\s*"default"') { throw 'Gateway menu route authorization policy not found.' }

Write-Host 'Portal Menu/Permissions foundation verification OK: Menu API, Security permission decisions, policies, and Gateway authorization are present.'
