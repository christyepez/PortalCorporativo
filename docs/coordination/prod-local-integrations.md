# PROD local integration roadmap

Status: implementation in progress through Portal Sprints 23-27.

## Objective
Run PortalCorporativo locally with `ASPNETCORE_ENVIRONMENT=Production` and expose integrated modules through the Portal API Gateway as the single HTTP entry point.

## Integrated modules

| Module | Gateway route | Runtime ownership | Host API exposure |
|---|---|---|---|
| Portal Core | `/api/security`, `/api/configuration`, `/api/menu`, `/api/audit`, `/api/notifications`, `/api/catalog`, `/api/content`, `/api/reporting`, `/api/integration` | Portal | Gateway only |
| CRM | `/api/crm/**` | CRM repo | Gateway only in PROD-local orchestrator |
| Financiero | `/api/financial/**` | Financiero repo | Gateway only in PROD-local orchestrator |
| HistoriasPaolin | `/api/historiaspaolin/**` | HistoriasPaolin repo | Gateway via opt-in network override |
| Talento Humano | pending | AppTTHH | not deployed |

## Runtime command

```powershell
Copy-Item .env.prod-local.example .env.prod.local
# Fill local-only values in .env.prod.local.
docker compose --env-file .env.prod.local -f docker-compose.yml -f docker-compose.prod-local.yml up -d --build
```

The default repository layout expects `PortalCorporativo`, `CRM` and `Financiero` as sibling folders. Override `CRM_REPO_PATH` and `FINANCIERO_REPO_PATH` when necessary.

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
