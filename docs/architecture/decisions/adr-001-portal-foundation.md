# ADR-001: Fundacion transversal del portal

- Estado: Aceptado
- Fecha: 2026-07-06
- Aprobado: 2026-07-06

## Contexto

PortalCorporativo declara capacidades transversales, pero el discovery encontro solo estructura documental y Compose parcial. Financiero y CRM permanecen bloqueados para reutilizacion.

## Decision

1. Crear Security, Configuration, Menu, Audit y Notification como bounded contexts independientes.
2. Implementar un API Gateway minimo real con YARP. Incluye proxy de rutas v1, validacion JWT, propagacion/generacion de `correlationId`, headers seguros, health checks y logging. Excluye transformacion de negocio, service discovery, monetizacion y alta disponibilidad.
3. Usar SQL Outbox propiedad de cada bounded context, en su propia base o esquema y dentro de la transaccion local. Solo el envelope y las utilidades tecnicas son comunes. La entrega es al menos una vez; `eventId` estable, indice unico, claim/lease y registro Inbox `(consumer, eventId)` evitan efectos duplicados. No introducir Kafka en Sprint 1.
4. Compartir solo building blocks tecnicos de contratos, Problem Details, correlacion, health y logging; no entidades de dominio.
5. Versionar HTTP y eventos desde v1, con `correlationId` obligatorio.
6. Extender Docker Compose y Seq existentes; las demas capacidades se clasifican CREATE dentro de PortalCorporativo.
7. Configuration calcula valores efectivos aplicando defaults de menor a mayor especificidad: `global -> tenant -> module -> user`; el ultimo valor definido gana. Por tanto, la prioridad efectiva es `user > module > tenant > global`.
8. Sprint 1 es single-tenant preparado para multi-tenant. Usa un tenant canonico `default`; los contratos y datos tenant-scoped incluyen `tenantId`, derivado de identidad y nunca aceptado ciegamente desde el cliente. Provisionamiento de multiples tenants y aislamiento certificado quedan fuera.
9. Audit es append-only: no expone update ni delete. Conserva registros 365 dias en linea. En Sprint 1 no hay purga automatica; archivo/purga controlada posterior a 365 dias se implementa en Sprint 2. La captura usa allowlist, omite secretos/tokens y enmascara identificadores personales no necesarios para investigacion.

## Consecuencias

- Positivas: ownership claro, consumidores desacoplados, entrega confiable y observabilidad desde el inicio.
- Costos: mas hosts, bases/migraciones separadas y disciplina de contratos.
- Restricciones: autorizacion backend, sin bases compartidas, sin secretos versionados y sin configuracion visual quemada.

## Decisiones diferidas

- Provisionamiento multi-tenant real y validacion formal de aislamiento.
- Archivo/purga automatica de Audit despues de 365 dias y almacenamiento de archivo.
- Proveedor productivo y gobierno de plantillas de Notification.
- Kafka, service discovery, alta disponibilidad y politicas avanzadas del Gateway.

Estas decisiones pertenecen a Sprint 2 o posteriores y no bloquean Sprint 1.
