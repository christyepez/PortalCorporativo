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
  'backend/api-gateway/src/Portal.ApiGateway/Program.cs',
  'backend/security-api/src/Portal.Security.Api/Program.cs',
  'backend/building-blocks/src/Portal.BuildingBlocks/PortalAuthorization.cs',
  'docs/security/authorization-policy-matrix.md',
  'docs/roadmap/portal-sprint13-controlled-auth-integration-preparation.md',
  'docs/security/portal-controlled-auth-integration-policy.md',
  'docs/security/portal-oidc-sso-future-boundary.md',
  'docs/integration/portal-auth-consumer-contract.md',
  'docs/integration/portal-auth-claims-permissions-contract.md'
)

foreach ($file in $requiredFiles) {
  if (-not (Test-Path (Join-Path $Root $file))) { Add-Failure "Required controlled Auth file missing: $file" }
}

$gateway = Get-Content (Join-Path $Root 'backend/api-gateway/src/Portal.ApiGateway/Program.cs') -Raw
foreach ($marker in @('AddAuthentication', 'JwtBearerDefaults.AuthenticationScheme', 'ValidateIssuer = true', 'ValidateAudience = true', 'ValidateLifetime = true', 'UseAuthentication', 'UseAuthorization')) {
  if ($gateway -notmatch [regex]::Escape($marker)) { Add-Failure "Gateway Auth marker missing: $marker" }
}

$security = Get-Content (Join-Path $Root 'backend/security-api/src/Portal.Security.Api/Program.cs') -Raw
foreach ($marker in @('AddAuthentication', 'AddPortalPermissionAuthorization', 'UseAuthentication', 'UseAuthorization')) {
  if ($security -notmatch [regex]::Escape($marker)) { Add-Failure "Security Auth marker missing: $marker" }
}

$authorization = Get-Content (Join-Path $Root 'backend/building-blocks/src/Portal.BuildingBlocks/PortalAuthorization.cs') -Raw
foreach ($marker in @('ClaimType = "permission"', 'RequireAuthenticatedUser', 'RequireClaim')) {
  if ($authorization -notmatch [regex]::Escape($marker)) { Add-Failure "Permission authorization marker missing: $marker" }
}

$frontendRoot = Join-Path $Root 'frontend/src'
if (Test-Path $frontendRoot) {
  $browserStorage = Get-ChildItem -Path $frontendRoot -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\(node_modules|dist|\.angular)\\' } |
    Select-String -Pattern 'localStorage|sessionStorage' -ErrorAction SilentlyContinue
  if ($browserStorage) { Add-Failure 'Browser token storage marker found in frontend source.' }
}

$compose = Get-Content (Join-Path $Root 'docker-compose.yml') -Raw
if ($compose -match '(?im)^\s{2}(crm|financiero|financial)[-_a-z0-9]*\s*:') {
  Add-Failure 'Docker Compose defines CRM/Financiero services during controlled Auth preparation.'
}

$scanRoots = @(
  'backend/building-blocks',
  'backend/api-gateway',
  'backend/security-api',
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
if ($certFiles) { Add-Failure 'Certificate or key files found in controlled Auth scan paths.' }

$unsafe = $files |
  Select-String -Pattern 'BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY|BEGIN CERTIFICATE|client_secret\s*[:=]\s*["''][^"'']+|Bearer\s+[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+|https://(?!localhost|github\.com|json\.schemastore\.org|aka\.ms)' -ErrorAction SilentlyContinue |
  Where-Object { $_.Line -notmatch 'Select-String -Pattern|notmatch|match|LOCAL_ONLY_PLACEHOLDER|PLACEHOLDER|NoGo|No real|Bearer\\s|client_secret\\s|BEGIN CERTIFICATE' }
if ($unsafe) { Add-Failure 'Potential secret, token, certificate or private URL pattern found.' }

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Portal controlled Auth guardrails OK: backend authorization present, frontend token storage absent, no real SSO/OIDC secrets and no consumer runtime coupling detected.'
