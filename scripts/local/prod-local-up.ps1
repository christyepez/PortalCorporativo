param(
    [string]$EnvFile = ".env.portal.local",
    [switch]$Build
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$envPath = if ([IO.Path]::IsPathRooted($EnvFile)) { $EnvFile } else { Join-Path $root $EnvFile }

if (-not (Test-Path -LiteralPath $envPath)) {
    throw "Local environment file not found: $envPath"
}

$args = @(
    'compose',
    '-p', 'portalcorporativo',
    '--env-file', $envPath,
    '-f', (Join-Path $root 'docker-compose.yml'),
    '-f', (Join-Path $root 'docker-compose.prod-local.yml'),
    'up', '-d'
)
if ($Build) { $args += '--build' }

& docker @args
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Output 'PORTAL_PROD_LOCAL_UP_COMPLETE'
