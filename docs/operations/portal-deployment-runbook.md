# Portal Deployment Runbook

## P1 Decision

ProductionActivationDecision: NoGo.

## Controlled Deployment Baseline Checklist

Before any non-production deployment baseline:

1. Confirm branch is based on GitHub `main`.
2. Confirm no `.env`, tokens, certificates, private URLs or real data are committed.
3. Validate `docker compose config` with non-secret placeholders or approved secret injection.
4. Build `backend/PortalCorporativo.sln`.
5. Run backend tests.
6. Start containers in a controlled local/non-production environment.
7. Validate Gateway and every API health endpoint.
8. Validate Security, Menu, Configuration, Audit and Notification smoke flows.
9. Confirm CRM and Financiero remain consumers only and do not share Portal databases.

## Rollback

Stop containers with `scripts/stop-local.ps1` or equivalent compose down command. Do not delete volumes unless explicitly required for local reset.

## Next Gate

`PortalSprintP2ControlledDeploymentBaseline`.
