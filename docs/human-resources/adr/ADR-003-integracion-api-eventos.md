# ADR-003: Integración mediante APIs y eventos

- Estado: Proposed
- Fecha: 2026-07-30

## Contexto

Los módulos y sistemas externos requieren intercambiar información sin compartir bases ni crear transacciones distribuidas.

## Decisión

Usar APIs para operaciones síncronas y eventos para propagación asíncrona. Cada productor implementará Outbox local y cada consumidor Inbox para idempotencia.

## Consecuencias

- Menor acoplamiento.
- Trazabilidad y reintentos.
- Consistencia eventual.
- Necesidad de versionado, DeadLetter y reconciliación.

## Restricciones

- Correlation ID obligatorio.
- Eventos no exponen entidades internas completas.
- Integraciones críticas deben tener reconciliación.
- Ningún módulo escribe en la base de otro.
