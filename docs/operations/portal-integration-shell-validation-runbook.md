# Portal Integration Shell Validation Runbook

## Purpose

Validate that PortalCorporativo has a controlled Integration Shell / External Modules baseline without activating productive CRM or Financiero runtime coupling.

## Commands

Run from the repository root:

```powershell
git diff --check
dotnet build backend/PortalCorporativo.sln
$env:DOTNET_ROLL_FORWARD='Major'; dotnet test backend/PortalCorporativo.sln --no-build
docker compose --env-file .env.example config
.\tools\check-portal-guardrails.ps1
.\tools\preflight-portal-local.ps1
.\tools\verify-portal-foundation.ps1
.\tools\check-portal-auth-guardrails.ps1
.\tools\verify-portal-auth-foundation.ps1
.\tools\check-portal-menu-permissions-guardrails.ps1
.\tools\verify-portal-menu-permissions-foundation.ps1
.\tools\check-portal-crosscutting-guardrails.ps1
.\tools\verify-portal-crosscutting-foundation.ps1
.\tools\check-portal-integration-shell-guardrails.ps1
.\tools\verify-portal-integration-shell-foundation.ps1
```

## Manual checks

- Confirm no `.env` exists in the repository root.
- Confirm gateway settings do not include CRM, Financiero or financial routes.
- Confirm Docker Compose does not define CRM or Financiero services.
- Confirm no private URLs, real tokens, secrets or certificates are committed.

## Expected result

P6 passes when the contract is documented, existing Portal foundations are intact and external module runtime activation remains disabled.

## Rollback

If a guardrail fails, do not deploy. Remove the unsafe configuration, update the decision record and rerun all checks.
