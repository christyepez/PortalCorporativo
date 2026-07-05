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
