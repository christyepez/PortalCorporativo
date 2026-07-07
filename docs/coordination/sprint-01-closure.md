# Sprint 1 Foundation — Cierre

- Estado: **Cerrado y aceptado**
- Fecha: 2026-07-06
- ADR: ADR-001 aceptado, sin contradicciones abiertas

## Resultado

Sprint 1 entregó una base transversal ejecutable: Gateway YARP, Security, Configuration, Menu, Audit, Notification, SQL Outbox/Inbox, Workers, health checks, logging estructurado y correlationId. Cada contexto conserva almacenamiento propio y autorización backend.

Validación final: build con 0 errores/0 warnings, 50/50 pruebas aprobadas y smoke integrado exitoso para Gateway, APIs, SQL, autorización, correlación y Notification LogDev en estado `Sent`.

## Clasificación de entrega

| Capacidad | Estado | Consumidores |
|---|---|---|
| Gateway | Lista | REUSE |
| Security | Foundation lista; IdP diferido | REUSE/EXTEND |
| Configuration / Menu | Foundation lista | EXTEND |
| Audit / Notification | Foundation lista | ADAPT |
| Outbox / Inbox | Foundation lista por bounded context | ADAPT/EXTEND |
| Workers | Foundation lista | EXTEND |
| Health / logs / correlación | Listos | REUSE |

## Límites aceptados

No incluye Catalog, Content/File, Reporting, Integration productiva, Angular Shell, IdP/OIDC productivo, broker, multi-tenant real, proveedor real de Notification ni purga automática de Audit. Estos límites no bloquean discovery de Financiero/CRM, pero sí el consumo de las capacidades pendientes.

## Evidencia

- Contratos: `docs/architecture/*contracts.md`.
- Seguridad: `docs/security/authorization-policy-matrix.md`.
- Onboarding: `docs/coordination/consumer-onboarding-guide.md`.
- Smoke repetible: `scripts/smoke/sprint1-smoke.ps1`.
- Roadmap: `docs/coordination/sprint-02-roadmap.md`.

## Decisión de coordinación

Sprint 1 queda cerrado sin bloqueos. El siguiente trabajo debe ser una de dos líneas explícitas: discovery de consumo en Financiero/CRM usando Portal-first, o inicio de Sprint 2 Portal. No se autoriza duplicar capacidades foundation en repositorios consumidores.
