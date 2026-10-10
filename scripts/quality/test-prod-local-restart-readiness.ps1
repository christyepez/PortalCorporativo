$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$restartPath = Join-Path $root 'scripts/local/prod-local-restart.ps1'
$restart = Get-Content -LiteralPath $restartPath -Raw

$required = @(
    'ReadyTimeoutSeconds',
    'PollSeconds',
    'PORTAL_PROD_LOCAL_RESTART_READY',
    'prod-local-verify.ps1',
    'IgnoreRestartCount',
    'PORTAL_PROD_LOCAL_RESTART_COMPLETE'
)
foreach ($marker in $required) {
    if (-not $restart.Contains($marker)) { throw "Restart readiness contract missing marker: $marker" }
    Write-Host "PASS restart contract marker $marker"
}

if ($restart -notmatch "\$state -in @\('exited','dead'\)") {
    throw 'Restart readiness must fail on terminal container states.'
}
if ($restart -notmatch "\$health -notin @\('none','healthy'\)") {
    throw 'Restart readiness must require healthy/none health states.'
}
if ($restart.IndexOf('prod-local-verify.ps1') -gt $restart.IndexOf("PORTAL_PROD_LOCAL_RESTART_COMPLETE")) {
    throw 'Runtime verification must happen before restart completion marker.'
}

Write-Host 'PORTAL_PROD_LOCAL_RESTART_READINESS_GATE_PASS'
