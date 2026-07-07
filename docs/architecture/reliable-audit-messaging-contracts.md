# Reliable Audit, Outbox e Inbox

## Audit

Consumidores llaman `POST /api/audit/events` mediante Gateway con JWT y `correlationId`. El payload admite before/after/metadata JSON, pero secretos, tokens e identificadores personales configurados se reemplazan por `[REDACTED]`. Audit es append-only y conserva 365 días en línea.

## Outbox

Cada bounded context persiste `OutboxMessage` en su propia base y en la misma transacción del cambio de negocio. Usa `IntegrationEventEnvelopeV1`, `eventType` versionado, `correlationId` e `idempotencyKey`. La entrega es al menos una vez; consumidores deben ser idempotentes.

Estados: `Pending -> Processing -> Processed`; los fallos pasan a `Failed` con backoff y finalmente `DeadLetter`. No se publica desde controladores.

## Inbox

Cada adaptador registra entradas antes de ejecutar efectos. La restricción única `(tenantId, source, idempotencyKey)` evita reprocesamiento. Solo después de completar el efecto se marca `Processed`.

## Consumidores

- CRM y Financiero adaptan Audit API; no acceden a su base.
- CRM y Financiero mantienen Outbox propio y pueden reutilizar contratos/building blocks.
- Integraciones entrantes usan Inbox por adaptador.
- No existen Kafka, RabbitMQ ni conectores externos en Sprint 1.

## Diferido

Broker productivo, Inbox Worker especializado, leasing distribuido robusto, archivo/purga Audit y dashboards operativos quedan para Sprint 2 o posteriores.
