# Roadmap de sprints

Se proponen sprints de dos semanas y un Program Increment inicial de 12 semanas.

## Sprint 0 — Gobierno y preparación

**Peso:** 10% del PI.

- Fusionar documentación y ADR.
- Crear tablero global, etiquetas y plantillas.
- Registrar dependencias y owners.
- Implementar workflow Codex básico.
- Definir ambientes, contratos y Definition of Done.

**Salida:** backlog priorizado y trabajo ejecutable en los cinco repositorios.

## Sprint 1 — Desbloqueo de infraestructura

**Peso:** 20%.

- SQL común accesible desde Docker.
- Secret Provider no productivo.
- Gateway `/health` y `/ready` con HTTP 200.
- propagación de correlation ID.
- runbook y evidencia automatizada.

**Paralelo:** HR Core skeleton, CRM ruta vertical diseñada, Financiero pruebas desacopladas.

## Sprint 2 — Portal Shell, identidad y contexto

**Peso:** 20%.

- Shell mínimo operativo.
- Entra ID/OIDC.
- contexto usuario/tenant/sede.
- menú dinámico y permisos.
- navegación a CRM, Financiero y TTHH.

**Salida:** usuario autenticado navega hacia módulos detrás del Gateway.

## Sprint 3 — Primera vertical productiva

**Peso:** 20%.

- CRM: Cliente/Organización CRUD real, sin DELETE inicialmente.
- Financiero: reabrir preflight y E2E técnico.
- TTHH: estructura organizacional y cargos.
- auditoría, outbox, health y pruebas.

**Salida:** al menos una ruta funcional real de CRM y HR detrás del Portal; Financiero `SCRIPT_EXIT=0` o bloqueo nuevo documentado con evidencia fresca.

## Sprint 4 — Servicios compartidos de alto impacto

**Peso:** 15%.

- Content/File MVP.
- Catalog MVP.
- notificaciones reales de no producción.
- adaptadores en CRM, Financiero y TTHH.

## Sprint 5 — Procesos y bandeja

**Peso:** 10%.

- Workflow foundation.
- Task Inbox MVP.
- caso piloto transversal: aprobación simple.
- preparar vacaciones HR, seguimiento CRM y aprobación Financiero.

## Sprint 6 — Consolidación del PI

**Peso:** 5%.

- E2E multi-repo.
- hardening de seguridad.
- observabilidad.
- deuda crítica.
- métricas, retrospectiva y roadmap PI-2.

## Condición para alterar el orden

Solo se altera por incidente P0, riesgo de seguridad, cambio legal obligatorio o bloqueo cuyo trabajo desbloqueador tenga mayor peso calculado.
