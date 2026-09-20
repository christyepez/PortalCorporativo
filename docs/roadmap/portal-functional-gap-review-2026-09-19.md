# Portal Functional / Integration Gap Review

Date: 2026-09-19
Primary runtime: `trabajo` / Docker Desktop

## Summary

The current PROD-local runtime is functionally integrated for Portal Core, CRM, Financiero, HistoriasPaolin and Talento Humano. The review found no safe reason to enable external/cloud providers. The highest-priority actionable gaps were frontend quality placeholders and stale active documentation.

## Resolved in this gate

| Gap | Severity | Resolution |
|---|---|---|
| Frontend `test` script was a structural placeholder | High | Replaced with Node's real test runner and shell contract tests |
| Frontend `lint` script was a placeholder | High | Replaced with TypeScript `--noEmit` plus policy lint |
| PROD-local integration roadmap still showed TTHH pending and older startup commands | Medium | Updated to the current unified lifecycle and `/api/hr/**` |
| Production-readiness checklist could be read as saying local domain routes are disabled | Medium | Clarified local PROD active vs external/cloud production disabled |

## Intentional guardrails — not defects
| Item | Status | Reason |
|---|---|---|
| Integration worker transport | Disabled | No approved external transport is required for the validated local runtime |
| Real notification providers | Disabled | Prevents external side effects; dev/log providers remain the safe baseline |
| Production OIDC/SSO | Disabled | No approved external identity/provider credentials are part of the local target |
| Real SRI transmission | Disabled | Explicit project guardrail; requires separate user approval |
| Cloud secret provider / cloud activation | Disabled | Current operating target is Docker Desktop local |

## Historical documentation

Many sprint/roadmap documents intentionally describe earlier states where CRM/Financiero navigation or runtime coupling was disabled. These are retained as historical evidence and should not be rewritten as if those gates never existed. Current-state operational documents and `codex/next-task.md` are authoritative for the active runtime.

## Validation

- Frontend shell contract tests: 4/4 pass.
- TypeScript no-emit validation: pass.
- Frontend policy lint: pass.
- Existing Portal CI continues to build/test/lint frontend and build/test backend.

## Next focus

Expand current-state quality coverage where it materially protects integration behavior, while preserving the external-production guardrails above.
