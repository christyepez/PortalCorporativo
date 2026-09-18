# Next Codex Task

## Repository

christyepez/PortalCorporativo

## Phase

Portal PROD-local Integrated Runtime - COMPLETE

## Current Branch

main

## Objective Status

`PortalProdLocalObjectiveAchieved = true`

The Portal functional foundation and the local Production-mode integrated runtime are complete. Portal Core, CRM, Financiero, Talento Humano and HistoriasPaolin run behind the Portal Gateway on the shared Docker network.

## Verified Evidence

- Portal Angular web health: PASS.
- Gateway readiness: PASS.
- CRM readiness through Gateway: PASS.
- Financiero readiness through Gateway: PASS.
- HistoriasPaolin readiness through Gateway: PASS.
- Talento Humano readiness through Gateway: PASS.
- Protected routes without token return 401 for CRM, Financiero, Talento Humano and HistoriasPaolin.
- Runtime stability scan: all integrated containers running with zero restarts and no recent fatal/unhandled/critical errors.
- CRM runtime: `Production` / `LocalProduction`, PortalIntegration enabled, FinancialIntegration enabled.
- Financiero runtime: `Production`, Portal Audit/Notification/Outbox/Configuration enabled.
- Authenticated PROD-local smoke returns `PROD_LOCAL_SMOKE_PASS` on both `trabajo` and `MarketingIndo` for CRM, Financiero, HistoriasPaolin and Talento Humano.
- Financiero JWT environment parity is merged in `f04d9783ca7dab6f852cb56f8d6110083da1931f`; 145/145 API tests passed and PR #68 CI succeeded.
- AppTTHH JWT environment parity is merged in `b9d4420d123973bc6896cd8aa0dd38f5a90bd0b2`.
- Closure: `docs/releases/portal-prod-local-runtime-closure.md`.

## Integrated Modules

- Portal Core APIs and Angular Shell.
- CRM via `/api/crm/**`.
- Financiero via `/api/financial/**`.
- HistoriasPaolin via `/api/historiaspaolin/**`.
- Talento Humano via `/api/hr/**`.

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

No additional sprint is required for the current objective. The Portal PROD-local integrated runtime is complete and operational on both `MarketingIndo` and `trabajo`, with full authenticated smoke evidence on each machine. The next executable preparation is the external production activation preflight in `scripts/production/validate-activation-inputs.ps1`; real activation remains blocked until approved external inputs are supplied.
