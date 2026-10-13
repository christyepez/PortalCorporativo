$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$script = Get-Content -LiteralPath (Join-Path $root 'scripts\local\prod-local-sync-deploy.ps1') -Raw
$verify = Get-Content -LiteralPath (Join-Path $root 'scripts\local\prod-local-verify.ps1') -Raw

$parseErrors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile(
    (Join-Path $root 'scripts\local\prod-local-sync-deploy.ps1'),
    [ref]$null,
    [ref]$parseErrors)
if ($parseErrors.Count -gt 0) {
    throw "PROD-local sync/deploy PowerShell parse failed: $($parseErrors -join '; ')"
}

function Assert-Contains([string]$Text,[string]$Expected,[string]$Message) {
    if (-not $Text.Contains($Expected)) { throw $Message }
}

foreach ($token in @(
    'git status --porcelain',
    'git fetch --prune origin | Out-Host',
    'git pull --ff-only origin main | Out-Host',
    'git rev-parse origin/main',
    "DefaultName 'CRM'",
    "DefaultName 'Financiero'",
    "DefaultName 'AppTTHH'",
    'prod-local-up.ps1',
    '-Build -SkipVerify',
    'prod-local-verify.ps1',
    '-ScanLogs',
    'PORTAL_PROD_LOCAL_SYNC_DEPLOY_PASS',
    'docker port portalcorporativo-portal-web-1 80/tcp',
    'docker port portalcorporativo-api-gateway-1 8080/tcp'
)) {
    Assert-Contains $script $token "Missing PROD-local sync/deploy token: $token"
}

if ($script -match 'git\s+reset\s+--hard|git\s+clean\s+-fd|git\s+checkout\s+-f') {
    throw 'PROD-local sync/deploy must not destroy local changes.'
}

foreach ($token in @(
    'Get-PublishedLocalBaseUrl',
    "portalcorporativo-api-gateway-1' -ContainerPort '8080/tcp'",
    "portalcorporativo-portal-web-1' -ContainerPort '80/tcp'",
    "portalcorporativo-seq-1' -ContainerPort '80/tcp'",
    '-GatewayBaseUrl $gatewayBaseUrl -SeqBaseUrl $seqBaseUrl',
    '-GatewayBaseUrl $gatewayBaseUrl -WebBaseUrl $webBaseUrl'
)) {
    Assert-Contains $verify $token "Missing dynamic PROD-local verification token: $token"
}

Write-Host 'PORTAL_PROD_LOCAL_SYNC_DEPLOY_GATE_PASS'
