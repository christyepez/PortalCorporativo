# Portal Health Smoke Evidence

## Health

- GenericHealthEndpointValidated: true.
- LiveHealthEndpointValidated: true.
- ReadyHealthEndpointValidated: true.
- `GET /health`: 200.
- `GET /health/live`: 200.
- `GET /health/ready`: 200.

## Runtime Docker

- RuntimeDockerUpValidated: true.
- Docker Compose full stack reached running/healthy state for Gateway, APIs, workers, SQL Server and Redis.
- Seq and MinIO started for local infrastructure.

## Smoke

- SmokeTestsValidated: true.
- SmokeTestsBlockedReason: none.
- CleanStackSmokeValidated: true.
- ExistingStackSmokeValidated: true.
- ProtectedEndpointSmokeHandled: true.

## Rollback

- RollbackStopValidated: true.
- Command used: `docker compose --env-file .env.example down`.
- Destructive cleanup used: false.
- Volume deletion used: false.
