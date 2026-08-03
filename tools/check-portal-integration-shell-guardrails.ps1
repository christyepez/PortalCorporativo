param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'
$failures = @()

function Add-Failure([string]$Message) {
  $script:failures += $Message
}

$runtimeRoots = @(
  'backend/api-gateway',
  'backend/menu-api',
  'backend/security-api',
  'backend/audit-api',
  'backend/configuration-api',
  'backend/notification-api',
  'backend/workers',
  'backend/building-blocks',
  'frontend',
  'docker-compose.yml',
  '.env.example'
) | ForEach-Object { Join-Path $Root $_ } | Where-Object { Test-Path $_ }

$runtimeFiles = foreach ($runtimeRoot in $runtimeRoots) {
  if (Test-Path $runtimeRoot -PathType Container) {
    Get-ChildItem -Path $runtimeRoot -Recurse -File -ErrorAction SilentlyContinue |
      Where-Object {
        $_.FullName -notmatch '\\(bin|obj|node_modules|dist|\.angular|\.git)\\' -and
        $_.Name -notin @('package-lock.json')
      }
  }
  else {
    Get-Item $runtimeRoot
  }
}

$envPath = Join-Path $Root '.env'
if (Test-Path $envPath) {
  Add-Failure 'A real .env file exists in the repository workspace.'
}

$certificateFiles = $runtimeFiles | Where-Object { $_.Extension -match '^\.(p12|pfx|pem|key|cer|crt)$' }
if ($certificateFiles) {
  Add-Failure 'Certificate or key files found in integration shell runtime paths.'
}

$secretMatches = $runtimeFiles | Select-String -Pattern 'BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY|BEGIN CERTIFICATE|client_secret\s*[:=]\s*["''][^"'']+|Bearer\s+[A-Za-z0-9_\-\.]+' -ErrorAction SilentlyContinue
if ($secretMatches) {
  Add-Failure 'Potential secret, certificate or token found in integration shell runtime files.'
}

$privateUrlMatches = $runtimeFiles | Select-String -Pattern 'https://(?!localhost|github\.com|json\.schemastore\.org)|http://(?!localhost|127\.0\.0\.1|seq:|sqlserver|security-api|configuration-api|menu-api|audit-api|notification-api|catalog-api|content-api|integration-api|reporting-api)' -ErrorAction SilentlyContinue
if ($privateUrlMatches) {
  Add-Failure 'Potential private or productive URL found in integration shell runtime files.'
}

$gatewaySettings = Join-Path $Root 'backend/api-gateway/src/Portal.ApiGateway/appsettings.json'
if (Test-Path $gatewaySettings) {
  $gatewayText = Get-Content $gatewaySettings -Raw
  if ($gatewayText -match '"(crm|financiero|financial)"') {
    Add-Failure 'Gateway contains CRM/Financiero/financial route or cluster before activation gate.'
  }
  if ($gatewayText -match 'AuthorizationPolicy' -and $gatewayText -notmatch '"AuthorizationPolicy"\s*:\s*"default"') {
    Add-Failure 'Gateway authorization policy baseline is not consistently default or stricter.'
  }
}

$composePath = Join-Path $Root 'docker-compose.yml'
if (Test-Path $composePath) {
  $composeText = Get-Content $composePath -Raw
  if ($composeText -match '(?im)^\s*(crm|financiero|financial)[-_a-z0-9]*\s*:') {
    Add-Failure 'Docker Compose defines CRM/Financiero services in Portal P6.'
  }
  if (($composeText | Select-String -Pattern 'image:\s*mcr\.microsoft\.com/mssql/server' -AllMatches).Matches.Count -gt 1) {
    Add-Failure 'Docker Compose defines more than one SQL Server image.'
  }
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Portal integration shell guardrails OK: no external module runtime routes, private URLs, real secrets, consumer services, or duplicate SQL Server detected.'
