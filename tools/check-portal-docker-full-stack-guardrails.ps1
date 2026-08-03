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
  'docker-compose.yml',
  '.env.example',
  'backend/PortalCorporativo.sln',
  'backend/building-blocks/src/Portal.BuildingBlocks/FoundationExtensions.cs',
  'scripts/smoke/sprint1-smoke.ps1',
  'tools/check-portal-health.ps1',
  'docs/roadmap/portal-sprint12-docker-full-stack-runtime-validation.md',
  'docs/operations/portal-docker-full-stack-evidence.md'
)

foreach ($file in $requiredFiles) {
  if (-not (Test-Path (Join-Path $Root $file))) { Add-Failure "Required Sprint 12 file missing: $file" }
}

$composePath = Join-Path $Root 'docker-compose.yml'
$compose = Get-Content $composePath -Raw

foreach ($service in @('sqlserver', 'seq', 'security-api', 'configuration-api', 'menu-api', 'audit-api', 'notification-api', 'notification-worker', 'api-gateway')) {
  if ($compose -notmatch "(?m)^\s{2}$([regex]::Escape($service)):\s*$") { Add-Failure "Required Docker service missing: $service" }
}

if (($compose | Select-String -Pattern 'image:\s*mcr\.microsoft\.com/mssql/server' -AllMatches).Matches.Count -ne 1) {
  Add-Failure 'Expected exactly one SQL Server container definition in Portal Compose.'
}

foreach ($portVariable in @('SQLSERVER_PORT', 'REDIS_PORT', 'MINIO_API_PORT', 'MINIO_CONSOLE_PORT', 'SEQ_PORT', 'API_GATEWAY_PORT')) {
  if ($compose -notmatch "\$\{$portVariable") { Add-Failure "Compose port is not parameterized with $portVariable." }
}

if ($compose -match '(?im)^\s{2}(crm|financiero|financial)[-_a-z0-9]*\s*:') {
  Add-Failure 'Docker Compose defines CRM/Financiero services in Portal runtime.'
}

$foundation = Get-Content (Join-Path $Root 'backend/building-blocks/src/Portal.BuildingBlocks/FoundationExtensions.cs') -Raw
foreach ($route in @('"/health"', '"/health/live"', '"/health/ready"')) {
  if ($foundation -notmatch [regex]::Escape($route)) { Add-Failure "Foundation health route missing: $route" }
}

$smoke = Get-Content (Join-Path $Root 'scripts/smoke/sprint1-smoke.ps1') -Raw
foreach ($marker in @('Portal stack already running', 'StartedByScript', 'AuthorizationExpected', 'docker compose down', '/health', '/health/live', '/health/ready')) {
  if ($smoke -notmatch [regex]::Escape($marker)) { Add-Failure "Smoke marker missing: $marker" }
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
if ($certFiles) { Add-Failure 'Certificate or key files found in Sprint 12 scan paths.' }

$unsafe = $files |
  Select-String -Pattern 'BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY|BEGIN CERTIFICATE|client_secret\s*[:=]\s*["''][^"'']+|Bearer\s+[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+|https://(?!localhost|github\.com|json\.schemastore\.org|aka\.ms)' -ErrorAction SilentlyContinue |
  Where-Object { $_.Line -notmatch 'Select-String -Pattern|notmatch|match|LOCAL_ONLY_PLACEHOLDER|PLACEHOLDER|NoGo|No real|Bearer\\s|AuthorizationExpected' }
if ($unsafe) { Add-Failure 'Potential secret, token, certificate or private URL pattern found.' }

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Portal Docker full stack guardrails OK: required services, health contract, parametrized ports, no consumer runtime coupling and no secrets detected.'
