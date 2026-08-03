# Portal Health Smoke Hardening Runbook

## Health validation

```powershell
docker compose --env-file .env.example up -d --build
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-health.ps1 -BaseUrl http://localhost:8082
```

Expected:

- `/health` returns 200.
- `/health/live` returns 200.
- `/health/ready` returns 200.

## Clean-stack smoke

```powershell
docker compose --env-file .env.example down
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts\smoke\sprint1-smoke.ps1 -JwtSecret "LOCAL_ONLY_PLACEHOLDER_CHANGE_ME_1234567890" -GatewayPort 8082 -SqlPort 21433
```

Expected:

- Script starts required services.
- Health endpoints pass.
- Development notification smoke passes when the local placeholder token matches the stack.
- Script stops the stack because it started it.

## Existing-stack smoke

```powershell
docker compose --env-file .env.example up -d --build
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts\smoke\sprint1-smoke.ps1 -JwtSecret "LOCAL_ONLY_PLACEHOLDER_CHANGE_ME_1234567890" -GatewayPort 8082 -SqlPort 21433
```

Expected:

- Script detects the running stack.
- Script does not fail on occupied ports.
- Script accepts 401/403 for protected endpoints when the placeholder token does not match a reused stack.
- Script does not stop a stack it did not start.

## Rollback

```powershell
docker compose --env-file .env.example down
```

Do not delete volumes or real data during this baseline.
