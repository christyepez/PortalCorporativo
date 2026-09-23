# Estimación y control de tokens Codex

## Propósito

Establecer un modelo de planificación para consumo de contexto, generación, pruebas y revisión. Los valores son rangos operativos, no garantías de facturación.

## Unidad de estimación

El consumo se calcula por ejecución completa:

```text
Tokens totales
= entrada de contexto
+ razonamiento y generación
+ respuestas de herramientas
+ correcciones
+ pruebas y revisión
```

## Rangos de referencia

| Trabajo | Tokens estimados |
|---|---:|
| Análisis de historia pequeña | 30.000–80.000 |
| Implementación pequeña | 80.000–180.000 |
| Historia mediana | 180.000–450.000 |
| Historia grande | 450.000–900.000 |
| Épica | 1,5–4 millones |
| Módulo funcional | 6–15 millones |
| Plataforma HR inicial | 45–90 millones |

## Factores de ajuste

### Aumentan consumo

- Repositorio completo como contexto.
- Historias ambiguas.
- Arquitectura no documentada.
- pruebas inestables.
- errores de compilación repetitivos.
- múltiples tecnologías en una misma tarea.
- cambios transversales.
- relectura de documentos completos.
- ausencia de contratos y ejemplos.

### Reducen consumo

- Context manifest selectivo.
- ADR claros.
- historias con criterios de aceptación.
- componentes reutilizables documentados.
- contratos API y eventos versionados.
- compilación y pruebas locales rápidas.
- diffs pequeños.
- agentes especializados.
- resúmenes de módulo actualizados.

## Modelo por historia

```text
Estimación = Base × Complejidad × Riesgo × Iteración
```

Valores sugeridos:

| Factor | Bajo | Medio | Alto |
|---|---:|---:|---:|
| Complejidad | 0,8 | 1,0 | 1,5 |
| Riesgo | 0,9 | 1,1 | 1,5 |
| Iteración esperada | 1,0 | 1,3 | 1,8 |

Base sugerida: 180.000 tokens para una historia mediana.

Ejemplo:

```text
180.000 × 1,0 × 1,1 × 1,3 = 257.400 tokens
```

## Presupuesto por sprint

Para un sprint con 8 historias medianas:

- Mínimo: 1,4 millones.
- Esperado: 2,0–3,5 millones.
- Alto: 5 millones o más si existen correcciones estructurales.

Se debe registrar consumo real por workflow para recalibrar después de tres sprints.

## Telemetría requerida

```yaml
codex_usage:
  workflow: implement-feature
  issue: HR-CORE-001
  input_tokens: 0
  output_tokens: 0
  tool_tokens: 0
  retries: 0
  files_read: 0
  files_changed: 0
  tests_executed: 0
  result: success
```

## Políticas de control

- No cargar todo el monorepo por defecto.
- Limitar contexto al dominio y contratos necesarios.
- Detener iteraciones cuando la causa sea falta de definición funcional.
- No regenerar archivos completos por cambios pequeños.
- Revisar por diff.
- Reutilizar resultados de análisis válidos.
- Separar épicas grandes en historias implementables.
- Exigir límite de archivos modificados por workflow.

## Estimación de costo

El costo monetario no debe fijarse en documentación estática porque depende del modelo, plan, precios y modalidad vigentes. El pipeline debe utilizar los precios configurados en el momento de ejecución:

```text
Costo estimado
= tokens de entrada × tarifa de entrada
+ tokens de salida × tarifa de salida
+ herramientas o infraestructura adicional
```

La configuración de tarifas debe mantenerse fuera del código del dominio y actualizarse sin modificar los workflows.

## Indicadores

- Tokens por historia terminada.
- Tokens por punto de historia.
- Tokens por archivo modificado.
- Porcentaje usado en correcciones.
- Número de reintentos.
- Tasa de PR aprobados sin retrabajo.
- Porcentaje de contexto reutilizado.
