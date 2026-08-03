# Portal Smoke Test Runbook

## Scope

Smoke checks are local/NonProduction-only. They must use documented local endpoints and development tokens only.

## Current Smoke Script

- `scripts/smoke/sprint1-smoke.ps1`

## Sequence

1. Create local `.env` from `.env.example`.
2. Replace placeholders locally.
3. Start Portal with Docker Compose.
4. Run health checks.
5. Run the smoke script.

## P2 Status

SmokeTestsValidated: PendingRuntime.

No production smoke, CRM runtime smoke or Financiero runtime smoke is approved in P2.
