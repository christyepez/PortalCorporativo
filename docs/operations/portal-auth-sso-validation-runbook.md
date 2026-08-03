# Portal Auth / SSO Validation Runbook

## Purpose

Validate the Auth/SSO/session baseline without activating production.

## Commands

```powershell
.\tools\check-portal-guardrails.ps1
.\tools\preflight-portal-local.ps1
.\tools\verify-portal-foundation.ps1
.\tools\check-portal-auth-guardrails.ps1
.\tools\verify-portal-auth-foundation.ps1
dotnet build backend/PortalCorporativo.sln
$env:DOTNET_ROLL_FORWARD='Major'; dotnet test backend/PortalCorporativo.sln --no-build
docker compose --env-file .env.example config
```

## Runtime Checks

Runtime Auth checks are deferred until containers are started with a local untracked `.env`. P3 does not configure an OIDC production provider and does not test real SSO.

## Expected P3 Output

- JWT foundation present.
- Permission policies present.
- No production OIDC provider.
- No real tokens/secrets/certificates/private URLs.
- No browser-readable token storage.
