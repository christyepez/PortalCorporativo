# Principios de priorización

## Orden de importancia

1. Desbloquear dependencias compartidas que afectan a más de un dominio.
2. Entregar una ruta vertical real antes de ampliar foundations o simulaciones.
3. Mantener trabajo paralelo solo cuando no dependa de un gate pendiente.
4. Evitar soluciones temporales que dupliquen capacidades del Portal.
5. Cerrar sprints con evidencia ejecutable, no solo con documentación.

## Modelo de peso

Cada épica se puntúa de 1 a 5 en:

- Impacto transversal.
- Valor de negocio.
- Urgencia.
- Reducción de riesgo.
- Capacidad de desbloqueo.
- Esfuerzo inverso: menor esfuerzo recibe mayor puntuación.

`Peso = 30% desbloqueo + 20% impacto transversal + 20% valor + 15% riesgo + 10% urgencia + 5% esfuerzo inverso`.

## Clases de prioridad

| Clase | Uso |
|---|---|
| P0 | Incidente o bloqueo total del programa |
| P1 | Desbloquea dos o más dominios |
| P2 | Entrega capacidad productiva de un dominio |
| P3 | Mejora, deuda o automatización no bloqueante |
| P4 | Exploración o trabajo futuro |

## Reglas

- Un P1 compartido tiene prioridad sobre un P2 de dominio.
- No se inicia una historia sin Definition of Ready.
- Una dependencia externa sin responsable y fecha no entra al sprint.
- Un dominio bloqueado debe tomar trabajo desacoplado; no crear reemplazos locales.
- Máximo 20% de capacidad en trabajo no planificado.
- Máximo dos iniciativas críticas simultáneas por equipo.
