# Current Codex Task

Title: Unified Docker Desktop PROD-local orchestration.

Status: implemented and validated on `trabajo`, which is the primary execution environment. `MarketingIndo` replication is deferred and must not block implementation when that device is offline.

Objective: operate Portal Core, CRM, Financiero, Talento Humano and HistoriasPaolin from the single `portalcorporativo` Docker Compose project.

Evidence: unified HistoriasPaolin services, shared Portal SQL/JWT/network, local lifecycle scripts and authenticated PROD-local smoke.

Guardrail: deployment remains local through Docker Desktop/Docker Compose; no cloud activation is required.
