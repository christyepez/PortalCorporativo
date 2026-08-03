# Portal Audit Consumer Contract

## Purpose

Consumers submit audit events through Portal Audit API. They do not write to `PortalAudit` directly.

## Required Metadata

- `actorId`
- `tenantId`
- `resource`
- `action`
- `correlationId`
- `severity`
- allowlisted `before`, `after` and `metadata` payloads

## Guardrails

- No secrets, tokens, certificates or unnecessary PII.
- No direct database writes.
- Events are append-only from the consumer perspective.
- Use Gateway and Portal permission `portal.audit.write`.
