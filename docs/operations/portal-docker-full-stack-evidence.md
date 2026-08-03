# Portal Docker Full Stack Evidence

## Docker Compose

- `docker compose --env-file .env.example config`: passed.
- `docker compose --env-file .env.example up -d --build`: passed.
- `docker compose --env-file .env.example ps`: required services reached running or healthy state.

## Required services

- sqlserver: validated.
- seq: validated.
- security-api: validated.
- configuration-api: validated.
- menu-api: validated.
- audit-api: validated.
- notification-api: validated.
- notification-worker: validated.
- api-gateway: validated.

## Health

- `GET /health`: 200.
- `GET /health/live`: 200.
- `GET /health/ready`: 200.

## Smoke

- Clean-stack smoke: passed.
- Existing-stack smoke: passed.
- Protected endpoint smoke: passed with protected behavior accepted for 401/403.

## Logs

- Startup logs reviewed.
- CriticalRuntimeErrorsDetected: false.

## Frontend

- `npm run build`: passed.
- `npm run test`: passed.
- `npm run lint`: passed.

## Guardrails

- No real secrets or certificates.
- No real `.env` committed.
- No CRM or Financiero runtime coupling.
- No production activation.
