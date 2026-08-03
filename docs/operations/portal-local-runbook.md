# Portal Local Runbook

## Prerequisites

- Docker Compose v2.
- .NET SDK capable of building .NET 8 projects.
- PowerShell.

## Local Environment

1. Copy `.env.example` to `.env`.
2. Replace every `CHANGE_ME` value locally.
3. Do not commit `.env`.

## Commands

```powershell
dotnet build backend/PortalCorporativo.sln
$env:DOTNET_ROLL_FORWARD='Major'; dotnet test backend/PortalCorporativo.sln --no-build
docker compose --env-file .env.example config
./scripts/run-local.ps1
```

## Notes

- This P1 gate did not create or commit `.env`.
- `dotnet test` without roll-forward failed on this workstation because only .NET runtime 10.x is installed; `DOTNET_ROLL_FORWARD=Major` allowed the .NET 8 testhost to run.
- Frontend build was not executed because no `package.json` exists under `frontend/portal-angular`.
