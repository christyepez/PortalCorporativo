# Portal Deployment Baseline Architecture

## Deployment Shape

Portal local/NonProduction deployment is composed around:

- one SQL Server container named `sqlserver`;
- separate logical Portal databases per capability;
- Redis for local cache/queue support;
- MinIO for local object-storage-compatible development;
- Seq for structured logs;
- Portal APIs and workers;
- API Gateway exposed on the configured local port.

## Boundaries

CRM and Financiero remain consumers. They must not share Portal databases, embed Portal runtime code, or require direct Portal database access.

## Security

P2 keeps production disabled. JWT symmetric-key development configuration is not an SSO/OIDC production decision. Secrets are injected only through local untracked configuration or approved secret stores in later gates.

## Observability

Structured logging targets Seq in local compose. Correlation ID propagation remains part of the Portal foundation and must be preserved in later runtime checks.

## Next Architecture Gate

`PortalSprintP3AuthSsoSessionBaseline` must validate Auth/SSO/session boundaries before production consideration.
