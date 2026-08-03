# Portal Operational Metrics

## NonProduction minimum metrics

| Metric | Source | Target |
| --- | --- | --- |
| Gateway health | `/health/ready` | 200 |
| API health | service `/health/ready` | healthy |
| Worker health | worker `/health/ready` | healthy |
| Request failures | structured logs | reviewed manually |
| Smoke result | `scripts/smoke/sprint1-smoke.ps1` | success |
| Container state | `docker ps` / Compose | running or healthy during validation |

## Future metrics

Production metrics require a later gate with approved telemetry ownership, retention, alert routing and secret handling.

RealPrometheusGrafanaConfigured: false.
