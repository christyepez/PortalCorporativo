# Capacidad, equipo y pesos

## Distribución recomendada del PI-1

| Frente | Capacidad |
|---|---:|
| Portal Runtime/Shell/Auth | 35% |
| Servicios compartidos | 20% |
| CRM | 15% |
| Financiero | 10% |
| Talento Humano | 10% |
| Codex/QA/Gobierno | 10% |

## Equipo mínimo recomendado

- Arquitecto/líder técnico: 1.
- Backend .NET: 3.
- Frontend: 2.
- DevOps/infra: 1.
- QA automatización: 1.
- Analista funcional compartido: 1.
- UX parcial: 0,5.

Con menos personas se mantiene el orden, pero se reducen streams activos; no se reparte una persona entre más de dos streams críticos.

## Capacidad por sprint

- 70% historias comprometidas.
- 15% integración, QA y deuda.
- 10% contingencia por dependencias.
- 5% documentación/ADR.

## Tamaño de historias

| Tamaño | Esfuerzo orientativo | Regla |
|---|---:|---|
| S | 8–20 h | Una capacidad simple |
| M | 20–50 h | Caso de uso completo |
| L | 50–100 h | Dividir antes del sprint |
| XL | Más de 100 h | No entra como historia |

## Política de WIP

- Máximo dos historias activas por desarrollador.
- Máximo una épica P1 activa por subequipo.
- Integración y pruebas forman parte de la historia, no una fase posterior.
- No iniciar más trabajo si una historia terminada espera revisión o despliegue.
