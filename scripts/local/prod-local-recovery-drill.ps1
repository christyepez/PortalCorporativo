param(
    [Parameter(Mandatory=$true)][string]$BackupSetPath,
    [string[]]$EnvFile = @(".env.portal.local"),
    [string[]]$Database = @(),
    [switch]$TempRestore
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$setPath = if ([IO.Path]::IsPathRooted($BackupSetPath)) { $BackupSetPath } else { Join-Path $root $BackupSetPath }
$manifestPath = Join-Path $setPath 'manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath)) { throw "Manifest not found: $manifestPath" }

$vars = @{}
foreach ($file in $EnvFile) {
    $path = if ([IO.Path]::IsPathRooted($file)) { $file } else { Join-Path $root $file }
    if (-not (Test-Path -LiteralPath $path)) { throw "Environment file not found: $path" }
    Get-Content -LiteralPath $path | ForEach-Object {
        if ($_ -match '^[#\s]*$') { return }
        $i = $_.IndexOf('=')
        if ($i -gt 0) { $vars[$_.Substring(0,$i).Trim()] = $_.Substring($i + 1).Trim() }
    }
}
$password = $vars['SQLSERVER_SA_PASSWORD']
if ([string]::IsNullOrWhiteSpace($password)) { throw 'SQLSERVER_SA_PASSWORD is required.' }

function Invoke-PortalSql {
    param(
        [Parameter(Mandatory=$true)][string]$Query,
        [switch]$Capture,
        [string[]]$ExtraArgs = @()
    )

    $args = @(
        'exec',
        'portalcorporativo-sqlserver-1',
        '/opt/mssql-tools18/bin/sqlcmd',
        '-S','localhost',
        '-U','sa',
        '-P',$password,
        '-C',
        '-b'
    ) + $ExtraArgs + @('-Q',$Query)

    if ($Capture) {
        $output = @(& docker @args)
        if ($LASTEXITCODE -ne 0) { throw 'SQL command failed during recovery drill.' }
        return $output
    }

    & docker @args
    if ($LASTEXITCODE -ne 0) { throw 'SQL command failed during recovery drill.' }
}

$items = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
if ($Database.Count -gt 0) {
    $items = @($items | Where-Object { $Database -contains [string]$_.Database })
}
if ($items.Count -eq 0) { throw 'No backup entries selected for recovery drill.' }

$containerDir = '/var/opt/mssql/backup/portal-local/recovery-drill'
docker exec portalcorporativo-sqlserver-1 mkdir -p $containerDir | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Could not prepare recovery drill directory in SQL Server.' }

try {
    foreach ($item in $items) {
        $db = [string]$item.Database
        if ($db -notmatch '^[A-Za-z0-9_]+$') { throw "Invalid database name in manifest: $db" }

        $backupFile = Join-Path $setPath ([string]$item.File)
        if (-not (Test-Path -LiteralPath $backupFile)) { throw "Backup file not found: $backupFile" }
        $actualHash = (Get-FileHash -LiteralPath $backupFile -Algorithm SHA256).Hash
        if ($actualHash -ne [string]$item.Sha256) { throw "Backup SHA256 mismatch for $db." }

        $containerFile = "$containerDir/$([IO.Path]::GetFileName($backupFile))"
        $tempDb = $null
        $tempRestoreSucceeded = $false

        try {
            docker cp $backupFile "portalcorporativo-sqlserver-1:$containerFile" | Out-Null
            if ($LASTEXITCODE -ne 0) { throw "Could not stage backup for $db." }

            $verifyQuery = "RESTORE VERIFYONLY FROM DISK=N'$containerFile' WITH CHECKSUM; DBCC CHECKDB([$db]) WITH NO_INFOMSGS;"
            Invoke-PortalSql -Query $verifyQuery
            Write-Output "RECOVERY_DRILL_PASS $db"

            if ($TempRestore) {
                $fileListLines = @(Invoke-PortalSql -Capture -ExtraArgs @('-W','-s','|','-h','-1') -Query "RESTORE FILELISTONLY FROM DISK=N'$containerFile';")
                $fileRows = @()
                foreach ($line in $fileListLines) {
                    $parts = [string]$line -split '\|'
                    if ($parts.Count -lt 3) { continue }
                    $logicalName = $parts[0].Trim()
                    $fileType = $parts[2].Trim()
                    if ([string]::IsNullOrWhiteSpace($logicalName)) { continue }
                    if ($fileType -notin @('D','L')) { continue }
                    $fileRows += [pscustomobject]@{
                        LogicalName = $logicalName
                        Type = $fileType
                    }
                }
                if ($fileRows.Count -eq 0) { throw "RESTORE FILELISTONLY returned no data/log files for $db." }

                $tempDb = "PortalRecovery_{0}_{1}" -f $db,([guid]::NewGuid().ToString('N').Substring(0,8))
                if ($tempDb -notmatch '^PortalRecovery_[A-Za-z0-9_]+$') { throw "Invalid temporary recovery database name: $tempDb" }

                $moveClauses = @()
                $dataIndex = 0
                $logIndex = 0
                foreach ($fileRow in $fileRows) {
                    $logicalSql = ([string]$fileRow.LogicalName).Replace("'","''")
                    if ([string]$fileRow.Type -eq 'L') {
                        $logIndex++
                        $destination = "/var/opt/mssql/data/${tempDb}_log$logIndex.ldf"
                    } else {
                        $dataIndex++
                        $extension = if ($dataIndex -eq 1) { '.mdf' } else { '.ndf' }
                        $destination = "/var/opt/mssql/data/${tempDb}_data$dataIndex$extension"
                    }
                    $moveClauses += "MOVE N'$logicalSql' TO N'$destination'"
                }

                $restoreQuery = "RESTORE DATABASE [$tempDb] FROM DISK=N'$containerFile' WITH CHECKSUM, RECOVERY, $($moveClauses -join ', '); DBCC CHECKDB([$tempDb]) WITH NO_INFOMSGS;"
                Invoke-PortalSql -Query $restoreQuery
                $tempRestoreSucceeded = $true
            }
        }
        finally {
            if (-not [string]::IsNullOrWhiteSpace($tempDb)) {
                if ($tempDb -notmatch '^PortalRecovery_[A-Za-z0-9_]+$') { throw "Refusing to drop unexpected database name: $tempDb" }
                $dropQuery = "IF DB_ID(N'$tempDb') IS NOT NULL DROP DATABASE [$tempDb];"
                Invoke-PortalSql -Query $dropQuery
                Write-Output "RECOVERY_TEMP_CLEANUP_PASS $db"
            }
            docker exec portalcorporativo-sqlserver-1 rm -f $containerFile 2>$null | Out-Null
        }

        if ($TempRestore -and $tempRestoreSucceeded) {
            Write-Output "RECOVERY_TEMP_RESTORE_PASS $db"
        }
    }
}
finally {
    docker exec portalcorporativo-sqlserver-1 sh -c "rm -f $containerDir/*" 2>$null | Out-Null
}

if ($TempRestore) {
    Write-Output 'PORTAL_PROD_LOCAL_TEMP_RESTORE_DRILL_PASS'
}
Write-Output 'PORTAL_PROD_LOCAL_RECOVERY_DRILL_PASS'
