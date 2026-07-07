# Integration API

Gestiona apertura de recursos integrados y sesiones temporales de integración.

## Reliable messaging foundation

Incluye contratos y servicios de aplicación para SQL Outbox/Inbox, idempotencia, reintentos y DeadLetter. No expone enqueue público: los bounded contexts escriben su propio Outbox dentro de su transacción local y usan adaptadores internos.

El Worker está deshabilitado por defecto. El transporte `Log` sirve solo para desarrollo; Kafka, RabbitMQ y proveedores reales están diferidos.
