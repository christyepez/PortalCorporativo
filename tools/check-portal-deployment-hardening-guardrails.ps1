param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'
$failures = @()

function Add-Failure([string]$Message) {
  $script:failures += $Message
}

$envPath = Join-Path $Root '.env'
if (Test-Path $envPath) {
  Add-Failure 'A real .env file exists in the repository workspace.'
}

$scanRoots = @(
  'docker-compose.yml',
  '.env.example',
  'docs',
  'codex',
  'scripts',
  'tools',
  'backend/api-gateway',
  'backend/building-blocks',
  'backend/workers'
) | ForEach-Object { Join-Path $Root $_ } | Where-Object { Test-Path $_ }

$files = foreach ($scanRoot in $scanRoots) {
  if (Test-Path $scanRoot -PathType Container) {
    Get-ChildItem -Path $scanRoot -Recurse -File -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -notmatch '\\(bin|obj|node_modules|\.git)\\' }
  }
  else {
    Get-Item $scanRoot
  }
}

$certificateFiles = $files | Where-Object { $_.Extension -match '^\.(p12|pfx|pem|key|cer|crt)$' }
if ($certificateFiles) {
  Add-Failure 'Certificate or key files found in deployment hardening paths.'
}

$unsafePatterns = $files |
  Select-String -Pattern 'BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY|BEGIN CERTIFICATE|client_secret\s*[:=]\s*["''][^"'']+|Bearer\s+[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+|https://(?!localhost|github\.com|json\.schemastore\.org)' -ErrorAction SilentlyContinue |
  Where-Object { $_.Line -notmatch 'Select-String -Pattern|notmatch|match|forbidden|unsafePatterns' }
if ($unsafePatterns) {
  Add-Failure 'Potential secret, token, certificate or private URL pattern found.'
}

$composePath = Join-Path $Root 'docker-compose.yml'
if (Test-Path $composePath) {
  $compose = Get-Content $composePath -Raw
  $sqlImages = ([regex]::Matches($compose, 'image:\s*mcr\.microsoft\.com/mssql/server')).Count
  if ($sqlImages -ne 1) { Add-Failure "Expected exactly one SQL Server image; found $sqlImages." }
  if ($compose -match '(?im)^\s*(crm|financiero|financial)[-_a-z0-9]*\s*:') {
    Add-Failure 'Docker Compose defines CRM/Financiero services during Portal P7.'
  }
}

$gatewaySettings = Join-Path $Root 'backend/api-gateway/src/Portal.ApiGateway/appsettings.json'
if (Test-Path $gatewaySettings) {
  $gateway = Get-Content $gatewaySettings -Raw
  if ($gateway -match '"(crm|financiero|financial)"') {
    Add-Failure 'Gateway contains CRM/Financiero/financial route or cluster before activation gate.'
  }
  if ($gateway -notmatch 'AuthorizationPolicy') {
    Add-Failure 'Gateway authorization policy is missing.'
  }
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Portal deployment hardening guardrails OK: no real .env, secrets, certificates, private URLs, consumer runtime coupling, or duplicate SQL Server detected.'
