# Portal Controlled Auth Runbook

## Purpose

Validate that Auth integration remains prepared but not production-active.

## Checks

```powershell
git diff --check
dotnet build backend\PortalCorporativo.sln
$env:DOTNET_ROLL_FORWARD='Major'; dotnet test backend\PortalCorporativo.sln --no-build
docker compose --env-file .env.example config
docker compose --env-file .env.example up -d --build
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-health.ps1 -BaseUrl http://localhost:8082
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts\smoke\sprint1-smoke.ps1 -JwtSecret "LOCAL_ONLY_PLACEHOLDER_CHANGE_ME_1234567890" -GatewayPort 8082 -SqlPort 21433
docker compose --env-file .env.example down
```

Frontend:

```powershell
Push-Location frontend
npm run build
npm run test
npm run lint
Pop-Location
```

Guardrails:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-controlled-auth-guardrails.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\verify-portal-controlled-auth-preparation.ps1
```

## Expected result

- No real SSO/OIDC configuration.
- No real client_id or client_secret.
- No browser token storage.
- Gateway and Security authorization foundations remain present.
- Production remains `NoGo`.
