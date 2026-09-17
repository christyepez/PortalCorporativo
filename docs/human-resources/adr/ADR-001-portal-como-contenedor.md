# ADR-001: Portal como contenedor y plataforma compartida

- Estado: Proposed
- Fecha: 2026-07-30

## Contexto

El Portal Corporativo contendrá múltiples módulos. Varias capacidades, como identidad, menú, configuración, auditoría, notificaciones, archivos, aprobaciones y observabilidad, son comunes.

## Decisión

El Portal será el contenedor de experiencia y la plataforma de capacidades transversales. Los módulos funcionales conservarán sus reglas y datos dentro de límites propios.

## Consecuencias

### Positivas

- Menor duplicación.
- Experiencia uniforme.
- Seguridad y auditoría centralizadas.
- Evolución independiente de dominios.

### Costos

- Dependencia explícita de contratos de plataforma.
- Necesidad de versionar APIs y eventos.
- Algunas funcionalidades HR quedan condicionadas a componentes comunes pendientes.

## Restricciones

- HR no puede crear otra autenticación, menú, auditoría, notificación o almacenamiento documental.
- El Portal no puede contener reglas laborales.
