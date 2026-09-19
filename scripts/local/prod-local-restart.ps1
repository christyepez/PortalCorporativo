param(
    [string[]]$EnvFile = @(".env.portal.local"),
    [string[]]$Service = @()
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

$envArgs = @()
foreach ($file in $EnvFile) {
    $path = if ([IO.Path]::IsPathRooted($file)) { $file } else { Join-Path $root $file }
    if (-not (Test-Path -LiteralPath $path)) { throw "Local environment file not found: $path" }
    $envArgs += @('--env-file', $path)
}

$args = @('compose','-p','portalcorporativo') + $envArgs + @(
    '-f',(Join-Path $root 'docker-compose.yml'),
    '-f',(Join-Path $root 'docker-compose.prod-local.yml'),
    'restart'
)
if ($Service.Count -gt 0) { $args += $Service }

& docker @args
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Output 'PORTAL_PROD_LOCAL_RESTART_COMPLETE'
