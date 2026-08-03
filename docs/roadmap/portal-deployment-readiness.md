# Portal Deployment Readiness

## Current Readiness

Deployment Readiness: NotReady.

## Validated

- GitHub `main` synchronized.
- Main base commit reviewed: `c9963b20020fc78014949cf3e29a58235ac260c6`.
- Backend solution builds successfully.
- Backend tests pass with `DOTNET_ROLL_FORWARD=Major`.
- `docker compose --env-file .env.example config` succeeds.
- Root compose uses one SQL Server container for Portal local services.

## Pending Before Controlled Deployment

- Confirm Docker runtime startup and service health with a local `.env` not committed to Git.
- Validate Gateway routing for every exposed API.
- Validate JWT issuer/audience/secret handling through a proper secret source.
- Validate SSO/OIDC production design; current runtime is JWT symmetric-key foundation.
- Validate Content/File, Catalog, Reporting and Integration production readiness.
- Define promotion strategy for environments beyond local development.
- Confirm health checks for all APIs use correct `/health`, `/health/live` and `/health/ready` semantics.

## Decision

Do not deploy to production from P1. Use P2 to create a controlled deployment baseline.
