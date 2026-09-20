# PROD-local Maintenance Automation

`trabajo` is the primary Docker Desktop runtime.

## One-command maintenance report

```powershell
./scripts/local/prod-local-maintenance.ps1 -ScanLogs
```

The report validates:

- latest backup age (default maximum 24 hours);
- retention set count (default maximum 7);
- exact managed-database inventory;
- presence and SHA-256 integrity of every file in the latest backup set;
- free disk space (default minimum 10 GB);
- container state, health and restart counts;
- recent fatal/critical log patterns when `-ScanLogs` is supplied;
- authenticated Portal smoke.

Success marker: `PORTAL_PROD_LOCAL_MAINTENANCE_PASS`.

## Optional daily backup task

Preview registration without changing Windows:
```powershell
./scripts/local/prod-local-backup-schedule.ps1 -Action Install -DailyAt 02:00 -WhatIf
```

Install only when desired:

```powershell
./scripts/local/prod-local-backup-schedule.ps1 -Action Install -DailyAt 02:00
```

Inspect or remove:

```powershell
./scripts/local/prod-local-backup-schedule.ps1 -Action Show
./scripts/local/prod-local-backup-schedule.ps1 -Action Remove
```

The task passes only the local environment-file path to the backup script; secret values are never embedded in the scheduled-task command.

`MarketingIndo` remains a deferred synchronization target and is ignored when offline.
