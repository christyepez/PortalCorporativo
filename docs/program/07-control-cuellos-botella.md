# Control de cuellos de botella

## Señales tempranas

- Historia bloqueada más de 24 horas.
- PR sin revisión más de 24 horas.
- dependencia sin owner o fecha.
- más trabajo iniciado que terminado.
- repetición de documentos sin cambio de estado runtime.
- un servicio compartido requerido por dos dominios sin backlog propio.
- pruebas E2E ejecutadas solo al final del sprint.

## Protocolo de bloqueo

1. Registrar el bloqueo en el tablero global.
2. Identificar proveedor, consumidor y owner.
3. Definir evidencia requerida y fecha límite.
4. Escalar a las 24 horas si es P1.
5. Cambiar al backlog `ready-without-dependency`.
6. No implementar duplicados locales.
7. Cerrar el bloqueo solo con evidencia reproducible.

## Backlog alternativo por stream

| Stream bloqueado | Trabajo alternativo permitido |
|---|---|
| Portal Runtime | pruebas, runbooks, observabilidad, contratos |
| CRM | dominio, validaciones, pruebas y UI con adaptadores mock |
| Financiero | reglas contables, SRI foundation, pruebas y seguridad |
| TTHH | HR Core que no use archivos/workflow |
| Servicios compartidos | contrato, SDK cliente y pruebas de compatibilidad |

## Límites

- Ningún bloqueo se arrastra por más de dos sprints sin decisión ejecutiva: resolver, cambiar alcance o pausar.
- No crear un nuevo sprint dedicado únicamente a registrar el mismo bloqueo.
- Toda dependencia crítica debe tener una historia en el repositorio proveedor.
- El consumidor no declara PASS basándose en mocks cuando el gate exige runtime real.

## Tablero recomendado

Columnas:

`Ready → In Progress → Integration → Review → E2E → Done`

Carriles:

`P0/P1`, `Portal`, `CRM`, `Financiero`, `TTHH`, `Shared`, `Codex/QA`.

Estados adicionales:

- `blocked-external`
- `blocked-contract`
- `ready-without-dependency`
- `waiting-evidence`
