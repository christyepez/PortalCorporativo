param(
    [string[]]$EnvFile = @('.env.portal.local'),
    [Parameter(Mandatory=$true)][string]$Output
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$envArgs = @()
foreach ($file in $EnvFile) {
    $path = if ([IO.Path]::IsPathRooted($file)) { $file } else { Join-Path $root $file }
    if (-not (Test-Path -LiteralPath $path)) { throw "Local environment file not found: $path" }
    $envArgs += @('--env-file', $path)
}

$composeArgs = @('compose','-p','portalcorporativo') + $envArgs + @(
    '-f',(Join-Path $root 'docker-compose.yml'),
    '-f',(Join-Path $root 'docker-compose.prod-local.yml')
)
$ids = @(& docker @($composeArgs + @('ps','-q')))
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
if ($ids.Count -eq 0) { throw 'No portalcorporativo containers are running.' }

$snapshot = [ordered]@{}
foreach ($id in $ids) {
    $row = & docker inspect --format '{{.Name}}|{{.RestartCount}}' $id
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    $parts = $row -split '\|'
    $name = $parts[0].TrimStart('/')
    $count = [int]$parts[1]
    $snapshot[$name] = $count
    Write-Output "CHECK restartBaseline $name=$count"
}

$outputPath = if ([IO.Path]::IsPathRooted($Output)) { $Output } else { Join-Path $root $Output }
$parent = Split-Path -Parent $outputPath
if (-not [string]::IsNullOrWhiteSpace($parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
$snapshot | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $outputPath -Encoding UTF8
Write-Output "PORTAL_PROD_LOCAL_RESTART_SNAPSHOT_CREATED $outputPath"
