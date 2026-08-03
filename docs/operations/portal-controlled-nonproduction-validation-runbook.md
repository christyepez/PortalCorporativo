# Portal Controlled NonProduction Validation Runbook

## Validate runtime

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-health.ps1 -BaseUrl http://localhost:8082
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts\smoke\sprint1-smoke.ps1 -JwtSecret "CHANGE_ME_Use_At_Least_32_Random_Characters" -GatewayPort 8082 -SqlPort 21433
docker compose --env-file .env.example logs --tail 150
```

## Validate frontend

```powershell
Push-Location frontend
npm run build
npm run test
npm run lint
Pop-Location
```

## Validate package evidence

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\verify-portal-controlled-nonproduction-deployment-package.ps1
```

Optional wrapper:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\portal-nonproduction-validate.ps1 -JwtSecret "CHANGE_ME_Use_At_Least_32_Random_Characters"
```
