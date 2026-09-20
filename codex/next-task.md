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
- Authenticated PROD-local smoke returns `PROD_LOCAL_SMOKE_PASS` on the primary device `trabajo` for CRM, Financiero, HistoriasPaolin and Talento Humano. `MarketingIndo` is synchronized only when available.
- Financiero JWT environment parity is merged in `f04d9783ca7dab6f852cb56f8d6110083da1931f`; 145/145 API tests passed and PR #68 CI succeeded.
- AppTTHH JWT environment parity is merged in `b9d4420d123973bc6896cd8aa0dd38f5a90bd0b2`.
- Closure: `docs/releases/portal-prod-local-runtime-closure.md`.

## Integrated Modules

- Portal Core APIs and Angular Shell.
- CRM via `/api/crm/**`.
- Financiero via `/api/financial/**`.
- HistoriasPaolin via `/api/historiaspaolin/**`.
- Talento Humano via `/api/hr/**`.

## Completed Gates

`DockerDesktopLocalRuntimeLifecycleHardening = COMPLETE`

`DockerDesktopLocalRuntimeBackupRecovery = COMPLETE`

`DockerDesktopLocalRuntimeMaintenanceAutomation = COMPLETE`

The local Docker Desktop lifecycle is hardened on `trabajo`; SQL backup/recovery is repeatable and verified; maintenance now checks backup freshness/integrity, retention, disk space and runtime health in one command.

## Next Gate

`DockerDesktopLocalRuntimeDriftDetection`

Add local drift detection on `trabajo`: validate expected repository revisions, Compose service/image topology, required environment variable names without reading secret values, runtime container/image identity and configuration-file hashes. Produce a baseline/report that can later be used when synchronizing `MarketingIndo`. External/cloud activation is not required.

## Guardrails

- Do not commit secrets, private production URLs, certificates or real data.
- Keep SRI real production transmission disabled until explicitly approved.
- Keep CRM/Financial databases bounded by their own contexts; no direct cross-domain DB coupling.
- Use the Portal Gateway as the host-facing API boundary.
- Do not persist browser access tokens.

## Closure Expected

The PROD-local objective remains the active operating model. Continue on `trabajo` with configuration/runtime drift detection and a reusable local baseline. Do not pause work when `MarketingIndo` is offline; synchronize only after a stable delivery is completed and the device is available. Cloud deployment is outside the current execution path.
