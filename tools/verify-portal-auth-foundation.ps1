param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'

$securityProgram = Join-Path $Root 'backend/security-api/src/Portal.Security.Api/Program.cs'
$gatewayProgram = Join-Path $Root 'backend/api-gateway/src/Portal.ApiGateway/Program.cs'
$authorization = Join-Path $Root 'backend/building-blocks/src/Portal.BuildingBlocks/PortalAuthorization.cs'
$gatewaySettings = Join-Path $Root 'backend/api-gateway/src/Portal.ApiGateway/appsettings.json'

foreach ($path in @($securityProgram, $gatewayProgram, $authorization, $gatewaySettings)) {
  if (-not (Test-Path $path)) { throw "Required Auth foundation file missing: $path" }
}

$securityText = Get-Content $securityProgram -Raw
$gatewayText = Get-Content $gatewayProgram -Raw
$authorizationText = Get-Content $authorization -Raw
$gatewaySettingsText = Get-Content $gatewaySettings -Raw

if ($securityText -notmatch 'JwtBearerDefaults\.AuthenticationScheme') { throw 'Security API JWT bearer foundation not found.' }
if ($securityText -notmatch 'AddPortalPermissionAuthorization') { throw 'Security API permission authorization not found.' }
if ($gatewayText -notmatch 'JwtBearerDefaults\.AuthenticationScheme') { throw 'Gateway JWT bearer foundation not found.' }
if ($gatewayText -notmatch 'AddReverseProxy') { throw 'Gateway YARP reverse proxy foundation not found.' }
if ($authorizationText -notmatch 'RequireAuthenticatedUser\(\)\.RequireClaim') { throw 'Portal permission policy foundation not found.' }
if ($gatewaySettingsText -notmatch '"AuthorizationPolicy"\s*:\s*"default"') { throw 'Gateway route authorization policy not found.' }
if ($securityText + $gatewayText + $gatewaySettingsText -match 'OpenIdConnect|client_secret|Authority"\s*:\s*"https://') {
  throw 'Production OIDC/client secret configuration appears to be present.'
}

Write-Host 'Portal Auth foundation verification OK: JWT bearer, permission policies, and Gateway authorization are present; production OIDC is not configured.'
