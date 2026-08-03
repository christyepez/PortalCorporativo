param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'
$required = @(
  'backend/PortalCorporativo.sln',
  'docker-compose.yml',
  '.env.example',
  'backend/api-gateway/src/Portal.ApiGateway/Portal.ApiGateway.csproj',
  'backend/security-api/src/Portal.Security.Api/Portal.Security.Api.csproj',
  'backend/configuration-api/src/Portal.Configuration.Api/Portal.Configuration.Api.csproj',
  'backend/menu-api/src/Portal.Menu.Api/Portal.Menu.Api.csproj',
  'backend/audit-api/src/Portal.Audit.Api/Portal.Audit.Api.csproj',
  'backend/notification-api/src/Portal.Notification.Api/Portal.Notification.Api.csproj',
  'backend/workers/src/Portal.Notification.Worker/Portal.Notification.Worker.csproj',
  'backend/workers/src/Portal.Integration.Worker/Portal.Integration.Worker.csproj'
)

$missing = @()
foreach ($item in $required) {
  $path = Join-Path $Root $item
  if (-not (Test-Path $path)) { $missing += $item }
}

if ($missing.Count -gt 0) {
  $missing | ForEach-Object { Write-Error "Missing required foundation item: $_" }
  exit 1
}

$compose = Get-Content (Join-Path $Root 'docker-compose.yml') -Raw
$sqlServices = ([regex]::Matches($compose, '(?m)^\s{2}sqlserver:\s*$')).Count
if ($sqlServices -ne 1) {
  throw "Expected exactly one sqlserver service in docker-compose.yml; found $sqlServices."
}

Write-Host 'Portal foundation verification OK.'
