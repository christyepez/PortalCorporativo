# Multi-tenancy contract

Portal resolves the effective tenant from the authenticated JWT and applies it as an isolation boundary across host-facing APIs.

## Resolution rules

1. The preferred JWT claim is `tenant_id`; the legacy `tenant` claim is accepted for compatibility.
2. `X-Tenant-ID` is optional. When present, it must match the authenticated tenant claim.
3. A non-default `X-Tenant-ID` without a tenant claim is rejected.
4. Tokens without a tenant claim remain backward-compatible with tenant `default`.
5. Tenant identifiers are normalized to lowercase and limited to letters, numbers, dot, underscore and hyphen, with a maximum length of 64 characters.
6. Request body or query-string tenant values never override the authenticated tenant context.

## Isolation coverage

The current local implementation enforces tenant isolation in:

- Security users, roles, permissions/resources and session revocation.
- Configuration reads, writes and precedence evaluation.
- Menu module/navigation reads.
- Notification templates and notification operations.
- Audit writes, searches and summaries.
- Integration Outbox/Inbox and idempotency lookup.
- Catalog entries, including tenant-scoped uniqueness for catalog + code.
- Content metadata/download/deactivation.
- Reporting execution context. Report definitions remain global; every execution receives the authenticated tenant.

Existing Catalog and Content rows are upgraded in place to tenant `default`; local database initialization is idempotent and does not require dropping the databases.

## Consumer rules

Domain applications must not choose another tenant by passing `tenantId` in a payload or query string. They authenticate with a token containing the correct tenant claim and let Portal resolve the effective tenant. A domain that needs cross-tenant administration must use an explicitly designed administrative capability rather than bypassing the tenant boundary.

All future persisted Portal capabilities must include tenant in their persistence key/filter before being exposed as multi-tenant. Unique indexes for tenant-owned data must include TenantId.

## Verification

The PROD-local E2E script creates two independent tenants and verifies that tenant B cannot read tenant A data across Security, Configuration, Notification, Catalog, Content, Audit and Integration. Reporting executions also verify that the returned execution context matches the authenticated tenant. A mismatched JWT tenant and `X-Tenant-ID` is expected to return HTTP 401.
