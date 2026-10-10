param(
    [string[]]$EnvFile = @(".env.portal.local"),
    [string[]]$Service = @(),
    [int]$ReadyTimeoutSeconds = 180,
    [int]$PollSeconds = 3,
    [switch]$SkipVerify
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

if ($ReadyTimeoutSeconds -lt 1) { throw 'ReadyTimeoutSeconds must be greater than zero.' }
if ($PollSeconds -lt 1) { throw 'PollSeconds must be greater than zero.' }

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

$restartArgs = $composeArgs + @('restart')
if ($Service.Count -gt 0) { $restartArgs += $Service }

& docker @restartArgs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$deadline = (Get-Date).AddSeconds($ReadyTimeoutSeconds)
do {
    $psArgs = $composeArgs + @('ps','-q')
    if ($Service.Count -gt 0) { $psArgs += $Service }
    $ids = @(& docker @psArgs)
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    if ($ids.Count -eq 0) { throw 'No matching portalcorporativo containers were found after restart.' }

    $allReady = $true
    $states = @()
    foreach ($id in $ids) {
        $row = & docker inspect --format '{{.Name}}|{{.State.Status}}|{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' $id
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        $parts = $row -split '\|'
        $name = $parts[0].TrimStart('/')
        $state = $parts[1]
        $health = $parts[2]
        $states += "$name state=$state health=$health"

        if ($state -in @('exited','dead')) {
            throw "Restart recovery failed: $name entered terminal state '$state'."
        }
        if ($state -ne 'running' -or $health -notin @('none','healthy')) {
            $allReady = $false
        }
    }

    if ($allReady) { break }
    if ((Get-Date) -ge $deadline) {
        throw "Restart readiness timed out after $ReadyTimeoutSeconds seconds: $($states -join '; ')"
    }
    Start-Sleep -Seconds $PollSeconds
} while ($true)

$states | ForEach-Object { Write-Host "READY $_" }
Write-Output 'PORTAL_PROD_LOCAL_RESTART_READY'

if (-not $SkipVerify) {
    & (Join-Path $PSScriptRoot 'prod-local-verify.ps1') -EnvFile $EnvFile -IgnoreRestartCount
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Output 'PORTAL_PROD_LOCAL_RESTART_COMPLETE'
