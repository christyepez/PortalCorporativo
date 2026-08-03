# Portal External Consumer Audit Configuration Notification Contract

## Audit

Consumers must send audit-relevant events through Portal Audit contracts or approved adapters. They must not write directly into Portal Audit tables.

Required inputs:

- event name.
- actor context.
- resource key.
- correlation id.
- PII/redaction notes.

## Configuration

Consumers may define configuration keys by module scope. Configuration values must not contain secrets.

Required inputs:

- key.
- scope.
- default value when safe.
- owner.
- change impact.

## Notification

Consumers request notifications through Portal Notification contracts. They must not own global provider credentials or direct delivery providers.

Required inputs:

- template code.
- event intent.
- recipients model.
- idempotency key rule.
- correlation id.

## Sprint 16 status

ConsumerAuditConfigurationNotificationContractPrepared: true.
