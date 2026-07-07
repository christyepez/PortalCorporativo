# Sprint 2 — Roadmap propuesto

## Objetivo

Convertir foundations pendientes en capacidades consumibles de producción sin ampliar PortalCorporativo con reglas de Financiero o CRM.

## Orden recomendado

| Orden | Paquete | Resultado mínimo | Dependencias |
|---:|---|---|---|
| 1 | IdP productivo/OIDC | Login y emisión confiable; claims y rotación de claves | Security, Gateway |
| 2 | Revocación + JWT E2E | Revocación/versionado de permisos y pruebas HTTP reales | IdP, policies |
| 3 | Catalog API Foundation | Catálogos versionados, publicación y permisos | Security, Audit |
| 4 | Content/File Foundation | Metadata, almacenamiento por adaptador, antivirus/limits definidos | Security, Audit, MinIO |
| 5 | Integration productiva | Contratos, observabilidad, leasing robusto y transporte aprobado | Outbox/Inbox, Workers |
| 6 | Notification productiva | Adaptador de proveedor, secretos externos y gobierno de plantillas | Integration, Configuration |
| 7 | Angular Shell | Login, layout, Menu y Configuration dinámicos | IdP, Menu, Configuration |
| 8 | Reporting Foundation | Contratos de reportes y autorización; sin lógica de dominio | Security, Content |
| 9 | Audit retention jobs | Archivo/purga controlada posterior a 365 días | Data/operaciones |
| 10 | Multi-tenancy real | Provisionamiento y aislamiento verificado | Todos los contextos |

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
