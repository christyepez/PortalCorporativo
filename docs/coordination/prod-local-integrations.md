# PROD local integration roadmap

Status: COMPLETE and validated on the primary `trabajo` Docker Desktop runtime.

## Objective
Run PortalCorporativo locally with `ASPNETCORE_ENVIRONMENT=Production` and expose integrated modules through the Portal API Gateway as the single HTTP entry point.

## Integrated modules

| Module | Gateway route | Runtime ownership | Host API exposure |
|---|---|---|---|
| Portal Core | `/api/security`, `/api/configuration`, `/api/menu`, `/api/audit`, `/api/notifications`, `/api/catalog`, `/api/content`, `/api/reporting`, `/api/integration` | Portal | Gateway only |
| CRM | `/api/crm/**` | CRM repo | Gateway only in PROD-local orchestrator |
| Financiero | `/api/financial/**` | Financiero repo | Gateway only in PROD-local orchestrator |
| HistoriasPaolin | `/api/historiaspaolin/**` | HistoriasPaolin repo | Gateway only in unified PROD-local orchestrator |
| Talento Humano | `/api/hr/**` | AppTTHH repo | Gateway only in PROD-local orchestrator |

## Runtime command

```powershell
./scripts/local/prod-local-up.ps1 -Build
./scripts/local/prod-local-status.ps1
./scripts/local/prod-local-verify.ps1 -ScanLogs
```

The default repository layout expects `PortalCorporativo`, `CRM`, `Financiero`, `AppTTHH` and `HistoriasPaolin_PORTAL_PROD` as sibling folders. Override the corresponding `*_REPO_PATH` variables only when necessary.

## Security boundary

- Gateway is the only host-facing API entry point for CRM and Financiero.
- Gateway requires a valid Portal JWT for business routes.
- Health routes are intentionally anonymous.
- Financiero validates the same Portal issuer/audience/signing key and permission claims internally.
- CRM remains foundation-oriented; in PROD local it is network-internal and protected by the Gateway boundary.
- No browser token persistence is introduced.

## External production guardrails

Local PROD does not enable real cloud/Internet production dependencies. SRI real send, external notification providers, production OIDC credentials, cloud secret providers and other irreversible external actions remain disabled.

## Smoke

After the stack becomes healthy:

```powershell
$env:JWT_SECRET = '<same local secret used by compose>'
./scripts/smoke/prod-local-smoke.ps1
```

Expected marker: `PROD_LOCAL_SMOKE_PASS`.

## Completion gate

- Base Portal CI green.
- PROD-local compose config valid.
- All containers healthy.
- Gateway, CRM and Financiero health return 200 through Gateway.
- CRM and Financiero business endpoints return 401 without token.
- Shared local Portal JWT reaches CRM and Financiero through Gateway.
- No direct CRM/Financiero host API port in the unified PROD-local orchestrator.
