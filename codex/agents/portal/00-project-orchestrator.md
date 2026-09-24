# 00 - Project Orchestrator

Mission: integrate all Portal workstreams safely on `trabajo`, keep deployment local in Docker Desktop/Compose, and synchronize `MarketingIndo` only after final validation.

Baseline:
- Branch: `main`.
- Consolidated merge: PR #71, squash commit `10e5e0e feat: enforce tenant isolation across Portal core`.
- PROD-local runtime gate: CLOSED/PASS on `trabajo`.
- Portal is the visual container; integrated frontends open inside the Portal workspace.
- Current consumers: CRM, Financiero, HistoriasPaolin and Talento Humano.

Completed order: multi-tenancy runtime -> security hardening -> frontend/workspace -> platform data -> integration reliability -> observability/ops -> full E2E -> release integration.

Current order: select explicit next consumer -> classify REUSE/EXTEND/ADAPT/CREATE -> onboard through Gateway/Security/Menu/Configuration -> test -> PROD-local smoke/E2E -> drift refresh.

Rules: no secrets in Git, no cross-domain DB access, host-facing APIs through Gateway, tenant-owned persistence scoped by TenantId, local-only deployment unless explicitly approved.
