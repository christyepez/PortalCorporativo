# Portal Docker Full Stack Runtime Runbook

## Purpose

Run a controlled NonProduction validation of the complete Portal Docker Compose stack.

## Preconditions

- Use `main` or a branch based on current GitHub `main`.
- Use `.env.example` only as a placeholder source.
- Do not create or commit a real `.env`.
- Do not use real secrets, certificates, private URLs or production providers.

## Commands

```powershell
git diff --check
dotnet build backend\PortalCorporativo.sln
$env:DOTNET_ROLL_FORWARD='Major'; dotnet test backend\PortalCorporativo.sln --no-build
docker compose --env-file .env.example config
docker compose --env-file .env.example up -d --build
docker compose --env-file .env.example ps
docker compose --env-file .env.example logs --tail 150
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-health.ps1 -BaseUrl http://localhost:8082
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts\smoke\sprint1-smoke.ps1 -JwtSecret "LOCAL_ONLY_PLACEHOLDER_CHANGE_ME_1234567890" -GatewayPort 8082 -SqlPort 21433
docker compose --env-file .env.example down
```

For frontend:

```powershell
Push-Location frontend
npm run build
npm run test
npm run lint
Pop-Location
```

## Expected result

- Required services are running or healthy.
- Health endpoints return 200.
- Smoke passes for clean-stack and existing-stack scenarios.
- Protected endpoints either succeed with matching local placeholder token or return 401/403.
- Rollback stops the stack.

## Production warning

This runbook does not approve production. Production remains `NoGo`.
