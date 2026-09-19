param(
    [string[]]$EnvFile = @(".env.portal.local"),
    [switch]$Build
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

$envArgs = @()
foreach ($file in $EnvFile) {
    $path = if ([IO.Path]::IsPathRooted($file)) { $file } else { Join-Path $root $file }
    if (-not (Test-Path -LiteralPath $path)) { throw "Local environment file not found: $path" }
    $envArgs += @('--env-file', $path)
}

$args = @('compose', '-p', 'portalcorporativo') + $envArgs + @(
    '-f', (Join-Path $root 'docker-compose.yml'),
    '-f', (Join-Path $root 'docker-compose.prod-local.yml'),
    'up', '-d'
)
if ($Build) { $args += '--build' }

& docker @args
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Output 'PORTAL_PROD_LOCAL_UP_COMPLETE'
