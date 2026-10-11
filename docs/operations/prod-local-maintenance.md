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

Scheduled backup and maintenance executions pass through `prod-local-scheduled-run.ps1`. Each run writes its console evidence to `runtime/prod-local/operations/<operation>-yyyyMMdd-HHmmss.log`; the default retention is the newest 14 logs per operation. Runtime log files are excluded from Git by the repository `*.log` rule. The wrapper propagates failures to Task Scheduler and emits `PORTAL_PROD_LOCAL_SCHEDULED_RUN_PASS` or `PORTAL_PROD_LOCAL_SCHEDULED_RUN_FAIL`. Both tasks use `WakeToRun` and Task Scheduler retry-on-failure (3 retries, 10-minute interval). Maintenance is additionally serialized behind `PortalCorporativo PROD-local Backup`: it waits until the backup task is no longer running/queued, requires a recent successful backup result (default maximum age 4 hours), and fails closed if the dependency is missing, disabled, stale, failed, or does not become ready within the dependency timeout.

## Consolidated operations status

Use the lightweight operational health command to validate Git alignment, backup freshness, Task Scheduler configuration, and the latest backup/maintenance evidence in one pass:

```powershell
./scripts/local/prod-local-operations-status.ps1
```

For a deeper runtime check that also runs the PROD-local verification and recent-log/observability scan. Deep runtime validation snapshots current Docker restart counters first and fails only when a counter increases during that validation, so historical restart counts do not create false failures while new restart activity is still detected. The same post-readiness restart-delta rule is used by `prod-local-up.ps1` and `prod-local-restart.ps1`: the intentional startup/restart is allowed to complete, then a baseline is captured immediately before verification, so only additional restarts during the verification window are treated as failures:

```powershell
./scripts/local/prod-local-operations-status.ps1 -DeepRuntime
```

Success marker: `PORTAL_PROD_LOCAL_OPERATIONS_STATUS_PASS`.

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
