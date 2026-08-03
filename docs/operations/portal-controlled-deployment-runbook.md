# Portal Controlled Deployment Runbook

## Purpose

Run Portal Corporativo locally or in NonProduction with safe placeholders and explicit guardrails. This runbook does not enable production.

## Prerequisites

- Git checkout based on GitHub `main`.
- Docker Compose v2.
- .NET SDK compatible with the solution.
- PowerShell.

## Safe Configuration

1. Keep `.env.example` versioned.
2. Create `.env` locally only when running containers.
3. Replace every `CHANGE_ME` locally.
4. Never commit `.env`, tokens, certificates, private URLs or real data.

## Validation Sequence

```powershell
.\tools\check-portal-guardrails.ps1
.\tools\preflight-portal-local.ps1
dotnet build backend/PortalCorporativo.sln
$env:DOTNET_ROLL_FORWARD='Major'; dotnet test backend/PortalCorporativo.sln --no-build
docker compose --env-file .env.example config
.\tools\verify-portal-foundation.ps1
```

## Optional Runtime Sequence

Only after preparing a local untracked `.env`:

```powershell
docker compose --env-file .env up -d --build
.\tools\check-portal-health.ps1 -BaseUrl http://localhost:8082
.\scripts\smoke\sprint1-smoke.ps1
```

## Rollback

Use `.\scripts\stop-local.ps1` or `docker compose --env-file .env down`. Do not delete volumes unless a local reset is explicitly approved.
