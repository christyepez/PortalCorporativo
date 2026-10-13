param(
    [string]$PortalRepo = "",
    [string]$CrmRepo = "",
    [string]$FinancieroRepo = "",
    [string]$HrRepo = "",
    [string[]]$EnvFile = @(".env.portal.local"),
    [switch]$SkipBuild,
    [switch]$SkipVerify
)

$ErrorActionPreference = 'Stop'

function Resolve-RepoPath {
    param(
        [string]$ExplicitPath,
        [string]$DefaultName,
        [string]$PortalPath
    )

    if (-not [string]::IsNullOrWhiteSpace($ExplicitPath)) {
        return (Resolve-Path -LiteralPath $ExplicitPath).Path
    }

    $parent = Split-Path -Parent $PortalPath
    $candidate = Join-Path $parent $DefaultName
    if (-not (Test-Path -LiteralPath $candidate)) {
        throw "Repository '$DefaultName' was not found at '$candidate'. Pass an explicit path."
    }

    return (Resolve-Path -LiteralPath $candidate).Path
}

function Assert-CleanMainAndSync {
    param(
        [string]$Name,
        [string]$Path
    )

    Write-Host "SYNC $Name -> $Path"
    Push-Location $Path
    try {
        $status = @(git status --porcelain)
        if ($LASTEXITCODE -ne 0) { throw "$Name: git status failed." }
        if ($status.Count -gt 0) {
            throw "$Name has local changes. Commit/stash them before PROD-local deploy."
        }

        $branch = (git branch --show-current).Trim()
        if ($LASTEXITCODE -ne 0) { throw "$Name: cannot determine current branch." }
        if ($branch -ne 'main') {
            throw "$Name must be on main before PROD-local deploy. Current branch: $branch"
        }

        git fetch --prune origin
        if ($LASTEXITCODE -ne 0) { throw "$Name: git fetch failed." }

        git pull --ff-only origin main
        if ($LASTEXITCODE -ne 0) { throw "$Name: git pull --ff-only failed." }

        $head = (git rev-parse HEAD).Trim()
        $originHead = (git rev-parse origin/main).Trim()
        if ($head -ne $originHead) {
            throw "$Name is not aligned with origin/main. local=$head origin=$originHead"
        }

        Write-Host "SYNC_OK $Name $head"
        return $head
    }
    finally {
        Pop-Location
    }
}

if ([string]::IsNullOrWhiteSpace($PortalRepo)) {
    $PortalRepo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
} else {
    $PortalRepo = (Resolve-Path -LiteralPath $PortalRepo).Path
}

$CrmRepo = Resolve-RepoPath -ExplicitPath $CrmRepo -DefaultName 'CRM' -PortalPath $PortalRepo
$FinancieroRepo = Resolve-RepoPath -ExplicitPath $FinancieroRepo -DefaultName 'Financiero' -PortalPath $PortalRepo
$HrRepo = Resolve-RepoPath -ExplicitPath $HrRepo -DefaultName 'AppTTHH' -PortalPath $PortalRepo

$heads = [ordered]@{
    Portal = Assert-CleanMainAndSync -Name 'PortalCorporativo' -Path $PortalRepo
    CRM = Assert-CleanMainAndSync -Name 'CRM' -Path $CrmRepo
    Financiero = Assert-CleanMainAndSync -Name 'Financiero' -Path $FinancieroRepo
    AppTTHH = Assert-CleanMainAndSync -Name 'AppTTHH' -Path $HrRepo
}

Write-Host '--- Repository baseline ---'
$heads.GetEnumerator() | ForEach-Object { Write-Host ("{0}={1}" -f $_.Key,$_.Value) }

Push-Location $PortalRepo
try {
    if (-not $SkipBuild) {
        & (Join-Path $PortalRepo 'scripts\local\prod-local-up.ps1') -EnvFile $EnvFile -Build -SkipVerify
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    } else {
        & (Join-Path $PortalRepo 'scripts\local\prod-local-up.ps1') -EnvFile $EnvFile -SkipVerify
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }

    if (-not $SkipVerify) {
        & (Join-Path $PortalRepo 'scripts\local\prod-local-verify.ps1') -EnvFile $EnvFile -ScanLogs
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }

    Write-Host 'PORTAL_PROD_LOCAL_SYNC_DEPLOY_PASS'
    Write-Host 'Portal:  http://127.0.0.1:4200/'
    Write-Host 'Gateway: http://127.0.0.1:8080/'
}
finally {
    Pop-Location
}
