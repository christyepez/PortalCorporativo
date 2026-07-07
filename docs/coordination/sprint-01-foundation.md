# Sprint 01 - Portal Foundation

> Estado: **Cerrado y aceptado (2026-07-06)**. Evidencia y límites finales en `sprint-01-closure.md`.

## Objetivo

Entregar una base ejecutable y verificable para seguridad, configuracion, menus, auditoria, notificaciones, gateway, Outbox, Workers, salud y logging. El sprint no incluye funcionalidades de Financiero ni CRM.

## Clasificacion y responsables

| Capacidad | Owner / bounded context | Clasificacion | Agente | Carpeta esperada |
|---|---|---|---|---|
| Security API | Portal / Identity & Access | CREATE | Security Agent | `backend/security-api/` |
| Configuration API | Portal / Configuration | CREATE | Backend Agent | `backend/configuration-api/` |
| Menu API | Portal / Navigation | CREATE | Backend Agent | `backend/menu-api/` |
| Audit API | Portal / Audit | CREATE | Backend Agent | `backend/audit-api/` |
| Notification API | Portal / Notifications | CREATE | Integration Agent | `backend/notification-api/` |
| API Gateway | Portal / Edge | CREATE | DevOps Agent | `backend/api-gateway/` |
| SQL Outbox | Cada contexto, contrato comun | CREATE | Data Agent | `backend/building-blocks/`, migraciones por API |
| Workers | Portal / Async Processing | CREATE | Integration Agent | `backend/workers/` |
| Health checks | Plataforma / Observability | CREATE | DevOps Agent | building blocks y cada host |
| Logging estructurado | Plataforma / Observability | EXTEND (Seq ya existe) | DevOps Agent | building blocks, hosts y Compose |

## Especificacion minima por capacidad

### Security API

- Responsabilidad: usuarios, roles, permisos, recursos y evaluacion de autorizacion backend.
- Contratos/endpoints: `LoginRequest/TokenResponse`, `AuthorizationRequest/Decision`; `POST /api/v1/auth/login`, `POST /api/v1/authorization/evaluate`, CRUD minimo de users/roles/resources/permissions.
- Entidades/eventos: User, Role, Permission, Resource, UserRole; `UserCreatedV1`, `RoleAssignedV1`, `PermissionChangedV1`.
- Dependencias: SQL Server, Outbox, Audit, logging. Los tokens nunca viajan por URL.
- Aceptacion: token firmado; recurso registrado; acceso permitido/denegado en backend; evento y auditoria con `correlationId`; pruebas unitarias, integracion y contrato.
- Decision: single-tenant preparado; tenant canonico `default`, `tenantId` en contratos tenant-scoped y derivado de identidad. IdP externo y multi-tenant real quedan fuera.

### Configuration API

- Responsabilidad: parametros funcionales y visuales versionados por alcance.
- Contratos/endpoints: `ConfigurationEntryV1`; `GET /api/v1/configurations/{scope}`, `PUT /api/v1/configurations/{scope}/{key}`.
- Entidades/eventos: ConfigurationEntry, ConfigurationVersion; `ConfigurationChangedV1`.
- Dependencias: Security, Audit, Outbox.
- Aceptacion: lectura por scope, escritura autorizada, version/concurrencia, auditoria y contrato versionado; pruebas confirman la fusion `global -> tenant -> module -> user`, donde el valor mas especifico gana.
- Decision: prioridad efectiva `user > module > tenant > global`.

### Menu API

- Responsabilidad: navegacion dinamica por aplicacion, rol y recurso protegido.
- Contratos/endpoints: `MenuTreeV1`, `MenuItemV1`; `GET /api/v1/menus/{applicationKey}`, CRUD administrativo de items.
- Entidades/eventos: Menu, MenuItem, MenuAssignment; `MenuPublishedV1`.
- Dependencias: Security y Configuration; Audit/Outbox para cambios.
- Aceptacion: arbol ordenado y filtrado; cada item referencia un Resource de Security; sin permisos decididos solo en frontend.
- Riesgo: ciclos y rutas inseguras; validar grafo y rutas permitidas.

### Audit API

- Responsabilidad: trazabilidad inmutable de acciones y accesos criticos.
- Contratos/endpoints: `AuditRecordV1`; `POST /api/v1/audit-records`, `GET /api/v1/audit-records` con filtros.
- Entidades/eventos: AuditRecord; no publica eventos de negocio en Sprint 1.
- Dependencias: identidad, `correlationId`, SQL Server, Worker para ingesta asincrona.
- Aceptacion: actor, accion, recurso, resultado, tiempo y correlacion; sin endpoints update/delete; consulta autorizada; allowlist y enmascaramiento probados.
- Decision: append-only y 365 dias en linea. Sprint 1 no purga; archivo/purga controlada se difiere a Sprint 2.

### Notification API

- Responsabilidad: aceptar solicitudes genericas y registrar estado de entrega; un proveedor de desarrollo.
- Contratos/endpoints: `NotificationRequestV1`, `NotificationStatusV1`; `POST /api/v1/notifications`, `GET /api/v1/notifications/{id}`.
- Entidades/eventos: Notification, DeliveryAttempt; `NotificationRequestedV1`, `NotificationSentV1`, `NotificationFailedV1`.
- Dependencias: Security, Outbox, Worker, Configuration, Audit.
- Aceptacion: solicitud idempotente; procesamiento asincrono; reintento acotado; estado consultable; secretos fuera del repositorio.
- Riesgo: proveedor y plantillas no decididos. Solo contrato y proveedor de desarrollo en Sprint 1.
- Estado P5: completado. Plantillas y mensajes aislados en SQL, endpoints JWT, idempotencia, programación, Worker, retry/backoff/DeadLetter y proveedores de desarrollo verificados con pruebas unitarias. Proveedor productivo diferido.

### API Gateway minimo

- Responsabilidad: unico punto de entrada, rutas versionadas, propagacion de identidad y correlacion.
- Contratos/endpoints: configuracion de rutas; `/health/live`, `/health/ready`; proxy `/api/security/*`, `/api/configuration/*`, `/api/menus/*`, `/api/audit/*`, `/api/notifications/*`.
- Entidades/eventos: ninguno.
- Dependencias: APIs, Security, logging.
- Aceptacion: rutas internas no expuestas directamente en perfil integrado; JWT validado; headers seguros; trazas correlacionadas.
- Decision: implementar YARP. Alcance: rutas v1, JWT, correlacion, headers seguros, health y logs; sin logica de negocio, service discovery ni HA.

### SQL Outbox base

- Responsabilidad: persistir evento y cambio de negocio en la misma transaccion de cada bounded context.
- Contratos: `IntegrationEventEnvelopeV1` con id, type, version, occurredAt, correlationId y payload.
- Entidades/eventos: OutboxMessage; eventos propios de cada contexto.
- Dependencias: SQL Server y Worker; ninguna base compartida.
- Aceptacion: migracion por contexto, entrega al menos una vez, `eventId` unico, claim/lease, Inbox unica `(consumer,eventId)`, reintento y estado observable.
- Decision: cada bounded context posee su Outbox en su almacenamiento; solo envelope y utilidades son compartidos. No se promete exactly-once.

### Workers base

- Responsabilidad: despachar Outbox, reintentar y mover fallos agotados a estado terminal consultable.
- Contratos/endpoints: consumidor de `IntegrationEventEnvelopeV1`; health checks del host.
- Entidades/eventos: ProcessingAttempt/estado en Outbox; sin eventos adicionales obligatorios.
- Dependencias: SQL Server, logging, health checks.
- Aceptacion: polling configurable, lease/concurrencia segura, backoff, idempotencia y recuperacion tras reinicio.
- Riesgo: ejecucion duplicada; usar claim/lease transaccional.

### Health checks

- Responsabilidad: convencion comun de liveness/readiness.
- Contratos/endpoints: `GET /health/live`, `GET /health/ready` en cada host.
- Entidades/eventos: ninguno.
- Dependencias: dependencias locales de cada host y Docker Compose.
- Aceptacion: liveness no depende de terceros; readiness valida dependencias esenciales; Compose espera estados saludables.
- Riesgo: checks costosos; usar timeout y no ejecutar consultas pesadas.

### Logging estructurado

- Responsabilidad: logs JSON con trazabilidad transversal y redaccion de secretos.
- Contrato: campos `timestamp`, `level`, `service`, `environment`, `traceId`, `correlationId`, `eventId`; salida consola y Seq en desarrollo.
- Entidades/eventos/endpoints: ninguno.
- Dependencias: todos los hosts, Seq ya definido en Compose.
- Aceptacion: una peticion puede seguirse gateway-API-worker; tokens/secretos/PII no se registran; niveles configurables.
- Riesgo: fuga de datos y cardinalidad; politica de redaccion obligatoria.

## Orden y agentes

1. Solution Architect: aprobar ADR, contratos y limites.
2. DevOps Agent: solucion base, Compose, gateway elegido, health/logging.
3. Data Agent: convenciones SQL y Outbox por contexto.
4. Security Agent: Security vertical slice.
5. Backend Agent: Audit, Configuration y Menu en ese orden.
6. Integration Agent: Worker Outbox y Notification.
7. QA Agent: unitarias, integracion, contratos, seguridad y Compose.
8. Documentation Agent: estado real, contratos y runbook.

No iniciar un agente si su dependencia inmediata no tiene contrato aprobado. Cambios por agente deben ser pequenos y revisables.

## Paquetes implementables

| Paquete | Responsable | Alcance | Archivos/carpetas esperadas | Criterios de aceptacion |
|---|---|---|---|---|
| P0 Decision baseline | Solution Architect + Coordinator | Congelar ADR, contratos v1 y alcance | `docs/architecture/`, `docs/coordination/` | ADR aceptado; cero decisiones bloqueantes |
| P1 Platform bootstrap | DevOps Agent | Solucion .NET, building blocks tecnicos, Compose, YARP, health y logging | `backend/PortalCorporativo.sln`, `backend/building-blocks/`, `backend/api-gateway/`, `docker-compose.yml` | Build limpio; Gateway enruta stub/health; logs correlacionados; Compose valida salud |
| P2 Identity & Access | Security Agent + Data Agent | Security vertical slice y almacenamiento propio | `backend/security-api/src/`, `backend/security-api/tests/` | Login, recursos y autorizacion backend; tenant `default`; pruebas positivas/negativas y OpenAPI |
| P3 Reliable audit | Data Agent + Integration Agent + Backend Agent | **Implementado:** Outbox/Inbox, Worker y Audit append-only | `backend/building-blocks/`, `backend/workers/`, `backend/audit-api/`, `backend/integration-api/` | Build y pruebas; duplicado sin segundo efecto; Audit sin update/delete; PII redactada |
| P4 Dynamic platform | Backend Agent | **Implementado:** Configuration y Menu | `backend/configuration-api/`, `backend/menu-api/` | Precedencia probada; Menu consulta Security y no sustituye autorización backend |
| P5 Notifications | Integration Agent | API, Outbox y proveedor de desarrollo | `backend/notification-api/` | Idempotencia, reintento, estado consultable, secretos externos |
| P6 Integrated quality | QA Agent + Documentation Agent | Build, pruebas, contratos, seguridad y runbook | carpetas `tests/`, README/docs | Todo el DoD pasa; matriz de capacidades refleja evidencia real |

### Primer paquete listo

P1 Platform bootstrap puede iniciar tras esta aprobacion. Puede leer los documentos de arquitectura y archivos raiz de infraestructura; puede modificar exclusivamente la solucion/backend de building blocks y gateway, Compose y pruebas asociadas. No debe crear APIs de negocio. P2 inicia cuando P1 publique convenciones compilables y contratos de observabilidad.

## Desbloqueo de consumidores

- Financiero: Security, Gateway, Audit, Outbox/Workers, Configuration y Notification; Menu habilita integracion visual posterior.
- CRM: las mismas capacidades; Configuration y Menu son especialmente necesarias para modulos y navegacion dinamica.
- Ningun consumidor accede a bases del portal; usa API o eventos versionados.

## Fuera de Sprint 1

Angular Shell, Catalog, Content/File, Reporting, Integration API completa, Kafka, BI, proveedores productivos de notificacion, IdP externo, SSO federado, UI administrativa, reglas de Financiero/CRM, alta disponibilidad y optimizaciones avanzadas.

## Sprint 2

Portal Angular Shell, Catalog API, administracion de Security/Configuration/Menu, Content/File minimo, proveedor real de notificaciones, multi-tenant real, archivo/purga Audit y politicas avanzadas del Gateway. Reporting e Integration se disenan despues de fijar limites con los dominios.

## Definition of Done

- ADR y contratos v1 aprobados; ownership y limites sin ambiguedad.
- Cada host compila, inicia en Compose y expone health checks.
- Autorizacion se valida en backend y todos los recursos visibles se registran en Security.
- Persistencia separada por bounded context; cero consultas cruzadas entre bases.
- Eventos versionados con `correlationId`, Outbox transaccional e idempotencia probada.
- Logs estructurados correlacionan gateway, API y Worker sin secretos ni PII.
- OpenAPI y pruebas unitarias, integracion y contrato pasan.
- README/runbook y matriz de estado se actualizan; ningun componente de dominio fue creado.

## P6 QA y seguridad

- Policies backend por permiso activas en Security, Configuration, Menu, Audit y Notification.
- Seeds y matriz de autorización consistentes; health permanece anónimo.
- Pruebas integration-light y `scripts/smoke/sprint1-smoke.ps1` verifican denegación, concesión, routing, correlación, SQL y procesamiento LogDev.
