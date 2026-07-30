# ADR-002: Límites del dominio Talento Humano

- Estado: Proposed
- Fecha: 2026-07-30

## Contexto

Talento Humano cubre capacidades con ritmos, reglas y niveles de sensibilidad diferentes. Un único módulo monolítico aumentaría acoplamiento y riesgo.

## Decisión

Dividir Talento Humano en bounded contexts: Core, Recruitment, EmployeeLifecycle, Time, Performance, Learning, EmployeeExperience, Compensation y PayrollIntegration.

Cada contexto controla sus datos y publica contratos o eventos.

## Consecuencias

- Despliegue y evolución progresivos.
- Límites de seguridad más claros.
- Consistencia eventual entre contextos.
- Mayor necesidad de contratos, Outbox, Inbox y observabilidad.

## Restricciones

- No compartir tablas.
- No acceder directamente a bases de otro contexto.
- HR.Core publica la identidad funcional del colaborador; otros módulos no duplican su maestro.
