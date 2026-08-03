# Portal Notification Provider Architecture

## Component separation

```mermaid
flowchart LR
  Consumer["Future consumers: CRM / Financiero"] --> Api["Portal Notification API"]
  Api --> Store["Portal Notification DB"]
  Worker["Notification Worker"] --> Store
  Worker --> Port["Notification Provider Port"]
  Port --> Dev["InternalDev / EmailDev / LogDev"]
  Port -. future .-> Real["SMTP / Email / SMS / Push / Webhook adapters"]
  Real -. future secrets .-> Secrets["Portal Secret Provider"]
```

## Responsibilities

| Component | Responsibility | Must not own |
| --- | --- | --- |
| Notification API | Accept requests, enforce permissions, create messages, apply idempotency | Provider credentials or external delivery |
| Notification Worker | Poll due messages, call provider port, apply retry and terminal status | Consumer domain logic |
| Provider adapter | Deliver one message through a configured channel | Templates, queue ownership or retry scheduling |
| Secret Provider | Resolve future provider credentials | Notification state |
| Consumers | Request notifications by contract | Global notification engine or provider credentials |

## Current providers

The current runtime uses development providers only:

- `InternalDev`.
- `EmailDev`.
- `LogDev`.

They must not send real email, SMS, push or webhook messages.

## Future adapters

Future adapters must be introduced behind an explicit provider gate and must use logical secret names only. Production delivery must remain disabled until provider evidence, rollback and operational ownership are approved.
