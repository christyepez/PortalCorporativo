# Portal Deployment Hardening Runbook

## Purpose

Validate PortalCorporativo deployment hardening without activating production.

## Preparation

1. Sync from GitHub `main`.
2. Confirm `.env.example` exists and `.env` is not committed.
3. Confirm all `CHANGE_ME` values remain placeholders in versioned files.
4. Confirm no CRM or Financiero runtime coupling is introduced.

## Validation commands

```powershell
git diff --check
dotnet build backend/PortalCorporativo.sln
$env:DOTNET_ROLL_FORWARD='Major'; dotnet test backend/PortalCorporativo.sln --no-build
docker compose --env-file .env.example config
.\tools\check-portal-guardrails.ps1
.\tools\preflight-portal-local.ps1
.\tools\verify-portal-foundation.ps1
.\tools\check-portal-deployment-hardening-guardrails.ps1
.\tools\verify-portal-deployment-hardening-foundation.ps1
```

## Controlled runtime validation

Runtime startup, health checks and smoke tests remain pending controlled environment in P7. When approved, use local placeholders only and never commit generated `.env`, logs or runtime artifacts.

## Expected result

Deployment hardening documents and scripts exist, production is NoGo, and existing P1-P6 guardrails still pass.
