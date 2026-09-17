# Architecture Decision Records

## Estado

- `Proposed`: pendiente de aprobación.
- `Accepted`: decisión vigente.
- `Superseded`: reemplazada por otra decisión.
- `Deprecated`: no debe utilizarse en nuevas implementaciones.

## Decisiones iniciales

| ADR | Decisión | Estado |
|---|---|---|
| [ADR-001](ADR-001-portal-como-contenedor.md) | Portal como contenedor y plataforma compartida | Proposed |
| [ADR-002](ADR-002-limites-del-dominio-hr.md) | Talento Humano por bounded contexts | Proposed |
| [ADR-003](ADR-003-integracion-api-eventos.md) | Integración mediante APIs, Outbox e Inbox | Proposed |
| [ADR-004](ADR-004-identidad-autorizacion.md) | Entra ID más autorización central y contextual | Proposed |
| [ADR-005](ADR-005-nomina-por-integracion.md) | Integrar nómina antes de construir motor propio | Proposed |

## Regla

Un cambio que cree una capacidad compartida, reemplace un componente del Portal, modifique autenticación/autorización o introduzca una dependencia de infraestructura debe crear o actualizar un ADR.
