param(
  [string]$EnvFile = '.env.example',
  [int]$Tail = 150,
  [string]$Service = ''
)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Push-Location $Root
try {
  if ($EnvFile -notmatch '(^|[\\/])(\.env\.example|\.env)$') {
    throw 'Only .env.example or a local .env file are allowed for controlled NonProduction logs.'
  }

  if ($Service) {
    docker compose --env-file $EnvFile logs --tail $Tail $Service
  }
  else {
    docker compose --env-file $EnvFile logs --tail $Tail
  }
}
finally {
  Pop-Location
}
