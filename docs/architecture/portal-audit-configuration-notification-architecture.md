# Portal Audit / Configuration / Notification Architecture

## Crosscutting Flow

```mermaid
flowchart LR
  Consumer["CRM / Financiero / future modules"] --> Gateway["API Gateway"]
  Gateway --> Audit["Audit API"]
  Gateway --> Config["Configuration API"]
  Gateway --> Notify["Notification API"]
  Notify --> Worker["Notification Worker"]
  Gateway --> Correlation["CorrelationId middleware"]
  Correlation --> Seq["Seq structured logs"]
```

## Current Implementation

- Audit API persists append-only audit logs with redaction behavior in the domain.
- Configuration API resolves scoped values by global, tenant, module and user metadata.
- Notification API stores templates/messages and uses development providers.
- Notification worker processes pending messages from Portal Notification database.
- Integration worker is present and disabled by default.
- Building blocks add structured logging, Seq sink and correlation ID middleware.

## Consumer Boundary

Consumers must call Portal APIs through Gateway and include correlation context. They must not share Portal databases, duplicate notification delivery engines or store crosscutting configuration secrets in their own domain runtime.
