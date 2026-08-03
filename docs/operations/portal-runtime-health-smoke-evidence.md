# Portal Runtime Health and Smoke Evidence

## Health evidence

| Check | Result |
| --- | --- |
| Docker Compose stack build/start | Passed |
| Docker healthy state for Gateway/APIs/workers | Passed |
| `GET /health/live` | 200 |
| `GET /health/ready` | 200 |
| `GET /health` | 404 |
| `X-Correlation-ID` response header on readiness | Present |
| Structured Gateway logs with `CorrelationId` | Present |
| Structured worker logs with `CorrelationId` | Present |

## Smoke evidence

| Check | Result |
| --- | --- |
| Smoke script invoked | Yes |
| Placeholder/local-only JWT secret used | Yes |
| Real secrets or certificates used | No |
| CRM/Financiero routes activated | No |
| Smoke result | Failed |
| Failure reason | SQL port already allocated during re-run and protected endpoint authorization failure. |

## Decision

Health and smoke are not approved for production. Runtime is partially validated for non-production only.
