# Next Codex Task

## Repository

christyepez/PortalCorporativo

## Phase

Portal PROD-local Integrated Runtime - Consumer Expansion

## Objective Status

`PortalProdLocalObjectiveAchieved = true`
`PortalAngularSecurityMajorUpgradeClosed = true`

The integrated local runtime is healthy and the Angular 20 security migration is merged to `main`.

## Current Runtime Evidence

- Angular: 20.3.31.
- Angular CLI / build tooling: 20.3.37.
- TypeScript: 5.9.3.
- Angular security upgrade merged through PR #60.
- Portal CI #116: PASS.
- PROD-local full Docker rebuild: PASS.
- Authenticated PROD-local smoke: PASS.
- Drift check: PASS after baseline refresh.
- Runtime verify: PASS.
- Maintenance scan: PASS.
- Integrated containers remain at zero restarts.
- Current domain integrations through Gateway: CRM, Financiero, HistoriasPaolin and Talento Humano (AppTTHH).
- Primary runtime: Docker Desktop on device `trabajo`.
- `MarketingIndo` synchronization remains deferred while the device is offline.

## Next Gate

`PortalConsumerExpansionGate`

Onboard the next explicitly selected domain/application through the existing Portal consumer contract. Do not create a new transversal capability when Security, Menu, Configuration, Audit, Notification, Content, Catalog, Reporting, Integration, Gateway or the Angular Shell can be reused or extended.

For every new consumer, require:
- Gateway-only host-facing API exposure.
- JWT permission enforcement in backend.
- Menu and Configuration registration by module code.
- Correlation ID propagation.
- Domain-owned database with no cross-domain table sharing.
- Health/readiness endpoints and authenticated PROD-local smoke coverage.
- Docker Compose integration without breaking current services.
- Unit/integration tests appropriate to the consumer.
- Drift baseline refresh only after the runtime is validated.

## Guardrails

- Do not commit secrets, private production URLs, certificates or real data.
- Keep SRI real production transmission disabled until explicitly approved.
- Keep every domain database bounded by its own context.
- Use the Portal Gateway as the host-facing API boundary.
- Do not persist browser access tokens.
- Do not change cloud deployment; Docker Desktop on `trabajo` remains the primary runtime.
- Do not block work waiting for `MarketingIndo`; synchronize it later when available.

## Closure Expected

The next consumer is considered integrated only when build/tests, Compose, health, authenticated smoke, drift and maintenance all pass without regressions to CRM, Financiero, HistoriasPaolin or Talento Humano.
