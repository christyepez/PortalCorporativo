# Portal Operational Health Monitoring

## Endpoints

| Endpoint | Purpose |
| --- | --- |
| `/health` | General service health |
| `/health/live` | Process liveness |
| `/health/ready` | Traffic readiness |

## Validation command

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\check-portal-health.ps1 -BaseUrl http://localhost:8082
```

## Review expectations

- GenericHealthEndpointValidated: true.
- LiveHealthEndpointValidated: true.
- ReadyHealthEndpointValidated: true.
- LocalSeqObservabilityValidated: true.
