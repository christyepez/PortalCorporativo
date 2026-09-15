# Métricas de seguimiento

## Métricas principales

| Métrica | Meta PI-1 |
|---|---:|
| Historias terminadas/iniciadas | >= 0,85 |
| Tiempo bloqueado promedio P1 | < 24 h |
| PR revisados en 24 h | >= 90% |
| E2E ejecutados durante sprint | 100% de verticales |
| Dependencias con owner y fecha | 100% |
| Capacidades compartidas duplicadas | 0 |
| Sprints cerrados solo con documentación | 0 |
| Defectos críticos escapados | 0 |

## Indicadores por sprint

- Throughput por stream.
- Cycle time.
- Aging de WIP.
- tiempo en `waiting-evidence`.
- porcentaje de trabajo P1/P2/P3.
- porcentaje de capacidad consumida por bloqueos.
- pruebas unitarias, integración y E2E.
- deuda crítica abierta/cerrada.

## Semáforo

### Verde

- Dependencias P1 menores a 24 horas.
- ratio terminado/iniciado mayor o igual a 0,85.
- gates del sprint con evidencia.

### Amarillo

- Bloqueo P1 entre 24 y 48 horas.
- más del 20% de capacidad no planificada.
- PR o E2E acumulándose al final.

### Rojo

- Bloqueo P1 mayor a 48 horas.
- dependencia crítica sin owner.
- sprint cerrado sin runtime verificable.
- duplicación de capacidad compartida.

## Reporte de cierre

Cada sprint publica:

1. Objetivos logrados y no logrados.
2. Evidencias y enlaces a PR.
3. dependencias abiertas.
4. métricas.
5. riesgos.
6. decisiones para el siguiente sprint.
7. cambios al camino crítico.
