# Next Codex Task

## Repository

christyepez/PortalCorporativo

## Phase

Portal PROD-local Integrated Runtime - COMPLETE

## Current Branch

main

## Objective Status

`PortalProdLocalObjectiveAchieved = true`

The Portal functional foundation and the local Production-mode integrated runtime are complete. Portal Core, CRM, Financiero and HistoriasPaolin run behind the Portal Gateway on the shared Docker network.

## Verified Evidence

- Portal Angular web health: PASS.
- Gateway readiness: PASS.
- CRM readiness through Gateway: PASS.
- Financiero readiness through Gateway: PASS.
- HistoriasPaolin readiness through Gateway: PASS.
- Protected routes without token return 401 for CRM, Financiero and HistoriasPaolin.
- Runtime stability scan: all integrated containers running with zero restarts and no recent fatal/unhandled/critical errors.
- CRM runtime: `Production` / `LocalProduction`, PortalIntegration enabled, FinancialIntegration enabled.
- Financiero runtime: `Production`, Portal Audit/Notification/Outbox/Configuration enabled.
- Commit `ff564d2d1ee7255c8abceed4a3d13caac8bdc2a4`: authenticated PROD-local smoke including HistoriasPaolin with `PROD_LOCAL_SMOKE_PASS` on MarketingIndo.
- Portal CI run #70 on that commit: success.
- Closure: `docs/releases/portal-prod-local-runtime-closure.md`.

## Integrated Modules

- Portal Core APIs and Angular Shell.
- CRM via `/api/crm/**`.
- Financiero via `/api/financial/**`.
- HistoriasPaolin via `/api/historiaspaolin/**`.

## Next Gate

`ExternalProductionActivationInputs`

This gate is outside the achieved PROD-local objective. It applies only when moving from local Production-mode execution to external/cloud production activation.

Required external inputs include approved OIDC/OAuth2 IdP configuration, secret provider/rotation ownership, production providers, production network endpoints and deployment approvals.

## Guardrails

- Do not commit secrets, private production URLs, certificates or real data.
- Keep SRI real production transmission disabled until explicitly approved.
- Keep CRM/Financial databases bounded by their own contexts; no direct cross-domain DB coupling.
- Use the Portal Gateway as the host-facing API boundary.
- Do not persist browser access tokens.

## Closure Expected

No additional sprint is required for the current objective. The Portal PROD-local integrated runtime is complete and operational on MarketingIndo.
