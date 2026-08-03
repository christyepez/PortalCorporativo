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
  '.env.example',
  'docker-compose.yml',
  'docs/roadmap/portal-sprint14-secret-provider-preparation.md',
  'docs/security/portal-secret-provider-policy.md',
  'docs/security/portal-secret-naming-convention.md',
  'docs/security/portal-secret-lifecycle.md',
  'docs/integration/portal-secret-provider-contract.md',
  'docs/operations/portal-secret-provider-placeholder-evidence.md'
)

foreach ($file in $requiredFiles) {
  if (-not (Test-Path (Join-Path $Root $file))) { Add-Failure "Required Secret Provider file missing: $file" }
}

$envExample = Get-Content (Join-Path $Root '.env.example') -Raw
foreach ($placeholder in @('CHANGE_ME', 'SQLSERVER_SA_PASSWORD', 'REDIS_PASSWORD', 'JWT_SECRET', 'MINIO_ROOT_PASSWORD')) {
  if ($envExample -notmatch [regex]::Escape($placeholder)) { Add-Failure ".env.example placeholder marker missing: $placeholder" }
}

$compose = Get-Content (Join-Path $Root 'docker-compose.yml') -Raw
foreach ($provider in @('AzureKeyVault', 'AWS_SECRET', 'GCP_SECRET', 'HashiCorp', 'Vault__', 'KeyVault__')) {
  if ($compose -match [regex]::Escape($provider)) { Add-Failure "Real or provider-specific secret configuration found in compose: $provider" }
}
if ($compose -match '(?im)^\s{2}(crm|financiero|financial)[-_a-z0-9]*\s*:') {
  Add-Failure 'Docker Compose defines CRM/Financiero services during Secret Provider preparation.'
}

$frontendRoot = Join-Path $Root 'frontend/src'
if (Test-Path $frontendRoot) {
  $browserStorage = Get-ChildItem -Path $frontendRoot -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\(node_modules|dist|\.angular)\\' } |
    Select-String -Pattern 'localStorage|sessionStorage' -ErrorAction SilentlyContinue
  if ($browserStorage) { Add-Failure 'Browser token storage marker found in frontend source.' }
}

$scanRoots = @(
  'backend/building-blocks',
  'backend/api-gateway',
  'backend/security-api',
  'backend/configuration-api',
  'backend/notification-api',
  'frontend/src',
  'docs/roadmap',
  'docs/security',
  'docs/integration',
  'docs/architecture',
  'docs/operations',
  'tools',
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
if ($certFiles) { Add-Failure 'Certificate or key files found in Secret Provider scan paths.' }

$unsafe = $files |
  Select-String -Pattern 'BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY|BEGIN CERTIFICATE|client_secret\s*[:=]\s*["''][^"'']+|Bearer\s+[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+|https://(?!localhost|github\.com|json\.schemastore\.org|aka\.ms)' -ErrorAction SilentlyContinue |
  Where-Object { $_.Line -notmatch 'Select-String -Pattern|notmatch|match|LOCAL_ONLY_PLACEHOLDER|PLACEHOLDER|CHANGE_ME|NoGo|No real|Bearer\\s|client_secret\\s|BEGIN CERTIFICATE' }
if ($unsafe) { Add-Failure 'Potential real secret, token, certificate or private URL pattern found.' }

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Portal Secret Provider guardrails OK: placeholders only, no real provider, no committed secrets, no browser token storage and no consumer runtime coupling detected.'
