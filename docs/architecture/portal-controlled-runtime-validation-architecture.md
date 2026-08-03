# Portal Controlled Runtime Validation Architecture

## Runtime boundary

Sprint 9 validates PortalCorporativo as a local non-production runtime stack. The stack remains self-contained and does not enable CRM or Financiero runtime coupling.

## Components validated

- API Gateway.
- Security API.
- Configuration API.
- Menu API.
- Audit API.
- Notification API.
- Catalog API.
- Content API.
- Integration API.
- Reporting API.
- Notification Worker.
- Integration Worker.
- Common SQL Server container.
- Redis.
- Seq.
- MinIO.

## Health contract observed

The runtime exposes `/health/live` and `/health/ready` successfully through the Gateway. The generic `/health` route currently returns 404, so the health contract is not complete for production monitoring.

## Observability

Structured JSON logs are emitted by Gateway and workers. Correlation IDs appear in response headers and logs.

## Architecture decision

The Portal baseline can continue to the frontend shell buildability baseline, but cannot be promoted to production until health endpoint normalization, smoke hardening and production provider decisions are closed.
