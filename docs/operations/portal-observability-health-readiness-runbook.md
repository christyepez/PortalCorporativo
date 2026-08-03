# Portal Observability / Health / Readiness Runbook

## Observability baseline

- Structured logs are sent to Seq through `Seq:ServerUrl`.
- `X-Correlation-ID` is propagated by Portal building blocks.
- Services expose health endpoints through the common foundation.

## Health endpoints

- `/health`: general health endpoint.
- `/health/live`: process liveness.
- `/health/ready`: readiness for traffic.

## Dependencies to observe

- SQL Server: persistent platform databases.
- Redis: cache/session-ready dependency when enabled.
- MinIO: object storage baseline.
- Seq: structured logs.
- Notification worker.
- Integration worker.
- API Gateway and Portal APIs.

## Validation

Use `tools/check-portal-health.ps1` only against an approved local runtime. P7 does not require Docker runtime startup.

## Production notes

Production observability requires dashboards, alerts, retention policy, incident owners and secret-safe log redaction before activation.
