# PROD-local Backup and Recovery

## Scope

The primary runtime is Docker Desktop on `trabajo`. Backups cover only databases managed by the Portal runtime:

- `PortalSecurity`
- `PortalConfiguration`
- `PortalMenu`
- `PortalAudit`
- `PortalNotification`
- `PortalIntegration`
- `FinancieroDb`
- `AppTTHHDb`
- `HistoriasPaolinDb`

Historical databases and databases owned by other projects are intentionally excluded.

## Create a backup set

```powershell
./scripts/local/prod-local-backup.ps1
```

Each set is stored under ignored `backups/prod-local/<timestamp>` and contains one `.bak` per database plus `manifest.json` with file size and SHA-256.

Backup uses SQL Server `COPY_ONLY`, `COMPRESSION`, `CHECKSUM` and `RESTORE VERIFYONLY`. The default retention is the newest 7 backup sets.
## Inventory

```powershell
./scripts/local/prod-local-backup-list.ps1
```

## Validate recovery without touching the live runtime

```powershell
./scripts/local/prod-local-backup-validate.ps1
```

The validator starts an isolated disposable SQL Server container, mounts the backup set read-only, restores every database, runs `DBCC CHECKDB`, drops the restored copy and removes the temporary container.

A successful run ends with `PORTAL_PROD_LOCAL_BACKUP_VALIDATION_PASS`.

## Restore a live database

Live restore is intentionally guarded and requires an explicit `-Apply` switch:

```powershell
./scripts/local/prod-local-restore.ps1 `
  -BackupSetPath 'backups/prod-local/<timestamp>' `
  -Database PortalSecurity `
  -Apply
```

Before restore, the script creates a safety backup unless `-SkipSafetyBackup` is explicitly supplied. It validates SHA-256, stops only containers that own the target database, restores with checksum, runs `DBCC CHECKDB`, returns the database to multi-user mode and restarts those containers.
## Guardrails

- Never commit `.bak`, manifests with local paths, or environment files.
- Do not include unrelated databases from the shared SQL instance.
- Validate a backup set before any live restore.
- Real SRI production transmission remains disabled.
- After any live restore, run:

```powershell
./scripts/local/prod-local-verify.ps1 -ScanLogs
```

Expected markers are `PROD_LOCAL_SMOKE_PASS` and `PORTAL_PROD_LOCAL_VERIFY_PASS`.
