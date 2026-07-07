# Capacidades reutilizables de PortalCorporativo

Este documento es el inventario base que otros repositorios deben consultar antes de crear componentes nuevos.

## Repositorio comun de agentes

```text
https://github.com/christyepez/CodexCommonAgents
```

Codex debe usar este archivo junto con:

```text
CodexCommonAgents/AGENTS.md
CodexCommonAgents/registry/reusable-portal-apis.md
CodexCommonAgents/registry/do-not-duplicate.md
CodexCommonAgents/playbooks/portal-first-implementation.md
```

## Regla central

PortalCorporativo es la plataforma transversal. Los repositorios de dominio como `Financiero`, `CRM` u otros proyectos deben reutilizar, extender o adaptar estas capacidades antes de crear componentes propios.

## Clasificación obligatoria

```text
REUSE   = usar directamente una capacidad del portal.
EXTEND  = extender configuración, permisos, catálogos, menús o contratos del portal.
ADAPT   = crear adaptador hacia una API o servicio del portal.
CREATE  = crear componente propio del dominio porque no existe en portal.
BLOCKED = no implementar hasta revisar portal o resolver una decisión.
```

## Capacidades transversales

| Capacidad | Uso recomendado | Decisión por defecto |
|---|---|---|
| API Gateway | Exposición y enrutamiento de APIs | REUSE |
| Security API | Login, usuarios, roles, permisos, autorización | REUSE/EXTEND |
| Menu API | Menús dinámicos por módulo, rol y tenant | EXTEND |
| Configuration API | Parámetros visuales y funcionales | EXTEND |
| Catalog API | Catálogos globales y parametrizables | EXTEND |
| Audit API | Auditoría de acciones críticas y trazabilidad | ADAPT |
| Notification API | Correos, avisos, eventos y notificaciones | ADAPT |
| Content API / File API | Archivos, documentos, imágenes y metadata | ADAPT |
| Reporting API | Reportes transversales e integración BI | EXTEND |
| Integration API | Integraciones comunes y contratos externos | EXTEND/ADAPT |
| Portal Angular Shell | Layout, navegación, temas, menús y seguridad visual | REUSE/EXTEND |
| SQL Outbox | Publicación confiable de eventos | EXTEND |
| Workers | Procesamiento asíncrono, reintentos e integración | EXTEND |
| Docker Compose | Ejecución local integrada | EXTEND |

## Estado al cierre de Sprint 1

| Capacidad | Estado | Clasificación consumidor |
|---|---|---|
| Security API | Foundation lista | REUSE/EXTEND |
| Audit API | Foundation lista | ADAPT |
| SQL Outbox/Inbox | Foundation lista; ownership por contexto | ADAPT/EXTEND |
| Configuration API | Foundation lista | EXTEND |
| Menu API | Foundation lista | EXTEND |
| Notification API | Foundation lista con proveedores dev | ADAPT |
| API Gateway | Foundation lista | REUSE |
| Workers | Foundation lista | EXTEND |
| Health/logging/correlationId | Foundation lista | REUSE |
| Catalog API | Pendiente | BLOCKED hasta Sprint 2 |
| Content/File API | Pendiente | BLOCKED hasta Sprint 2 |
| Reporting API | Pendiente | BLOCKED hasta Sprint 2 |
| Integration API productiva | Pendiente | BLOCKED hasta contrato/transporte |
| Portal Angular Shell | Pendiente | BLOCKED hasta Sprint 2 |
| IdP productivo | Pendiente | BLOCKED para login productivo |

## Estado de Security API

Identity & Access Foundation esta implementada para el tenant canonico `default`:

- Usuarios, roles, permisos, recursos protegidos y asignaciones.
- Evaluacion backend mediante `CheckPermission`.
- Unicidad y aislamiento por `tenantId` preparados para evolucion multi-tenant.
- SQL Server exclusivo del bounded context Security.
- Seeds de administracion transversal.
- Endpoints protegidos por validacion JWT y respuestas correlacionadas.

Clasificacion para CRM, Financiero y futuros dominios: `REUSE/EXTEND`. Deben registrar recursos/permisos y consumir contratos; no deben duplicar identidad global ni consultar la base del portal.

Autenticacion, emision de tokens, OAuth/OIDC y administracion multi-tenant real permanecen pendientes. Hasta disponer de un emisor confiable, la capacidad implementada cubre autorizacion y administracion foundation, no login productivo.

Las APIs aplican autorización backend por claim firmado `permission`. La matriz vigente está en `docs/security/authorization-policy-matrix.md`; Gateway autentica y cada API vuelve a validar JWT y permiso. Health es la única superficie transversal anónima deliberada.

## Estado de Audit, Outbox e Inbox

- Audit API: append-only, paginación/filtros, correlación y redacción de PII. Clasificación consumidor: `ADAPT`.
- SQL Outbox: contrato y servicios de referencia con idempotencia, retry y DeadLetter. Cada bounded context mantiene su propia tabla/transacción; clasificación: `EXTEND`.
- SQL Inbox: detección única por `tenant + source + idempotencyKey`; clasificación: `EXTEND/ADAPT`.
- Worker: host configurable con backoff y límite de intentos; deshabilitado sin transporte explícito.

CRM y Financiero envían registros auditables mediante contrato/API o adaptador y nunca escriben en `PortalAudit`. Para eventos de negocio implementan el contrato Outbox en su propia base; no escriben directamente en `PortalIntegration`. Kafka/RabbitMQ no están implementados.

## Estado de Configuration y Menu

- Configuration API resuelve `global -> tenant -> module -> user`; gana el valor activo más específico. Soporta JSON para metadata visual, funcional, grids, formularios, acciones, layouts y temas.
- Menu API mantiene módulos, jerarquía, rutas, orden, iconos, metadata y acciones. La visibilidad consulta `CheckPermission` de Security en backend.
- CRM y Financiero registran claves, módulos e ítems por contrato (`EXTEND`); no codifican menús/configuración propios ni consultan bases del portal.
- Cambios emiten contrato versionado hacia un puerto obligatorio y logging estructurado. Outbox transaccional local por contexto y Audit HTTP quedan diferidos para endurecimiento Sprint 2.

## Estado de Notification

- Notification API acepta solicitudes idempotentes, programadas o inmediatas, basadas en plantillas versionadas por tenant.
- Persiste mensajes, destinatarios, estados e intentos en `PortalNotification`; un Worker independiente procesa con backoff, límite de intentos y DeadLetter.
- Sprint 1 incluye únicamente `Internal`, `EmailDev` y `LogDev`; no envía correo real ni guarda secretos de proveedor.
- CRM y Financiero consumen el contrato HTTP mediante `ADAPT`; no implementan motores de plantillas, reintentos ni proveedores propios.
- Clasificación actual: `ADAPT` para consumidores y `EXTEND` para registrar plantillas. Proveedor productivo y preferencias avanzadas quedan pendientes.

## Prohibido duplicar

No crear nuevamente en repositorios de dominio:

- Autenticación.
- Usuarios.
- Roles globales.
- Permisos globales.
- Motor de menús.
- Motor de configuración visual.
- Auditoría transversal.
- Notificaciones transversales.
- Gestión genérica de archivos.
- Catálogos globales.
- API Gateway.
- Shell Angular.

## Permitido crear en dominios

Los repositorios de dominio pueden crear componentes propios cuando correspondan a reglas específicas del negocio.

Ejemplos:

- Financiero: plan de cuentas, asientos, facturación, retenciones, XML SRI, RIDE, ATS.
- CRM: clientes, contactos, leads, oportunidades, actividades, casos, campañas, integration hub CRM.

## Salida mínima para Codex

Toda tarea debe reportar:

```text
Portal Capability Checked:
Reuse Classification:
Portal Components Reused:
Portal Components Extended:
New Components Created:
Reason for New Components:
Risks:
Next Step:
```
