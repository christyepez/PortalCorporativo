param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'
Push-Location $Root
try {
  if (-not (Test-Path '.env.example')) { throw '.env.example is required.' }
  if (-not (Test-Path 'docker-compose.yml')) { throw 'docker-compose.yml is required.' }
  if (-not (Test-Path 'backend/PortalCorporativo.sln')) { throw 'backend/PortalCorporativo.sln is required.' }

  docker compose --env-file .env.example config | Out-Null

  $frontendPackage = Get-ChildItem -Path 'frontend' -Filter package.json -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $frontendPackage) {
    Write-Host 'FrontendBuildValidated=false; FrontendBuildBlockedReason=No buildable frontend package manifest found.'
  }

  Write-Host 'Portal local preflight OK.'
}
finally {
  Pop-Location
}
