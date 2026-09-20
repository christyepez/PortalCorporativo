# Current Codex Task

Title: Docker Desktop PROD-local synchronization package.

Status: COMPLETE on `trabajo`. `MarketingIndo` remains deferred and never blocks implementation.

Objective: prepare a non-secret, reusable synchronization package and safe preflight/application flow so `MarketingIndo` can later align with the authoritative `trabajo` runtime.

Evidence: package generated in `config/prod-local-sync-package.json`; local target preflight returned `PORTAL_PROD_LOCAL_SYNC_PREFLIGHT_PASS`; package records exact external repo revisions, required local file/env names, baseline hash and expected services; apply flow is guarded by `-Apply`, requires clean repositories and allows only fast-forward operations.

Guardrail: no secret values or backup payloads are included; no reset/force Git operation is used; `MarketingIndo` is not required to be online until synchronization is actually executed.
