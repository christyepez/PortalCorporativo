# Roadmap técnico

## Sprint 1 Foundation — cerrado

- [x] P1 Platform Bootstrap: solución, Compose, Gateway, health y logging.
- [x] P2 Security Foundation: usuarios, roles, recursos, permisos y autorización.
- [x] P3 Audit + SQL Outbox/Inbox + Worker Foundation.
- [x] P4 Configuration + Menu Foundation.
- [x] P5 Notification API + Worker Foundation.
- [x] P6 QA integrado y policies backend por permiso.
- [x] Build limpio, 50/50 pruebas y smoke integrado.

## Sprint 2 propuesto

- [ ] Catalog API Foundation.
- [ ] Content/File API Foundation.
- [ ] Reporting API Foundation.
- [ ] Integration API y transporte productivos.
- [ ] Portal Angular Shell integrado con Security/Menu/Configuration.
- [ ] IdP productivo con OIDC/OAuth2.
- [ ] Revocación de permisos y automatización E2E JWT.
- [ ] Jobs de archivo/purga Audit después de 365 días.
- [ ] Evaluar Kafka/RabbitMQ mediante ADR; no introducir broker por defecto.

## Riesgos diferidos

- IdP y SSO productivos; multi-tenant real y aislamiento formal.
- Revocación/latencia de claims y diseño de roles de mínimo privilegio.
- Proveedor productivo de notificaciones y gobierno avanzado de plantillas.
- Outbox transaccional en cada contexto, leasing distribuido y broker productivo.
- Retención automatizada de Audit, HA/observabilidad avanzada y E2E completos.

Detalle y orden: `docs/coordination/sprint-02-roadmap.md`.
