# Mapa verificado de reutilización del Portal

## Política de decisión

El orden obligatorio antes de implementar es:

1. Reutilizar.
2. Extender.
3. Adaptar mediante contrato.
4. Construir.
5. Reemplazar progresivamente solo con ADR aprobado.

## Capacidades existentes

| Capacidad | Estado | Decisión HR | Acción |
|---|---|---|---|
| API Gateway YARP | Implementada | Reutilizar | Registrar rutas HR |
| Security API | Foundation implementada | Reutilizar y extender | Crear recursos, acciones y alcance organizacional |
| Configuration API | Implementada | Extender | Registrar claves y metadata HR |
| Menu API | Implementada | Extender | Registrar módulo, rutas y permisos |
| Audit API | Implementada | Adaptar | Crear `PortalAuditAdapter` |
| Notification API | Foundation implementada | Adaptar y extender | Consumir API y habilitar proveedores reales |
| SQL Outbox | Referencia implementada | Adaptar | Mantener Outbox en la base HR |
| SQL Inbox | Implementada | Adaptar | Idempotencia de consumidores HR |
| Workers | Implementados | Extender | Agregar procesamiento HR |
| Health checks | Implementados | Reutilizar | Liveness y readiness HR |
| Logging | Implementado | Reutilizar | Propagar contexto y clasificación |
| Correlation ID | Implementado | Reutilizar | Propagación extremo a extremo |
| Docker Compose | Implementado | Extender | Agregar servicios y base HR |
| Seq | Implementado | Reutilizar | Centralizar logs |
| Smoke tests | Implementados | Extender | Agregar escenarios HR |

## Capacidades pendientes de plataforma

| Capacidad | Decisión | Dependencia de HR |
|---|---|---|
| Angular Portal Shell | Construir en Portal | Bloquea experiencia integrada |
| Entra ID/OIDC productivo | Integrar en Portal | Bloquea autenticación productiva |
| Catalog API | Construir en Portal | Bloquea catálogos globales administrables |
| Content/File API | Construir en Portal | Bloquea expediente documental completo |
| Reporting API | Construir en Portal | Bloquea exportaciones asíncronas comunes |
| Integration API | Endurecer/construir | Habilita conectores comunes |
| Workflow Engine | Construir en Portal | Bloquea aprobaciones configurables |
| Task Inbox | Construir en Portal | Bloquea bandeja corporativa |
| Correo y Teams reales | Extender Notification | Bloquea comunicaciones productivas |

## Capacidades propias de HR

- Organización.
- Cargos.
- Posiciones.
- Personas.
- Colaboradores.
- Relaciones laborales.
- Contratos.
- Vacaciones y permisos.
- Reclutamiento.
- Candidatos.
- Onboarding y offboarding.
- Desempeño.
- Competencias.
- Aprendizaje.
- Clima.
- Compensación.
- Novedades e integración de nómina.

## Prohibiciones

- Crear otra autenticación o sistema de sesión.
- Crear otro menú global.
- Enviar correo directamente desde HR.
- Guardar archivos como solución local del módulo.
- Escribir directamente en bases del Portal.
- Compartir tablas entre bounded contexts.
- Validar autorización únicamente en la UI.
- Implementar auditoría propia desconectada del Portal.
- Codificar aprobaciones específicas sin usar Workflow.

## Contratos adaptadores esperados

```text
HumanResources.Infrastructure/Portal
├── PortalSecurityClient
├── PortalMenuRegistration
├── PortalConfigurationClient
├── PortalAuditAdapter
├── PortalNotificationAdapter
├── PortalFileAdapter
├── PortalWorkflowAdapter
├── PortalTaskInboxAdapter
└── PortalIntegrationAdapter
```

## Quality gate de reutilización

Cada pull request debe declarar:

```yaml
portal_reuse:
  capabilities_checked: []
  reused: []
  extended: []
  adapted: []
  created: []
  duplication_risk: none
  adr_required: false
```

El pipeline debe rechazar dependencias directas a bases ajenas, servicios duplicados o envío de notificaciones fuera del contrato común.
