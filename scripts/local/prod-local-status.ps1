$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$envPath = Join-Path $root '.env.portal.local'

if (-not (Test-Path -LiteralPath $envPath)) {
    throw "Local environment file not found: $envPath"
}

& docker compose -p portalcorporativo --env-file $envPath -f (Join-Path $root 'docker-compose.yml') -f (Join-Path $root 'docker-compose.prod-local.yml') ps
exit $LASTEXITCODE
