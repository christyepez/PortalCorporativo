# Portal Operational SLO/SLA NonProduction

## Preliminary NonProduction SLOs

| Area | Target |
| --- | --- |
| Health response | `/health/ready` returns 200 during validation |
| Smoke | Existing-stack smoke succeeds |
| Rollback | Stack stops with no Portal containers running |
| Logs | Structured logs available locally in Seq and Compose logs |
| Correlation | `X-Correlation-ID` present in smoke/runtime flow |

## SLA status

No production SLA is defined in Sprint 19. NonProduction SLOs are operational validation targets only.

NonProductionSloSlaPrepared: true.
