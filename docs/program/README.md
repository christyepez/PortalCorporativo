# Programa Portal Corporativo

Este directorio define la secuencia global de implementación para PortalCorporativo, CRM, Financiero, AppTTHH y CodexCommonAgents.

## Objetivo

Evitar que los dominios avancen de forma aislada, dupliquen capacidades compartidas o acumulen sprints de documentación sin desbloquear ejecución real.

## Documentos

1. [01-principios-priorizacion.md](01-principios-priorizacion.md)
2. [02-mapa-dependencias.md](02-mapa-dependencias.md)
3. [03-roadmap-sprints.md](03-roadmap-sprints.md)
4. [04-hilos-paralelos.md](04-hilos-paralelos.md)
5. [05-gates-entrada-salida.md](05-gates-entrada-salida.md)
6. [06-capacidad-equipo-pesos.md](06-capacidad-equipo-pesos.md)
7. [07-control-cuellos-botella.md](07-control-cuellos-botella.md)
8. [08-automatizacion-codex.md](08-automatizacion-codex.md)
9. [09-backlog-program-increment-1.md](09-backlog-program-increment-1.md)
10. [10-metricas-seguimiento.md](10-metricas-seguimiento.md)

## Repositorios del programa

- `christyepez/PortalCorporativo`
- `christyepez/CRM`
- `christyepez/Financiero`
- `christyepez/AppTTHH`
- `christyepez/CodexCommonAgents`

## Regla operativa

Ningún dominio debe construir Gateway, Shell, autenticación, autorización global, menú, auditoría, notificaciones, almacenamiento documental, workflow o task inbox propios para esquivar una dependencia del Portal.
