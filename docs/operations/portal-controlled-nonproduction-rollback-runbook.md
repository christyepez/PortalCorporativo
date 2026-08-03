# Portal Controlled NonProduction Rollback Runbook

## Stop stack

```powershell
docker compose --env-file .env.example down
docker ps --filter name=portal-corporativo --format "{{.Names}} {{.Status}}"
```

Optional wrapper:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\portal-nonproduction-stop.ps1
```

## Expected result

- RollbackStopValidated: true.
- StackStoppedAfterValidation: true.
- No Portal containers remain running.

This rollback is NonProduction-only. Production rollback remains out of scope.
