# Current Codex Task

Title: Portal frontend quality coverage expansion.

Status: COMPLETE on `trabajo`. `MarketingIndo` remains deferred and never blocks implementation.

Objective: expand real frontend regression coverage around the integrated shell and remove duplicated readiness state.

Evidence: shell contract suite expanded to 8/8 passing tests covering integrated domain routes, route uniqueness, `/api` boundary, environment contract, production readiness, output hashing, accessibility invariants and browser token persistence guardrails; Angular production build and TypeScript/policy lint pass; `environment.shellReadiness` is now the single source of truth; `portal-web` rebuilt in Docker Desktop and PROD-local maintenance/drift/smoke all pass.

Guardrail: no external/cloud provider activation was introduced; real SRI, OIDC/SSO, external notifications and integration transport remain disabled.
