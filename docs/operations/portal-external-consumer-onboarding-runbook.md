# Portal External Consumer Onboarding Runbook

## Purpose

Validate that external consumer onboarding remains contract-only and does not activate CRM or Financiero runtime coupling.

## Validation

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

## Guardrails

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-external-consumer-guardrails.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\verify-portal-external-consumer-onboarding-preparation.ps1
```

## Expected result

- No CRM or Financiero services in Portal Compose.
- No CRM or Financiero productive Gateway routes.
- No productive external navigation.
- No shared database ownership.
- No private URLs, secrets, tokens or certificates.
- Production remains `NoGo`.
