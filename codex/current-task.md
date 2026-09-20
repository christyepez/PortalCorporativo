# Current Codex Task

Title: Docker Desktop PROD-local drift detection.

Status: COMPLETE on `trabajo`. `MarketingIndo` remains deferred and never blocks implementation.

Objective: detect configuration/runtime drift using a reusable non-secret baseline for external repository revisions, Compose hashes, required environment variable names, service topology and runtime image identities.

Evidence: baseline created in `config/prod-local-baseline.json`; drift check returned `PORTAL_PROD_LOCAL_DRIFT_CHECK_PASS`; the daily maintenance command now includes drift detection and returned `PORTAL_PROD_LOCAL_MAINTENANCE_PASS`, `PORTAL_PROD_LOCAL_VERIFY_PASS` and `PROD_LOCAL_SMOKE_PASS` with zero restarts.

Guardrail: no environment values are stored, Portal self-revision is neutralized to avoid false drift after each PR, and execution remains local on Docker Desktop.
