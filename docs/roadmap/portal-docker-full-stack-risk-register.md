# Portal Docker Full Stack Risk Register

| Risk | Impact | Status | Mitigation |
| --- | --- | --- | --- |
| Local port collisions | Docker startup can fail on developer machines. | Controlled | `.env.example` exposes parametrized ports for SQL Server, Redis, MinIO, Seq and Gateway. |
| Existing stack uses different local JWT secret | Smoke protected endpoints can return 401/403. | Accepted | Sprint 11/12 treat 401/403 as valid protected behavior for reused stacks. |
| Startup logs include framework warnings | Noise can obscure real runtime failures. | Monitored | Sprint 12 reviews logs for critical failures, unhandled exceptions and fatal errors. |
| Full stack validation is NonProduction-only | Production readiness may be overestimated. | Controlled | Go/NoGo keeps `PortalProductionReady: false`. |
| CRM/Financiero compose coupling appears accidentally | Portal would stop being a reusable platform boundary. | Guarded | Sprint 12 guardrail checks compose for consumer services and shared coupling terms. |
