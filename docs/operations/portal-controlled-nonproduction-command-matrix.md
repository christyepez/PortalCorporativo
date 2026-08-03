# Portal Controlled NonProduction Command Matrix

| Step | Command |
| --- | --- |
| Preflight | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\preflight-portal-local.ps1` |
| Guardrails | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-controlled-nonproduction-deployment-guardrails.ps1` |
| Verify package | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\verify-portal-controlled-nonproduction-deployment-package.ps1` |
| Backend build | `dotnet build backend\PortalCorporativo.sln` |
| Backend tests | `$env:DOTNET_ROLL_FORWARD='Major'; dotnet test backend\PortalCorporativo.sln --no-build` |
| Compose config | `docker compose --env-file .env.example config` |
| Deploy | `docker compose --env-file .env.example up -d --build` |
| Deploy wrapper | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\portal-nonproduction-deploy.ps1` |
| Health | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-health.ps1 -BaseUrl http://localhost:8082` |
| Smoke | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts\smoke\sprint1-smoke.ps1 -JwtSecret "CHANGE_ME_Use_At_Least_32_Random_Characters" -GatewayPort 8082 -SqlPort 21433` |
| Logs | `docker compose --env-file .env.example logs --tail 150` |
| Validate wrapper | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\portal-nonproduction-validate.ps1 -JwtSecret "CHANGE_ME_Use_At_Least_32_Random_Characters"` |
| Stop | `docker compose --env-file .env.example down` |
| Stop wrapper | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\portal-nonproduction-stop.ps1` |
