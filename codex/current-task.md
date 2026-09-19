# Current Codex Task

Title: Docker Desktop PROD-local lifecycle hardening.

Status: COMPLETE on `trabajo`. Unified up/status/restart/verify/down lifecycle is validated; `MarketingIndo` remains a deferred synchronization target and never blocks implementation.

Objective: operate Portal Core, CRM, Financiero, Talento Humano and HistoriasPaolin from the single `portalcorporativo` Docker Compose project.

Evidence: unified HistoriasPaolin services, shared Portal SQL/JWT/network, idempotent local lifecycle scripts, controlled service restart, zero unexpected restart counts and authenticated PROD-local smoke. HistoriasPaolin migration startup was reduced by prebuilding EF artifacts and using `--no-build` at runtime.

Guardrail: deployment remains local through Docker Desktop/Docker Compose; no cloud activation is required.
