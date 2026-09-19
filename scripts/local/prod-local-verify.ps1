param(
    [string[]]$EnvFile = @(".env.portal.local"),
    [switch]$SkipSmoke,
    [switch]$ScanLogs,
    [int]$RecentMinutes = 15
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

$envPaths = @()
foreach ($file in $EnvFile) {
    $path = if ([IO.Path]::IsPathRooted($file)) { $file } else { Join-Path $root $file }
    if (-not (Test-Path -LiteralPath $path)) { throw "Local environment file not found: $path" }
    $envPaths += $path
}

$envArgs = @()
foreach ($path in $envPaths) { $envArgs += @('--env-file', $path) }
$composeArgs = @('compose','-p','portalcorporativo') + $envArgs + @(
    '-f',(Join-Path $root 'docker-compose.yml'),
    '-f',(Join-Path $root 'docker-compose.prod-local.yml')
)

$ids = @(& docker @composeArgs ps -q)
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
if ($ids.Count -eq 0) { throw 'No portalcorporativo containers are running.' }

$failures = @()
$rows = @(& docker inspect --format '{{.Name}}|{{.State.Status}}|{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}|{{.RestartCount}}' @ids)
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

foreach ($row in $rows) {
    $parts = $row -split '\|'
    $name = $parts[0].TrimStart('/')
    $state = $parts[1]
    $health = $parts[2]
    $restartCount = [int]$parts[3]
    Write-Host ("CHECK {0} state={1} health={2} restarts={3}" -f $name,$state,$health,$restartCount)
    if ($state -ne 'running') { $failures += "$name state=$state" }
    if ($health -notin @('none','healthy')) { $failures += "$name health=$health" }
    if ($restartCount -ne 0) { $failures += "$name restartCount=$restartCount" }
}

if ($ScanLogs) {
    $since = "{0}m" -f $RecentMinutes
    foreach ($id in $ids) {
        $name = (& docker inspect --format '{{.Name}}' $id).TrimStart('/')
        $hits = @(& docker logs --since $since --tail 100 $id 2>&1 | Select-String -Pattern '(?i)(Unhandled exception|\bFATAL\b|\bCRITICAL\b)')
        if ($hits.Count -gt 0) { $failures += "$name recentCriticalLogs=$($hits.Count)" }
    }
}
if (-not $SkipSmoke) {
    foreach ($path in $envPaths) {
        Get-Content -LiteralPath $path | ForEach-Object {
            if ($_ -match '^[#\s]*$') { return }
            $idx = $_.IndexOf('=')
            if ($idx -le 0) { return }
            [Environment]::SetEnvironmentVariable($_.Substring(0,$idx).Trim(),$_.Substring($idx+1).Trim(),'Process')
        }
    }
    & (Join-Path $root 'scripts\smoke\prod-local-smoke.ps1')
    if ($LASTEXITCODE -ne 0) { $failures += 'authenticatedSmoke=failed' }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Host "FAIL $_" }
    throw "PROD-local verification failed with $($failures.Count) issue(s)."
}

Write-Host 'PORTAL_PROD_LOCAL_VERIFY_PASS'
