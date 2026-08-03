param([string]$EnvFile = '.env.example')
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Push-Location $Root
try {
  if ($EnvFile -notmatch '(^|[\\/])(\.env\.example|\.env)$') {
    throw 'Only .env.example or a local .env file are allowed for controlled NonProduction stop.'
  }

  docker compose --env-file $EnvFile down
  $remaining = docker ps --filter name=portal-corporativo --format '{{.Names}} {{.Status}}'
  if ($remaining) {
    throw "Portal containers still running: $remaining"
  }
  Write-Host 'Portal controlled NonProduction stack stopped. StackStoppedAfterValidation: true.'
}
finally {
  Pop-Location
}
