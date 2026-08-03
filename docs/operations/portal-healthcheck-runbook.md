# Portal Health Check Runbook

## Local Gateway

Default placeholder gateway port in `.env.example` is `8082`.

Expected endpoints:

- `GET /health`
- `GET /health/live`
- `GET /health/ready`

## Command

```powershell
.\tools\check-portal-health.ps1 -BaseUrl http://localhost:8082
```

## P2 Status

HealthChecksValidated: PendingRuntime.

P2 validates the script and documents the endpoints. Actual runtime health is deferred until containers are started with a local untracked `.env`.
