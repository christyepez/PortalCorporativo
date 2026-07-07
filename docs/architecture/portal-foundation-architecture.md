# Portal Foundation Architecture

## Estilo

PortalCorporativo usa APIs independientes por bounded context, Clean Architecture y persistencia separada. La comunicacion entre contextos ocurre por HTTP versionado o eventos versionados; nunca mediante tablas compartidas.

```text
Consumers -> API Gateway -> Security / Configuration / Menu / Audit / Notification
                              |             |         |       |
                              +-- SQL DB + Outbox por contexto --+
                                                   |
                                             Outbox Worker
                                                   |
                                           eventos versionados

Todos los hosts -> health checks + logs estructurados -> consola/Seq (desarrollo)
```

## Contextos

| Contexto | Autoridad sobre | No posee |
|---|---|---|
| Identity & Access | usuarios, roles, permisos, recursos, decisiones | menus y configuracion visual |
| Configuration | claves, scopes y versiones configurables | secretos ni reglas de dominio |
| Navigation | menus, items y asignaciones | autorizacion definitiva |
| Audit | registros inmutables de actividad | eventos de negocio fuente |
| Notifications | solicitudes y estado de entrega | reglas que deciden cuando notificar |
| Edge | ruteo y politicas de entrada | logica de negocio |
| Async Processing | despacho tecnico y reintentos | ownership de eventos de negocio |

## Contratos transversales

- HTTP bajo `/api/v1`; OpenAPI es el contrato publicable.
- Eventos con envelope: `id`, `type`, `version`, `occurredAt`, `correlationId`, `producer`, `payload`.
- Errores HTTP con Problem Details y codigo estable.
- Idempotency key obligatoria para notificaciones y consumidores asincronos.
- `correlationId` entra por Gateway o se genera; se propaga a logs, auditoria y eventos.

## Decisiones operativas Sprint 1

- Gateway: implementacion real YARP, limitada a rutas v1, JWT, correlacion, headers, health y logs.
- Configuracion efectiva: se fusiona `global -> tenant -> module -> user`; el valor mas especifico gana.
- Tenancy: un tenant canonico `default`; contratos tenant-scoped conservan `tenantId` para evolucion futura.
- Audit: append-only, 365 dias en linea, sin purga automatica en Sprint 1 y captura por allowlist con PII enmascarada.
- Outbox: tabla y ownership por bounded context. El Worker usa claim/lease; cada consumidor registra Inbox con unicidad `(consumer, eventId)`.

## Datos y seguridad

- SQL Server con base o esquema independiente y credenciales de minimo privilegio por contexto.
- JWT se valida en Gateway y nuevamente donde se protege el recurso; la autorizacion final vive en backend.
- Configuration no almacena secretos. Secretos vienen de variables locales no versionadas o un secret store futuro.
- Audit y logging aplican redaccion; no guardan tokens ni payloads sensibles completos.
- El `tenantId` se obtiene de identidad confiable; una API no confia en un tenant enviado libremente por el cliente.

## Despliegue Sprint 1

Docker Compose es el entorno integrado de desarrollo. Incluye infraestructura existente y los hosts del sprint con health checks, dependencias condicionadas por readiness y configuracion externa. Kafka permanece desactivado; SQL Outbox es el transporte inicial.
