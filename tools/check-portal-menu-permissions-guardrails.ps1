param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'
$failures = @()

function Add-Failure([string]$Message) {
  $script:failures += $Message
}

$runtimeRoots = @('backend/menu-api', 'backend/security-api', 'backend/api-gateway', 'backend/building-blocks', 'docker-compose.yml', '.env.example') |
  ForEach-Object { Join-Path $Root $_ } |
  Where-Object { Test-Path $_ }

$runtimeFiles = foreach ($runtimeRoot in $runtimeRoots) {
  if (Test-Path $runtimeRoot -PathType Container) {
    Get-ChildItem -Path $runtimeRoot -Recurse -File -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -notmatch '\\(bin|obj|node_modules|\.git)\\' }
  }
  else {
    Get-Item $runtimeRoot
  }
}

$privateUrlMatches = $runtimeFiles | Select-String -Pattern 'https://(?!localhost|github\.com|json\.schemastore\.org)|crm\.internal|financiero\.internal|financial\.internal' -ErrorAction SilentlyContinue
if ($privateUrlMatches) {
  Add-Failure 'Potential private/productive route URL found in menu/security/gateway runtime files.'
}

$externalNavigationSeeds = $runtimeFiles | Select-String -Pattern '"/crm|"/financial|"/financiero|crm\.|financial\.|financiero\.' -ErrorAction SilentlyContinue
if ($externalNavigationSeeds) {
  Add-Failure 'External CRM/Financial productive navigation or permission seeds appear in runtime files.'
}

$envPath = Join-Path $Root '.env'
if (Test-Path $envPath) {
  Add-Failure 'A real .env file exists in the repository workspace.'
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Portal Menu/Permissions guardrails OK: no private routes, real .env, or productive external navigation seeds detected.'
