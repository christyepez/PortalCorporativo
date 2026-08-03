param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'
$failures = @()

function Add-Failure([string]$Message) {
  $script:failures += $Message
}

$envPath = Join-Path $Root '.env'
if (Test-Path $envPath) { Add-Failure 'A real .env file exists in the repository workspace.' }

Push-Location $Root
try {
  $trackedEnv = git ls-files .env
  if ($trackedEnv) { Add-Failure '.env is tracked by git.' }
}
finally {
  Pop-Location
}

$requiredFiles = @(
  'backend/building-blocks/src/Portal.BuildingBlocks/FoundationExtensions.cs',
  'scripts/smoke/sprint1-smoke.ps1',
  'tools/check-portal-health.ps1'
)

foreach ($file in $requiredFiles) {
  if (-not (Test-Path (Join-Path $Root $file))) { Add-Failure "Required health/smoke file missing: $file" }
}

$foundation = Get-Content (Join-Path $Root 'backend/building-blocks/src/Portal.BuildingBlocks/FoundationExtensions.cs') -Raw
foreach ($route in @('"/health"', '"/health/live"', '"/health/ready"')) {
  if ($foundation -notmatch [regex]::Escape($route)) { Add-Failure "Foundation health route missing: $route" }
}

$smoke = Get-Content (Join-Path $Root 'scripts/smoke/sprint1-smoke.ps1') -Raw
foreach ($text in @('Portal stack already running', 'StartedByScript', 'AuthorizationExpected', 'docker compose down', '/health/live', '/health/ready')) {
  if ($smoke -notmatch [regex]::Escape($text)) { Add-Failure "Smoke hardening marker missing: $text" }
}

$scanRoots = @(
  'backend/building-blocks',
  'backend/api-gateway',
  'scripts/smoke',
  'tools',
  'docs/roadmap',
  'docs/operations',
  'docs/architecture',
  'docs/security',
  'frontend/src',
  'docker-compose.yml',
  '.env.example'
) | ForEach-Object { Join-Path $Root $_ } | Where-Object { Test-Path $_ }

$files = foreach ($scanRoot in $scanRoots) {
  if (Test-Path $scanRoot -PathType Container) {
    Get-ChildItem -Path $scanRoot -Recurse -File -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -notmatch '\\(bin|obj|node_modules|dist|\.angular|\.git)\\' -and $_.Name -notin @('package-lock.json') }
  }
  else {
    Get-Item $scanRoot
  }
}

$certFiles = $files | Where-Object { $_.Extension -match '^\.(p12|pfx|pem|key|cer|crt)$' }
if ($certFiles) { Add-Failure 'Certificate or key files found in health/smoke paths.' }

$unsafe = $files |
  Select-String -Pattern 'BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY|BEGIN CERTIFICATE|client_secret\s*[:=]\s*["''][^"'']+|Bearer\s+[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+|https://(?!localhost|github\.com|json\.schemastore\.org|aka\.ms)' -ErrorAction SilentlyContinue |
  Where-Object { $_.Line -notmatch 'Select-String -Pattern|notmatch|match|LOCAL_ONLY_PLACEHOLDER|PLACEHOLDER|NoGo|No real|Bearer\\s' }
if ($unsafe) { Add-Failure 'Potential secret, token, certificate or private URL pattern found.' }

$compose = Get-Content (Join-Path $Root 'docker-compose.yml') -Raw
if (($compose | Select-String -Pattern 'image:\s*mcr\.microsoft\.com/mssql/server' -AllMatches).Matches.Count -ne 1) {
  Add-Failure 'Expected exactly one SQL Server image in Portal Compose.'
}
if ($compose -match '(?im)^\s*(crm|financiero|financial)[-_a-z0-9]*\s*:') {
  Add-Failure 'Docker Compose defines CRM/Financiero services during Portal Sprint 11.'
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Portal health/smoke guardrails OK: health routes, idempotent smoke markers, no secrets/private URLs, and no consumer runtime coupling detected.'
