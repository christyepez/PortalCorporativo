param(
    [string]$OutputRoot = "backups/prod-local"
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$outputBase = if ([IO.Path]::IsPathRooted($OutputRoot)) { $OutputRoot } else { Join-Path $root $OutputRoot }

if (-not (Test-Path -LiteralPath $outputBase)) {
    Write-Output 'No PROD-local backup sets found.'
    exit 0
}

$rows = foreach ($set in (Get-ChildItem -LiteralPath $outputBase -Directory | Sort-Object Name -Descending)) {
    $manifestPath = Join-Path $set.FullName 'manifest.json'
    if (-not (Test-Path -LiteralPath $manifestPath)) { continue }
    $items = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    [pscustomobject]@{
        BackupSet = $set.Name
        Databases = $items.Count
        SizeMB = [math]::Round((($items | Measure-Object SizeBytes -Sum).Sum / 1MB), 2)
        Path = $set.FullName
    }
}

$rows | Format-Table -AutoSize
