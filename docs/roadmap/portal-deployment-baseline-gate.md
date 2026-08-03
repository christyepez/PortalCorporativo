# Portal Deployment Baseline Gate

## Gate Summary

Portal P2 approves a deployment baseline for controlled local/NonProduction validation. It does not approve production activation.

## Required Baseline

| Area | Decision |
| --- | --- |
| GitHub main source | Required |
| Single SQL Server container | Required |
| Separate Portal logical databases | Required |
| Real `.env` in Git | Forbidden |
| Secrets/tokens/certificates in Git | Forbidden |
| CRM direct coupling | Forbidden |
| Financiero direct coupling | Forbidden |
| Runtime production mode | Forbidden |

## Status

- Docker Compose config: Validated with `.env.example`.
- Backend build: Validated.
- Backend tests: Validated with roll-forward.
- Frontend build: Blocked; no package manifest exists.
- Docker runtime up: PendingValidation.
- Health checks: PendingRuntime.
- Smoke checks: PendingRuntime.

## Exit Criteria For P3

P3 may start with Auth/SSO/session baseline work, still NonProduction-only. Production remains blocked until runtime checks and security issuer strategy are complete.
