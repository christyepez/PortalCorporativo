# Portal Controlled Runtime Validation Runbook

## Scope

Validate PortalCorporativo runtime only in a controlled non-production local environment.

## Preconditions

- GitHub `main` is the source of truth.
- P1-P8 baseline is closed.
- No `.env` file is committed.
- `.env.example` contains only placeholder/local values.
- CRM and Financiero runtime coupling remain disabled.

## Commands

```powershell
git remote -v
git checkout main
git fetch origin
git pull origin main
git rev-parse HEAD
git checkout -b portal-sprint9-controlled-runtime-validation

git diff --check
dotnet build backend/PortalCorporativo.sln
$env:DOTNET_ROLL_FORWARD='Major'
dotnet test backend/PortalCorporativo.sln --no-build
docker compose --env-file .env.example config
docker compose --env-file .env.example up -d --build
docker compose --env-file .env.example ps
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-health.ps1 -BaseUrl http://localhost:8082
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts\smoke\sprint1-smoke.ps1 -JwtSecret "LOCAL_ONLY_PLACEHOLDER_CHANGE_ME_1234567890" -GatewayPort 8082 -SqlPort 21433
docker compose --env-file .env.example down
```

## Expected result

The stack may be validated only as non-production. If any runtime endpoint or smoke test fails, record `ControlledRuntimeReadiness: PartialBlocked` and keep production `NoGo`.

## Rollback

```powershell
docker compose --env-file .env.example down
docker compose --env-file .env.example ps
```

Do not delete volumes or real data during controlled validation.
