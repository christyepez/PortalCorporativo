param(
  [string]$EnvFile = '.env.example',
  [switch]$SkipBuild
)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Push-Location $Root
try {
  if ($EnvFile -notmatch '(^|[\\/])(\.env\.example|\.env)$') {
    throw 'Only .env.example or a local .env file are allowed for controlled NonProduction deployment.'
  }

  powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-controlled-nonproduction-deployment-guardrails.ps1
  docker compose --env-file $EnvFile config | Out-Null
  if (-not $SkipBuild) {
    dotnet build backend\PortalCorporativo.sln
  }
  docker compose --env-file $EnvFile up -d --build
  Write-Host 'Portal controlled NonProduction deploy completed. ProductionActivationDecision: NoGo.'
}
finally {
  Pop-Location
}
