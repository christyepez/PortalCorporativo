# Portal Configuration Consumer Contract

## Purpose

Consumers read and extend centralized Portal configuration by module/tenant/user metadata.

## Scopes

- Global
- Tenant
- Module
- User

## Guardrails

- Do not store secrets in configuration values.
- Use relative module identifiers, not private URLs.
- Consumers may cache non-sensitive effective values only according to a future cache policy.
- Use Gateway and Portal configuration permissions.
