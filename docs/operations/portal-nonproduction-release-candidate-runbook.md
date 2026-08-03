# Portal NonProduction Release Candidate Runbook

## Purpose

Validate and package Portal Corporativo as a controlled NonProduction Release Candidate without enabling production.

## Commands

```powershell
git diff --check
dotnet build backend\PortalCorporativo.sln
$env:DOTNET_ROLL_FORWARD='Major'; dotnet test backend\PortalCorporativo.sln --no-build
docker compose --env-file .env.example config
docker compose --env-file .env.example up -d --build
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-health.ps1 -BaseUrl http://localhost:8082
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts\smoke\sprint1-smoke.ps1 -GatewayPort 8082 -SqlPort 21433
docker compose --env-file .env.example logs --tail 150
docker compose --env-file .env.example down
npm run build
npm run test
npm run lint
```

## Guardrails

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-nonproduction-rc-guardrails.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\verify-portal-nonproduction-rc-evidence.ps1
```

## Expected outcome

- Portal is ready for a controlled NonProduction deployment package.
- Production remains `NoGo`.
- The stack is stopped after validation.
