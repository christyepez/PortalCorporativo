param(
    [string[]]$EnvFile = @(".env.portal.local")
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
    'down'
)

& docker @args
exit $LASTEXITCODE
