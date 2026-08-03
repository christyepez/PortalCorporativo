# Portal Menu / Permissions Validation Runbook

## Purpose

Validate Menu, Permissions and Navigation baseline without activating production or external module navigation.

## Commands

```powershell
.\tools\check-portal-guardrails.ps1
.\tools\preflight-portal-local.ps1
.\tools\verify-portal-foundation.ps1
.\tools\check-portal-auth-guardrails.ps1
.\tools\verify-portal-auth-foundation.ps1
.\tools\check-portal-menu-permissions-guardrails.ps1
.\tools\verify-portal-menu-permissions-foundation.ps1
dotnet build backend/PortalCorporativo.sln
$env:DOTNET_ROLL_FORWARD='Major'; dotnet test backend/PortalCorporativo.sln --no-build
docker compose --env-file .env.example config
```

## Expected Result

- Menu foundation exists.
- Permission policies are centralized.
- Gateway route authorization exists.
- CRM/Financiero navigation contracts are preparation-only.
- Production remains NoGo.
