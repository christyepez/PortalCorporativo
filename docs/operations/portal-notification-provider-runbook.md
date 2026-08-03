# Portal Notification Provider Runbook

## Purpose

Validate that Notification Provider preparation is documented and that runtime remains NonProduction-only.

## Local validation

```powershell
git diff --check
dotnet build backend\PortalCorporativo.sln
$env:DOTNET_ROLL_FORWARD='Major'; dotnet test backend\PortalCorporativo.sln --no-build
docker compose --env-file .env.example config
docker compose --env-file .env.example up -d --build
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-health.ps1 -BaseUrl http://localhost:8082
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts\smoke\sprint1-smoke.ps1 -GatewayPort 8082 -SqlPort 21433
docker compose --env-file .env.example down
```

## Provider guardrails

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-notification-provider-guardrails.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\verify-portal-notification-provider-preparation.ps1
```

## Expected result

- Development providers only.
- No real SMTP/email/SMS/push/webhook provider.
- No provider credentials.
- No external API calls.
- No CRM or Financiero runtime coupling.
- Production remains `NoGo`.

## Rollback

This sprint is documentation and guardrail only. Rollback is reverting the Sprint 15 docs and tools commit.
