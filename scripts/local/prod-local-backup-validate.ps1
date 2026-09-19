param(
    [string]$BackupSetPath = ""
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$backupRoot = Join-Path $root 'backups\prod-local'

if ([string]::IsNullOrWhiteSpace($BackupSetPath)) {
    $latest = Get-ChildItem -LiteralPath $backupRoot -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if (-not $latest) { throw 'No backup set found.' }
    $setPath = $latest.FullName
} else {
    $setPath = if ([IO.Path]::IsPathRooted($BackupSetPath)) { $BackupSetPath } else { Join-Path $root $BackupSetPath }
}

$manifestPath = Join-Path $setPath 'manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath)) { throw "Manifest not found: $manifestPath" }
$items = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
if ($items.Count -eq 0) { throw 'Backup manifest is empty.' }

$container = 'portal-backup-restore-validation'
$password = 'Aa1' + ([Guid]::NewGuid().ToString('N')) + 'Z9'
$mount = "type=bind,source=$setPath,target=/var/opt/mssql/backup,readonly"
docker rm -f $container 2>$null | Out-Null
docker run -d --name $container --mount $mount -e ACCEPT_EULA=Y -e "MSSQL_SA_PASSWORD=$password" mcr.microsoft.com/mssql/server:2022-latest | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Could not start validation SQL Server.' }

try {
    $ready = $false
    for ($i = 0; $i -lt 60; $i++) {
        $previousPreference = $ErrorActionPreference
        $ErrorActionPreference = 'SilentlyContinue'
        docker exec $container /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $password -C -Q "SELECT 1" 2>$null | Out-Null
        $readyCode = $LASTEXITCODE
        $ErrorActionPreference = $previousPreference
        if ($readyCode -eq 0) { $ready = $true; break }
        Start-Sleep -Seconds 2
    }
    if (-not $ready) { throw 'Validation SQL Server did not become ready.' }

    foreach ($item in $items) {
        $db = [string]$item.Database
        $file = [string]$item.File
        if ($db -notmatch '^[A-Za-z0-9_]+$' -or $file -notmatch '^[A-Za-z0-9_.-]+$') { throw 'Invalid backup manifest entry.' }
        $backup = "/var/opt/mssql/backup/$file"
        $verify = "RESTORE VERIFYONLY FROM DISK=N'$backup' WITH CHECKSUM;"
        docker exec $container /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $password -C -b -Q $verify
        if ($LASTEXITCODE -ne 0) { throw "VERIFYONLY failed for $db." }
        $restore = "RESTORE DATABASE [$db] FROM DISK=N'$backup' WITH RECOVERY, CHECKSUM; DBCC CHECKDB([$db]) WITH NO_INFOMSGS; ALTER DATABASE [$db] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$db];"
        docker exec $container /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $password -C -b -Q $restore
        if ($LASTEXITCODE -ne 0) { throw "Restore validation failed for $db." }
        Write-Output "PASS restore validation: $db"
    }

    Write-Output "PORTAL_PROD_LOCAL_BACKUP_VALIDATION_PASS $setPath"
}
finally {
    docker rm -f $container 2>$null | Out-Null
}
