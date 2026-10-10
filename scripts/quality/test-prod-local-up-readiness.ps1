$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$upPath = Join-Path $root 'scripts/local/prod-local-up.ps1'
$up = Get-Content -LiteralPath $upPath -Raw

$required = @(
    'ReadyTimeoutSeconds',
    'PollSeconds',
    'PORTAL_PROD_LOCAL_UP_READY',
    'prod-local-verify.ps1',
    'IgnoreRestartCount',
    'PORTAL_PROD_LOCAL_UP_COMPLETE'
)
foreach ($marker in $required) {
    if (-not $up.Contains($marker)) { throw "Startup readiness contract missing marker: $marker" }
    Write-Host "PASS startup contract marker $marker"
}

if ($up -notmatch "\$state -in @\('exited','dead'\)") {
    throw 'Startup readiness must fail on terminal container states.'
}
if ($up -notmatch "\$health -notin @\('none','healthy'\)") {
    throw 'Startup readiness must require healthy/none health states.'
}
if ($up.IndexOf('prod-local-verify.ps1') -gt $up.IndexOf("PORTAL_PROD_LOCAL_UP_COMPLETE")) {
    throw 'Runtime verification must happen before startup completion marker.'
}

Write-Host 'PORTAL_PROD_LOCAL_UP_READINESS_GATE_PASS'
