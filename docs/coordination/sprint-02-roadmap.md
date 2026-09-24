# Sprint 2 — Roadmap de cierre

## Objetivo

Convertir foundations pendientes en capacidades consumibles sin ampliar PortalCorporativo con reglas de Financiero o CRM. El objetivo PROD-local quedó cerrado; la activación productiva externa conserva gates separados.

## Estado consolidado

| Orden | Paquete | Estado actual | Evidencia / gate |
|---:|---|---|---|
| 1 | IdP productivo/OIDC | EXTERNAL GATE | Boundary OIDC implementado; faltan inputs/aprobaciones de `ExternalProductionActivationInputs` |
| 2 | Revocación + JWT E2E | CLOSED | Revocación foundation y E2E HTTP validados |
| 3 | Catalog API Foundation | CLOSED | API, persistencia, tenant isolation y lifecycle E2E validados |
| 4 | Content/File Foundation | CLOSED | API, metadata, almacenamiento, tenant isolation y lifecycle E2E validados |
| 5 | Integration | CLOSED PROD-local | Outbox/Inbox, idempotencia, worker y transporte desacoplado validados |
| 6 | Notification productiva | EXTERNAL GATE | Foundation/worker cerrados; proveedor y secretos reales requieren activación explícita |
| 7 | Angular Shell | CLOSED | Angular 20, Menu/Configuration/Security y workspace integrados |
| 8 | Reporting Foundation | CLOSED | Contratos, autorización y ejecución controlada integrados |
| 9 | Audit retention jobs | CLOSED | Archive-before-purge transaccional con mínimo 365 días |
| 10 | Multi-tenancy | CLOSED PROD-local | Tenant context e aislamiento formal validados en E2E |

## Broker

Kafka o RabbitMQ es opcional y requiere ADR comparando volumen, operación, ordering, replay y costo. SQL Outbox continúa como fuente transaccional; introducir broker no habilita bases compartidas ni exactly-once.

## Criterios de aceptación

- Contratos versionados, ownership y clasificación aprobados antes del código.
- Autorización backend, auditoría, correlationId, health y logs incluidos.
- Persistencia y secretos aislados; sin acoplamiento a bases de consumidores.
- Pruebas unitarias, contrato, integración/E2E y smoke pasan.
- CRM/Financiero consumen por extensión/adaptación y no duplican plataforma.

## Riesgos

Alcance excesivo, selección prematura de broker/proveedor, PII en archivos/reportes, revocación inconsistente, complejidad multi-tenant y UI acoplada. Mitigar con paquetes verticales pequeños, ADRs y gates de QA/seguridad.
