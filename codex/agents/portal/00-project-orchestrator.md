# 00 - Project Orchestrator

Mission: integrate all Portal workstreams safely on `trabajo`, keep deployment local in Docker Desktop/Compose, and synchronize `MarketingIndo` only after final validation.

Baseline:
- Branch: `feat/local-multitenancy-context`
- Last consolidated commit: `a4a566f feat: enforce tenant isolation across Portal core`
- Integration reliability baseline: `721c88f`
- Portal is the visual container; integrated frontends open inside the Portal workspace.
- AppCondominio uses 4210 because 4208 belongs to PanelPresupuesto.

Order: multi-tenancy runtime -> security hardening -> frontend/workspace -> platform data -> integration reliability -> observability/ops -> full E2E -> release/sync.

Rules: no secrets in Git, no cross-domain DB access, host-facing APIs through Gateway, tenant-owned persistence scoped by TenantId, local-only deployment unless explicitly approved.
