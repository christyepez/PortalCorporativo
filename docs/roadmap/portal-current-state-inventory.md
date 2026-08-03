# Portal Current State Inventory

## Repository Structure

- `backend/`: .NET solution `PortalCorporativo.sln`, API Gateway, transversal APIs, workers, building blocks and tests.
- `frontend/portal-angular/`: Angular shell intent documented, but only `README.md` exists; no `package.json` or buildable frontend was found.
- `docker-compose.yml`: root local compose for Portal services.
- `deploy/local/`: shared local workspace compose for Portal, CRM and Financiero.
- `scripts/`: local run/stop and Sprint 1 smoke scripts.
- `docs/`: architecture, security, coordination and local development documentation.
- `codex/`: architecture rules, reusable capabilities and task tracking.

## Backend Stack

- .NET 8.
- ASP.NET Core minimal APIs.
- Clean Architecture-style project layout per bounded capability.
- Entity Framework Core with SQL Server.
- YARP API Gateway.
- JWT bearer authentication and permission policy authorization.
- Seq logging integration through shared Portal foundation.

## Frontend Stack

- Intended stack: Angular Portal Shell.
- Current state: documented only under `frontend/portal-angular/README.md`.
- Build readiness: pending; no frontend package manifest was found.

## Docker / Compose

- Root compose includes `sqlserver`, `redis`, `minio`, `seq`, `security-api`, `configuration-api`, `menu-api`, `audit-api`, `notification-api`, workers, `catalog-api`, `content-api`, `integration-api`, `reporting-api` and `api-gateway`.
- `deploy/local/docker-compose.local.yml` documents a shared local SQL Server for Portal, CRM and Financiero with separate logical databases.
- Root `.env.example` contains placeholders only.

## Documentation Existing

Existing docs cover architecture, stack decisions, DDD model, security guidelines, data governance, local development, consumer onboarding, Sprint 1 closure and foundation dependencies.
