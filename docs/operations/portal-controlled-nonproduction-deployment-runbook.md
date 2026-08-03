# Portal Controlled NonProduction Deployment Runbook

## Prerequisites

- Docker and Docker Compose.
- .NET SDK capable of building the solution.
- Node.js and npm.
- Available ports from `.env.example`.
- A local `.env` file copied from `.env.example` and kept unversioned.

## Deploy

```powershell
git diff --check
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-controlled-nonproduction-deployment-guardrails.ps1
docker compose --env-file .env.example config
dotnet build backend\PortalCorporativo.sln
$env:DOTNET_ROLL_FORWARD='Major'; dotnet test backend\PortalCorporativo.sln --no-build
docker compose --env-file .env.example up -d --build
```

Optional wrapper:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\portal-nonproduction-deploy.ps1
```

## Notes

Use `.env.example` for validation and local placeholders only. Do not commit `.env`.
