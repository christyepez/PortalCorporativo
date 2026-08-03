param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'
$failures = @()

function Add-Failure([string]$Message) {
  $script:failures += $Message
}

$runtimeRoots = @('backend', 'frontend', 'docker-compose.yml', '.env.example') |
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

$browserStorage = $runtimeFiles | Select-String -Pattern 'localStorage|sessionStorage' -ErrorAction SilentlyContinue
if ($browserStorage) {
  Add-Failure 'Browser-readable token storage references were found in runtime files.'
}

$forbidden = $runtimeFiles | Select-String -Pattern 'client_secret|BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY|BEGIN CERTIFICATE|https://(?!localhost|github\.com|json\.schemastore\.org)' -ErrorAction SilentlyContinue
if ($forbidden) {
  Add-Failure 'Potential production Auth secret/certificate/private URL patterns were found in runtime files.'
}

$envPath = Join-Path $Root '.env'
if (Test-Path $envPath) {
  Add-Failure 'A real .env file exists in the repository workspace.'
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Portal Auth guardrails OK: no browser token storage, client secrets, certificates, private URLs, or real .env detected.'
