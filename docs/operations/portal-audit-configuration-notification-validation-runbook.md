# Portal Audit / Configuration / Notification Validation Runbook

## Purpose

Validate crosscutting Portal baselines without sending real notifications or enabling production providers.

## Commands

```powershell
.\tools\check-portal-guardrails.ps1
.\tools\preflight-portal-local.ps1
.\tools\verify-portal-foundation.ps1
.\tools\check-portal-auth-guardrails.ps1
.\tools\verify-portal-auth-foundation.ps1
.\tools\check-portal-menu-permissions-guardrails.ps1
.\tools\verify-portal-menu-permissions-foundation.ps1
.\tools\check-portal-crosscutting-guardrails.ps1
.\tools\verify-portal-crosscutting-foundation.ps1
dotnet build backend/PortalCorporativo.sln
$env:DOTNET_ROLL_FORWARD='Major'; dotnet test backend/PortalCorporativo.sln --no-build
docker compose --env-file .env.example config
```

## Runtime Status

P5 does not execute real SMTP/SMS/push/email delivery. Runtime smoke checks remain NonProduction-only and require local untracked `.env`.
