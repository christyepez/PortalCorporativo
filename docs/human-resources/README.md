# Talento Humano en Portal Corporativo

## Propósito

Este directorio contiene la definición funcional, arquitectónica y de implementación del módulo de Talento Humano integrado al Portal Corporativo.

El Portal actúa como contenedor de experiencia y plataforma compartida. Talento Humano conserva sus reglas, datos y procesos de negocio como dominios independientes, reutilizando las capacidades transversales existentes.

## Principios

1. Reutilizar antes de adaptar.
2. Adaptar antes de construir.
3. No duplicar capacidades transversales.
4. Mantener límites claros entre Portal y dominios.
5. Integrar mediante contratos, APIs y eventos.
6. Automatizar análisis, implementación, pruebas y documentación con Codex.
7. Exigir revisión humana para seguridad, privacidad, compensación y nómina.

## Documentos

| Documento | Contenido |
|---|---|
| [01-vision-alcance.md](01-vision-alcance.md) | Visión, objetivos, alcance y supuestos |
| [02-benchmark-funcional.md](02-benchmark-funcional.md) | Capacidades tomadas como referencia del mercado |
| [03-mapa-reutilizacion-portal.md](03-mapa-reutilizacion-portal.md) | Decisiones verificadas: reutilizar, adaptar, reemplazar o construir |
| [04-arquitectura-objetivo.md](04-arquitectura-objetivo.md) | Arquitectura lógica, dominios, contratos y dependencias |
| [05-modulos-funcionales.md](05-modulos-funcionales.md) | Mapa funcional completo de Talento Humano |
| [06-seguridad-datos-cumplimiento.md](06-seguridad-datos-cumplimiento.md) | Seguridad, privacidad, auditoría y clasificación de datos |
| [07-integraciones.md](07-integraciones.md) | Integraciones, eventos y responsabilidades |
| [08-roadmap-sprints-esfuerzo.md](08-roadmap-sprints-esfuerzo.md) | Etapas, sprints, esfuerzo, equipo y dependencias |
| [09-agentes-codex-automatizacion.md](09-agentes-codex-automatizacion.md) | Agentes, orquestación y ejecución sin copiar prompts |
| [10-tokens-costos-codex.md](10-tokens-costos-codex.md) | Modelo de estimación y control de tokens |
| [11-calidad-pruebas-devops.md](11-calidad-pruebas-devops.md) | Quality gates, pruebas, CI/CD y observabilidad |
| [12-backlog-inicial.md](12-backlog-inicial.md) | Épicas e historias iniciales priorizadas |
| [adr/README.md](adr/README.md) | Registro inicial de decisiones de arquitectura |

## Estado de capacidades del Portal

### Implementadas y reutilizables

- API Gateway YARP.
- Security API foundation.
- Configuration API.
- Menu API.
- Audit API.
- Notification API foundation.
- SQL Outbox e Inbox.
- Workers.
- Health checks.
- Logging estructurado.
- Correlation ID.
- Docker Compose y SQL Server local.
- Smoke tests.

### Pendientes o por endurecer

- Angular Portal Shell.
- Microsoft Entra ID/OIDC productivo.
- Catalog API.
- Content/File API.
- Reporting API.
- Integration API productiva.
- Workflow Engine.
- Task Inbox.
- Correo y Teams productivos.

## Orden recomendado

1. Completar capacidades bloqueantes del Portal.
2. Implementar HR.Core en paralelo.
3. Incorporar expediente cuando Content/File esté disponible.
4. Incorporar vacaciones y aprobaciones cuando Workflow y Task Inbox estén disponibles.
5. Continuar con reclutamiento, ciclo de vida, desempeño, aprendizaje, clima y compensación.
6. Mantener nómina como integración antes de evaluar un motor propio.
