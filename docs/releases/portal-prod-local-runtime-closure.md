# Portal PROD-local runtime closure

Date: 2026-09-17

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
- SQL Server, Redis, MinIO and Seq infrastructure.

CRM and Financiero APIs are internal to the Docker network; the Portal Gateway is the host-facing API boundary.

## Runtime verification on MarketingIndo

Observed runtime state:

- Portal Web health: HTTP 200.
- Gateway readiness: HTTP 200.
- CRM readiness through Gateway: HTTP 200.
- Financiero readiness through Gateway: HTTP 200.
- HistoriasPaolin readiness through Gateway: HTTP 200.
- CRM protected route without token: HTTP 401.
- Financiero protected route without token: HTTP 401.
- HistoriasPaolin protected route without token: HTTP 401.
- All Portal, CRM, Financiero and HistoriasPaolin containers were running with zero restarts.
- No recent fatal/unhandled/critical application errors were detected during the runtime stability scan.
- Portal Gateway, CRM and Financiero were running with `ASPNETCORE_ENVIRONMENT=Production` where applicable.
- CRM reported `LocalProduction` runtime with Portal and Financial integrations enabled.
- Financiero reported Portal Audit, Notification, Outbox and Configuration integrations enabled.

Commit `ff564d2d1ee7255c8abceed4a3d13caac8bdc2a4` records the authenticated PROD-local smoke including CRM, Financiero and HistoriasPaolin and states `PROD_LOCAL_SMOKE_PASS` on MarketingIndo.

Portal CI run #70 on the same commit completed successfully.

## Guardrails

This closure means local Production-mode deployment, not activation of irreversible external production integrations.

The following remain intentionally outside this objective:

- Real external/cloud IdP activation.
- Real production secrets or certificates committed to source control.
- Real SRI production transmission.
- Cloud production network endpoints or deployment approvals.

## Result

`PortalProdLocalObjectiveAchieved = true`

The Portal integrated local Production runtime objective is complete and operational on MarketingIndo.
