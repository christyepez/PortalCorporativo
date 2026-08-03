# Portal Docker Full Stack Runtime Architecture

## Runtime boundary

Portal Corporativo owns the reusable platform runtime. Sprint 12 validates only Portal services and shared local infrastructure required by the Portal stack.

## Infrastructure

- One SQL Server container for Portal databases.
- Redis for local platform dependencies.
- Seq for structured logging.
- MinIO placeholder for content/file infrastructure readiness.

## Portal services

- API Gateway.
- Security API.
- Configuration API.
- Menu API.
- Audit API.
- Notification API.
- Notification Worker.
- Additional Portal APIs and workers may start with the full compose.

## Consumer boundaries

CRM and Financiero are consumers. They are not part of Portal Sprint 12 runtime validation and must not be added to the Portal compose.

## Health contract

The Gateway exposes:

- `/health`
- `/health/live`
- `/health/ready`

All three endpoints must return 200 in controlled NonProduction runtime validation.
