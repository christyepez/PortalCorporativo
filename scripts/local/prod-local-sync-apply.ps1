[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [string]$Package = 'config/prod-local-sync-package.json',
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$packagePath = if ([IO.Path]::IsPathRooted($Package)) { $Package } else { Join-Path $root $Package }
if (-not (Test-Path -LiteralPath $packagePath)) { throw "Sync package not found: $packagePath" }
$packageData = Get-Content -LiteralPath $packagePath -Raw | ConvertFrom-Json

if (-not $Apply) { throw 'Synchronization changes repositories. Re-run with -Apply after reviewing the package and preflight.' }

$targets = @(
    [pscustomobject]@{ Name='PortalCorporativo'; Path=$root; Branch=[string]$packageData.PortalBranch; Revision='' }
)
foreach ($repo in $packageData.Repositories) {
    $targets += [pscustomobject]@{
        Name = [string]$repo.Name
        Path = (Join-Path $root ([string]$repo.RelativePath))
        Branch = [string]$repo.Branch
        Revision = [string]$repo.Revision
    }
}
foreach ($target in $targets) {
    if (-not (Test-Path -LiteralPath $target.Path)) { throw "Repository missing: $($target.Name) at $($target.Path)" }
    $dirty = @(& git -C $target.Path status --porcelain)
    if ($dirty.Count -gt 0) { throw "Repository has local changes and will not be modified: $($target.Name)" }
}

foreach ($target in $targets) {
    if (-not $PSCmdlet.ShouldProcess($target.Name, "Synchronize branch $($target.Branch)")) { continue }
    & git -C $target.Path fetch origin --prune
    if ($LASTEXITCODE -ne 0) { throw "git fetch failed: $($target.Name)" }
    & git -C $target.Path switch $target.Branch
    if ($LASTEXITCODE -ne 0) { throw "git switch failed: $($target.Name)" }

    if ([string]::IsNullOrWhiteSpace($target.Revision)) {
        & git -C $target.Path pull --ff-only origin $target.Branch
    } else {
        & git -C $target.Path merge --ff-only $target.Revision
    }
    if ($LASTEXITCODE -ne 0) { throw "fast-forward synchronization failed: $($target.Name)" }
    $current = (& git -C $target.Path rev-parse HEAD).Trim()
    Write-Output "SYNC repo=$($target.Name) branch=$($target.Branch) revision=$current"
}

Write-Output 'PORTAL_PROD_LOCAL_SYNC_APPLY_PASS'
