# Portal Current Architecture

Portal Corporativo is structured as a transversal platform. It provides reusable platform capabilities instead of domain-specific CRM or Financiero logic.

## Backend

- API Gateway: `backend/api-gateway/src/Portal.ApiGateway`.
- Building blocks: `backend/building-blocks/src/Portal.BuildingBlocks`.
- Security API: users, roles, permissions and protected resources.
- Configuration API: scoped/effective configuration.
- Menu API: dynamic menu items filtered through backend permission checks.
- Audit API: audit event recording and query.
- Notification API: templates, send/schedule/status/retry/cancel.
- Catalog, Content, Reporting and Integration APIs: project foundations present.
- Workers: Notification and Integration workers.

## Security Boundary

APIs use JWT bearer authentication and `AddPortalPermissionAuthorization`. Production SSO/OIDC is not validated in P1 and remains pending.

## Data Boundary

Portal uses logical databases per platform capability in the local SQL Server container. CRM and Financiero must use their own databases and must not share Portal tables.

## Integration Boundary

Consumers integrate through Gateway and published contracts. Portal must not embed CRM or Financiero domain behavior.

## Observability

Seq is configured for local structured logging. Correlation support is provided through shared foundation behavior.
