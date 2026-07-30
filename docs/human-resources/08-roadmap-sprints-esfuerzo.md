# Roadmap, sprints y esfuerzo

## Estrategia general

Se ejecutan dos líneas coordinadas:

1. Completar capacidades compartidas del Portal.
2. Construir HR.Core y luego dominios funcionales.

## Equipo de referencia

- Arquitecto: parcial durante todo el programa.
- Líder técnico: 1.
- Backend .NET: 2.
- Frontend Angular: 2.
- QA: 1.
- DevOps: parcial.
- Analista funcional HR: 1.
- UX/UI: parcial.
- Especialista de datos/BI: parcial desde las primeras fases.

## Etapa 0 — Descubrimiento e inventario

Duración: 3 semanas.

| Actividad | Horas |
|---|---:|
| Procesos y reglas actuales | 80 |
| Inventario de sistemas e integraciones | 40 |
| Modelo organizacional y de datos | 40 |
| Arquitectura y ADR | 48 |
| Backlog y criterios de aceptación | 40 |
| Automatización inicial Codex | 24 |
| **Total** | **272** |

## Etapa 1 — Plataforma bloqueante

Duración estimada: 10 a 14 semanas, con trabajo paralelo.

| Sprint | Entregable | Horas |
|---|---|---:|
| P2.1 | Angular Portal Shell | 260 |
| P2.2 | Entra ID/OIDC productivo | 180–240 |
| P2.3 | Content/File API | 280–380 |
| P2.4 | Catalog API | 140–200 |
| P2.5 | Workflow Engine + Task Inbox foundation | 420–600 |
| P2.6 | Correo y Teams productivos | 180–280 |
| P2.7 | Reporting e Integration hardening | 260–380 |

## Etapa 2 — HR.Core

Duración: 6 a 8 semanas.

Incluye:

- Organización.
- cargos.
- posiciones.
- personas.
- colaboradores.
- relaciones laborales.
- historial.
- permisos y menú.
- eventos y auditoría.

Esfuerzo: 1.050–1.300 horas.

## Etapa 3 — Expediente y autoservicio

Duración: 5 a 7 semanas.

- Perfil del colaborador.
- documentos.
- vencimientos.
- actualización controlada de datos.
- visor y auditoría.

Esfuerzo: 850–1.100 horas.

## Etapa 4 — Tiempo, vacaciones y permisos

Duración: 5 a 7 semanas.

Esfuerzo: 850–1.100 horas.

## Etapa 5 — Reclutamiento y ciclo de vida

Duración: 8 a 10 semanas.

Esfuerzo: 1.300–1.700 horas.

## Etapa 6 — Desempeño y aprendizaje

Duración: 8 a 10 semanas.

Esfuerzo: 1.250–1.650 horas.

## Etapa 7 — Clima, experiencia y analítica

Duración: 5 a 7 semanas.

Esfuerzo: 850–1.150 horas.

## Etapa 8 — Compensación e integración de nómina

Duración: 7 a 10 semanas.

Esfuerzo: 1.400–1.900 horas.

## Resumen del programa

Sin motor propio completo de nómina:

- Esfuerzo funcional HR: aproximadamente 7.550–9.900 horas.
- Capacidades pendientes del Portal: aproximadamente 1.720–2.340 horas.
- Total programa: aproximadamente 9.270–12.240 horas.
- Calendario estimado con equipo completo y paralelismo: 10–14 meses.

Las cifras son rangos de planificación y deben recalibrarse después del inventario funcional y tres sprints con velocidad real.

## Roadmap por horizonte

### 0–3 meses

- Descubrimiento.
- Shell.
- identidad productiva.
- Catalog y Content foundation.
- HR.Core inicial.

### 4–6 meses

- HR.Core completo.
- expediente.
- autoservicio.
- Workflow y Task Inbox.
- vacaciones y permisos.

### 7–9 meses

- Reclutamiento.
- onboarding/offboarding.
- desempeño inicial.
- integración analítica.

### 10–14 meses

- Aprendizaje.
- clima.
- compensación.
- integración de nómina.
- endurecimiento y adopción.

## Definition of Ready

Una historia está lista cuando contiene:

- Objetivo funcional.
- actor.
- reglas.
- datos.
- permisos.
- eventos.
- componentes Portal reutilizados.
- criterios de aceptación.
- casos de error.
- clasificación de datos.

## Definition of Done

- Código y migraciones.
- pruebas unitarias, integración y contrato.
- autorización backend.
- auditoría.
- observabilidad.
- documentación actualizada.
- quality gates aprobados.
- despliegue en ambiente objetivo.
- validación funcional.
