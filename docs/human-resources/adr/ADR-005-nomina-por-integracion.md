# ADR-005: Integrar nómina antes de construir un motor propio

- Estado: Proposed
- Fecha: 2026-07-30

## Contexto

La nómina concentra reglas legales, financieras, contables y operativas de alto riesgo. Ya existe un sistema que puede continuar calculándola mientras el Portal consolida HR Core, tiempo, contratos y compensación.

## Decisión

La primera estrategia será integrar novedades, resultados, roles y reconciliación con el sistema de nómina existente. Un motor propio solo se evaluará después de estabilizar los datos y procesos precursores.

## Consecuencias

- Menor riesgo inicial.
- Entrega de valor más rápida.
- Dependencia temporal del sistema actual.
- Necesidad de contratos, conciliación y operación de soporte.

## Criterios para reevaluar

- HR Core estable.
- reglas de tiempo y compensación maduras.
- inventario legal completo.
- costo total de integración conocido.
- pruebas paralelas de cálculo disponibles.
- aprobación ejecutiva, financiera y legal.
