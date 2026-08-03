# Portal to CRM Contract Alignment Runbook

## Purpose

Validate that Portal remains stable and contract-only while handing off CRM alignment requirements.

## Steps

1. Confirm Portal main includes Sprint 21.
2. Confirm Sprint 20 consumer runtime pilot planning is reviewed.
3. Confirm no CRM service exists in Portal Docker Compose.
4. Confirm no CRM route or cluster exists in Portal Gateway runtime configuration.
5. Confirm no productive CRM navigation is enabled.
6. Run Portal NonProduction validation using the existing wrappers.
7. Hand off the Sprint 21 package to the CRM repository workflow.

## Validation commands

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\portal-nonproduction-deploy.ps1 -EnvFile .env.example -SkipBuild
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\portal-nonproduction-validate.ps1 -BaseUrl http://localhost:8082 -GatewayPort 8082 -SqlPort 21433 -JwtSecret "CHANGE_ME_Use_At_Least_32_Random_Characters"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\portal-nonproduction-logs.ps1 -EnvFile .env.example -Tail 150
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\portal-nonproduction-stop.ps1 -EnvFile .env.example
```

## Stop condition

Stop if a CRM route, CRM service, shared DB, cross-domain migration, private URL, real secret, real provider or production activation appears before the CRM P2 gate.
