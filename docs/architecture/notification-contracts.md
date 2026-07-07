# Notification Foundation Contracts

## Ownership

`Notifications` posee plantillas, solicitudes, destinatarios, estado e intentos. Los consumidores deciden cuándo notificar; no escriben en `PortalNotification`.

## HTTP v1 foundation

Todas las rutas requieren JWT y viven bajo `/api/notifications`:

- `POST/PUT /templates`, `GET /templates`, `POST /templates/{id}/activate|deactivate`.
- `POST /send`, `POST /schedule`.
- `GET /{id}`, `GET /`.
- `POST /{id}/retry`, `POST /{id}/cancel`.

Permisos registrados en Security y aplicados en backend: `portal.notification.manage`, `portal.notification.send`, `portal.notification.read`. Gateway y API validan JWT; la API exige además el claim `permission` correspondiente.

## Semántica

- Tenant canónico: `default`; clave única de plantilla `(tenantId, code)` y de solicitud `(tenantId, idempotencyKey)`.
- Canales: `Internal`, `EmailDev`, `LogDev`.
- Estados: `Pending`, `Processing`, `Sent`, `Failed`, `Cancelled`, `DeadLetter`.
- Worker: entrega al menos una vez, backoff configurable y máximo de intentos. Los proveedores de desarrollo solo generan logs estructurados.
- Seeds: `portal.security.user-created`, `portal.security.role-assigned`, `portal.configuration.changed`, `portal.menu.changed`, `portal.notification.test`.
- Cambios pasan por `INotificationChangeRecorder`; integración transaccional Audit/Outbox queda para Sprint 2.

## Fuera de alcance

SMTP, SendGrid, SES, SMS/push reales, secretos, UI, preferencias avanzadas y selección de proveedor productivo.
