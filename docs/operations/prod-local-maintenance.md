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
- container state and health;
- recent fatal/critical log patterns when `-ScanLogs` is supplied;
- authenticated Portal smoke;
- optional non-destructive recovery drill when `-RecoveryDrill` is supplied.

Success marker: `PORTAL_PROD_LOCAL_MAINTENANCE_PASS`.

## Daily backup task

Preview registration without changing Windows:

```powershell
./scripts/local/prod-local-backup-schedule.ps1 -Action Install -DailyAt 02:00 -WhatIf
```

Install:

```powershell
./scripts/local/prod-local-backup-schedule.ps1 -Action Install -DailyAt 02:00
```

Inspect or remove:

```powershell
./scripts/local/prod-local-backup-schedule.ps1 -Action Show
./scripts/local/prod-local-backup-schedule.ps1 -Action Remove
```

## Daily maintenance task

The maintenance task is intended to run after the daily backup.

Preview:

```powershell
./scripts/local/prod-local-maintenance-schedule.ps1 -Action Install -DailyAt 02:30 -WhatIf
```

Install:

```powershell
./scripts/local/prod-local-maintenance-schedule.ps1 -Action Install -DailyAt 02:30
```

To include the deeper non-destructive recovery drill in the scheduled maintenance:

```powershell
./scripts/local/prod-local-maintenance-schedule.ps1 -Action Install -DailyAt 02:30 -RecoveryDrill
```

Inspect or remove:

```powershell
./scripts/local/prod-local-maintenance-schedule.ps1 -Action Show
./scripts/local/prod-local-maintenance-schedule.ps1 -Action Remove
```

Scheduled task commands contain only local paths and operational switches. Secret values are never embedded. Backup and maintenance tasks are configured to start and continue while the laptop is on battery power, so operational checks are not silently queued when AC power is unavailable.

`MarketingIndo` remains a deferred synchronization target and is ignored when offline.
