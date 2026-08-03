# Portal Consumer Runtime Pilot Runbook

## Purpose

Guide a future CRM controlled runtime pilot without activating it in Sprint 20.

## Preflight

1. Confirm Portal main includes Sprint 20.
2. Confirm CRM has completed its Common DB Controlled Activation Plan.
3. Confirm CRM has completed Portal Consumer Contract Alignment.
4. Confirm Portal NonProduction package remains healthy.
5. Confirm no productive Gateway route or external navigation is enabled.

## Validation commands

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\portal-nonproduction-deploy.ps1 -EnvFile .env.example -SkipBuild
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\portal-nonproduction-validate.ps1 -BaseUrl http://localhost:8082 -GatewayPort 8082 -SqlPort 21433 -JwtSecret "CHANGE_ME_Use_At_Least_32_Random_Characters"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\portal-nonproduction-logs.ps1 -EnvFile .env.example -Tail 150
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\portal-nonproduction-stop.ps1 -EnvFile .env.example
```

## Stop condition

Stop the pilot planning path if CRM/Financiero routes, services, shared database markers, real providers, real secrets, private URLs or production activation appear before the next gate.
