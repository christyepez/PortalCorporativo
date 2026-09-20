# Current Codex Task

Title: Portal integrated functional gap review.

Status: COMPLETE on `trabajo`. `MarketingIndo` remains deferred and never blocks implementation.

Objective: identify unresolved functional/integration gaps, distinguish real defects from intentional external-production guardrails, and implement safe high-priority fixes.

Evidence: frontend placeholder test/lint scripts replaced with real Node contract tests, TypeScript no-emit validation and policy lint; 4/4 tests pass; production build passes; current PROD-local integration documentation aligned with CRM, Financiero, HistoriasPaolin and Talento Humano active behind the Gateway; gap review documented in `docs/roadmap/portal-functional-gap-review-2026-09-19.md`.

Guardrail: Integration transport, real notification providers, production OIDC/SSO, real SRI transmission and cloud activation remain disabled intentionally.
