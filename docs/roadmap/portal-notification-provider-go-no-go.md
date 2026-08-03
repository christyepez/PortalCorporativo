# Portal Notification Provider Go/No-Go

## Current decision

`NoGo` for production notification providers.

## Go conditions for a future gate

- Approved provider selection.
- Secret Provider runtime active and reviewed.
- Provider credentials resolved by logical name only.
- No provider credentials committed to Git.
- Delivery audit and correlation policy validated.
- Retry, backoff, idempotency and dead-letter behavior validated.
- Manual evidence for email, SMS, push or webhook test environments.
- Explicit rollback plan.

## NoGo conditions in Sprint 15

- Real SMTP configured: false.
- Real email provider configured: false.
- Real SMS provider configured: false.
- Real push provider configured: false.
- Real webhook provider configured: false.
- Real provider credentials present: false.
- Real sending enabled: false.
- External API calls enabled: false.
- Production activation decision: NoGo.

## Production statement

Portal is not production-ready for real notification delivery.
