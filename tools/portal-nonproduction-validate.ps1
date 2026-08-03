param(
  [string]$BaseUrl = 'http://localhost:8082',
  [int]$GatewayPort = 8082,
  [int]$SqlPort = 21433,
  [Parameter(Mandatory = $true)]
  [string]$JwtSecret
)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Push-Location $Root
try {
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-health.ps1 -BaseUrl $BaseUrl
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts\smoke\sprint1-smoke.ps1 -JwtSecret $JwtSecret -GatewayPort $GatewayPort -SqlPort $SqlPort
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\verify-portal-controlled-nonproduction-deployment-package.ps1
  Write-Host 'Portal controlled NonProduction validation completed. ProductionActivationDecision: NoGo.'
}
finally {
  Pop-Location
}
