# Guía de onboarding para consumidores

Aplica a Financiero, CRM y futuros dominios. PortalCorporativo es owner de capacidades transversales; el consumidor es owner exclusivo de su negocio.

## Flujo común

1. Clasificar cada necesidad como REUSE, EXTEND, ADAPT, CREATE o BLOCKED.
2. Registrar en Security un `resource` y acciones/permisos propios del módulo; asignarlos por mínimo privilegio.
3. Consumir exclusivamente mediante Gateway con JWT firmado, claim `permission` y `X-Correlation-ID`.
4. Registrar menús/rutas y Configuration por código de módulo; la UI nunca reemplaza autorización backend.
5. Enviar auditoría allowlisted mediante Audit API con `portal.audit.write`; no incluir tokens, secretos ni PII innecesaria.
6. Solicitar notificaciones mediante Notification API con plantilla registrada, `idempotencyKey` y `portal.notification.send`.
7. Mantener Outbox en la base del dominio y dentro de la transacción local; usar Inbox idempotente para entradas.

## Financiero

- Security: reutiliza usuarios/roles globales y registra recursos como `financiero.invoice` o `financiero.ledger`; no crea identidad propia.
- Menu/Configuration: extiende módulo `financiero`, rutas, acciones, grids y parámetros funcionales/visuales.
- Audit: adapta eventos críticos —asientos, aprobaciones, documentos fiscales— sin escribir en `PortalAudit`.
- Notification: registra plantillas `financiero.*` y solicita envíos; no implementa motor de plantillas/reintentos.
- CREATE permitido: plan de cuentas, períodos, asientos, facturación, retenciones, SRI, XML, RIDE y ATS.

## CRM

- Security: reutiliza identidad y registra recursos como `crm.customer`, `crm.lead` o `crm.opportunity`.
- Menu/Configuration: extiende módulo `crm`, navegación, acciones, formularios y metadata dinámica.
- Audit: adapta cambios críticos de clientes, oportunidades, casos y campañas mediante API/eventos.
- Notification: registra plantillas `crm.*` y solicita avisos con idempotencia; no duplica entrega/retry.
- CREATE permitido: clientes, contactos, leads, oportunidades, actividades, casos, campañas y CRM Integration Hub. Salesforce/Dynamics se aíslan detrás del Hub.

## Prohibido duplicar

Identidad/autenticación, usuarios/roles globales, autorización, Gateway, motor de menús, configuración transversal, auditoría, notificaciones, catálogos globales, archivos genéricos y shell. Tampoco se permite acceso directo a bases del portal, compartir tablas entre contextos, transportar tokens por URL o confiar solo en permisos frontend.

## Disponibilidad

Security, Configuration, Menu, Audit, Notification, Gateway, Outbox/Inbox y Workers están disponibles como foundation. Catalog, Content/File, Reporting, Angular Shell, IdP y transporte productivo están `BLOCKED` hasta Sprint 2; el consumidor no debe suplirlos duplicándolos.
