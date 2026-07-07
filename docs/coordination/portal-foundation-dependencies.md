# Portal Foundation - Dependencias

## Matriz

| Capacidad | Security | Config | Audit | Outbox | Worker | Health/Logs | Gateway |
|---|---:|---:|---:|---:|---:|---:|---:|
| Security | - |  | D | D |  | D | D |
| Configuration | D | - | D | D |  | D | D |
| Menu | D | D | D | D |  | D | D |
| Audit | D |  | - |  | D* | D | D |
| Notification | D | D | D | D | D | D | D |
| Gateway | D |  |  |  |  | D | - |
| Outbox |  |  |  | - | D | D |  |
| Workers |  | D |  | D | - | D |  |

`D` indica dependencia. `D*`: la ingesta asincrona es deseable; el contrato HTTP minimo permite arrancar antes.

## Camino critico

1. P0: contratos y ADR aceptado.
2. P1: solucion, building blocks, Compose, health/logging y Gateway YARP.
3. P2: Security vertical slice.
4. P3: Outbox, Inbox, Worker y Audit.
5. P4: Configuration y Menu.
6. P5: Notification.
7. P6: QA integrado y documentacion.

## Reglas

- Cada API posee su esquema/base logica y su tabla Outbox.
- Cada consumidor persistente posee Inbox con clave unica `(consumer, eventId)`.
- No se comparten entidades de dominio; solo envelopes, telemetria y utilidades tecnicas estables.
- Las llamadas sincronas usan contratos HTTP v1; la propagacion asincrona usa eventos v1.
- Fallo de Audit/Notification no invalida una transaccion de dominio ya confirmada; se publica mediante Outbox cuando aplique.

## Riesgos

| Riesgo | Prob. | Impacto | Mitigacion | Owner |
|---|---|---|---|---|
| Alcance excesivo en un sprint | Alta | Alta | Vertical slices minimos; excluir UI y proveedores productivos | Coordinator |
| Security mal delimitado | Media | Critico | Threat model, autorizacion backend y pruebas negativas | Security Agent |
| Acoplamiento por base compartida | Media | Alto | Base/esquema y migraciones por contexto | Data Agent |
| Duplicados de Outbox | Alta | Alto | `eventId` estable, indice unico, claim/lease e Inbox | Integration Agent |
| PII/secretos en logs o auditoria | Media | Critico | Redaccion, allowlist y pruebas | DevOps/QA |
| Gateway como punto unico de fallo | Media | Alto | Stateless, health/readiness; HA queda para futuro | DevOps Agent |
| Contratos cambian sin version | Media | Alto | OpenAPI/event schemas v1 y contract tests | Architect/QA |
| Menu confia en frontend | Media | Critico | Revalidar recurso en cada API | Security Agent |
| Proveedor productivo diferido | Alta | Medio | Puerto/adaptador y proveedor de desarrollo | Integration Agent |
| Preparacion tenant incompleta | Media | Alto | tenant `default`, `tenantId` en scopes y derivacion desde identidad | Security/Data |
| Retencion Audit sin automatizacion | Media | Medio | 365 dias en linea; archivo/purga asignados a Sprint 2 | Audit/Data |
