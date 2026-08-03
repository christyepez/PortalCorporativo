# Portal Notification Consumer Contract

## Purpose

Consumers request notification templates and messages through Portal Notification API. Portal owns delivery orchestration.

## P5 Supported Mode

- Development/log/internal providers only.
- No SMTP, SMS or push provider configured.
- No real email or push delivery.

## Required Metadata

- Template code.
- Channel requested by approved Portal configuration.
- Recipients appropriate for the selected development mode.
- Correlation ID.
- Idempotency key.

## Guardrails

- Consumers must not create their own global notification engine.
- No provider credentials in Git or configuration values.
- Real delivery requires a later production provider gate.
