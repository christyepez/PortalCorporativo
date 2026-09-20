param(
    [string]$BackupRoot = "backups/prod-local",
    [int]$MaxBackupAgeHours = 24,
    [int]$RetentionSets = 7,
    [double]$MinFreeGB = 10,
    [switch]$SkipRuntimeVerify,
    [switch]$ScanLogs
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$backupPath = if ([IO.Path]::IsPathRooted($BackupRoot)) { $BackupRoot } else { Join-Path $root $BackupRoot }
$expectedDatabases = @(
    'PortalSecurity','PortalConfiguration','PortalMenu',
    'PortalAudit','PortalNotification','PortalIntegration',
    'FinancieroDb','AppTTHHDb','HistoriasPaolinDb'
)
$failures = @()

if (-not (Test-Path -LiteralPath $backupPath)) {
    $failures += "backupRootMissing=$backupPath"
} else {
    $sets = @(Get-ChildItem -LiteralPath $backupPath -Directory | Sort-Object Name -Descending)
    if ($sets.Count -eq 0) { $failures += 'backupSets=0' }
    if ($RetentionSets -gt 0 -and $sets.Count -gt $RetentionSets) { $failures += "retentionSets=$($sets.Count)>$RetentionSets" }
}
if ($failures.Count -eq 0) {
    $latest = $sets[0]
    $manifestPath = Join-Path $latest.FullName 'manifest.json'
    if (-not (Test-Path -LiteralPath $manifestPath)) {
        $failures += "manifestMissing=$($latest.Name)"
    } else {
        $ageHours = ((Get-Date).ToUniversalTime() - (Get-Item $manifestPath).LastWriteTimeUtc).TotalHours
        Write-Output ("CHECK backupSet={0} ageHours={1:N2}" -f $latest.Name,$ageHours)
        if ($ageHours -gt $MaxBackupAgeHours) { $failures += "backupAgeHours=$([math]::Round($ageHours,2))>$MaxBackupAgeHours" }

        $items = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
        $actualDatabases = @($items | ForEach-Object { [string]$_.Database } | Sort-Object)
        $expectedSorted = @($expectedDatabases | Sort-Object)
        if (($actualDatabases -join '|') -ne ($expectedSorted -join '|')) { $failures += 'databaseInventoryMismatch=true' }

        foreach ($item in $items) {
            $file = Join-Path $latest.FullName ([string]$item.File)
            if (-not (Test-Path -LiteralPath $file)) { $failures += "backupFileMissing=$($item.File)"; continue }
            $hash = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash
            if ($hash -ne [string]$item.Sha256) { $failures += "sha256Mismatch=$($item.File)" }
        }
    }
}
$driveRoot = [IO.Path]::GetPathRoot($backupPath)
$driveName = $driveRoot.TrimEnd('\').TrimEnd(':')
$drive = Get-PSDrive -Name $driveName
$freeGB = [math]::Round($drive.Free / 1GB, 2)
Write-Output ("CHECK backupDrive={0} freeGB={1:N2}" -f $driveName,$freeGB)
if ($freeGB -lt $MinFreeGB) { $failures += "freeGB=$freeGB<$MinFreeGB" }

if (-not $SkipRuntimeVerify) {
    try {
        & (Join-Path $PSScriptRoot 'prod-local-verify.ps1') -ScanLogs:$ScanLogs
    } catch {
        $failures += 'runtimeVerify=failed'
        Write-Output $_.Exception.Message
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output "FAIL $_" }
    throw "PROD-local maintenance failed with $($failures.Count) issue(s)."
}

Write-Output 'PORTAL_PROD_LOCAL_MAINTENANCE_PASS'
