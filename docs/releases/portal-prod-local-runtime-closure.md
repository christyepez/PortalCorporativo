# Portal PROD-local runtime closure

Date: 2026-09-18

## Objective

Run the Portal Corporativo locally with Production runtime behavior and the integrated modules behind a single Gateway boundary.

## Integrated runtime

The validated local runtime includes:

- Portal Angular web shell.
- Portal API Gateway.
- Security, Configuration, Menu, Audit, Notification, Catalog, Content/File, Reporting and Integration services.
- CRM through `/api/crm/**`.
- Financiero through `/api/financial/**`.
- HistoriasPaolin through `/api/historiaspaolin/**`.
- Talento Humano (AppTTHH) through `/api/hr/**`.
- SQL Server, Redis, MinIO and Seq infrastructure.

CRM and Financiero APIs are internal to the Docker network; the Portal Gateway is the host-facing API boundary.

## Runtime verification on MarketingIndo and trabajo

Observed runtime state:

- Portal Web health: HTTP 200.
- Gateway readiness: HTTP 200.
- CRM readiness through Gateway: HTTP 200.
- Financiero readiness through Gateway: HTTP 200.
- HistoriasPaolin readiness through Gateway: HTTP 200.
- Talento Humano readiness through Gateway: HTTP 200.
- Protected routes without token return HTTP 401 for CRM, Financiero, HistoriasPaolin and Talento Humano.
- Protected routes with the Portal JWT return HTTP 200 for CRM, Financiero, HistoriasPaolin and Talento Humano.
- The full smoke finishes with `PROD_LOCAL_SMOKE_PASS` on both `MarketingIndo` and `trabajo`.
- Portal Gateway and integrated domain APIs run with Production runtime behavior where applicable.
- CRM reports `LocalProduction` runtime with Portal and Financial integrations enabled.
- Financiero runs with Portal Audit, Notification, Outbox and Configuration integrations enabled.
- Financiero main `f04d9783ca7dab6f852cb56f8d6110083da1931f` includes standard Portal JWT environment fallback; 145/145 API tests passed and PR #68 CI succeeded.
- AppTTHH main `b9d4420d123973bc6896cd8aa0dd38f5a90bd0b2` includes the same standard Portal JWT environment compatibility.

## Guardrails

This closure means local Production-mode deployment, not activation of irreversible external production integrations.

The following remain intentionally outside this objective:

- Real external/cloud IdP activation.
- Real production secrets or certificates committed to source control.
- Real SRI production transmission.
- Cloud production network endpoints or deployment approvals.

## Result

`PortalProdLocalObjectiveAchieved = true`

The Portal integrated local Production runtime objective is complete and operational on both `MarketingIndo` and `trabajo`.
