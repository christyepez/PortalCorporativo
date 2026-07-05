# Integración con CodexCommonAgents

Repositorio común:

```text
https://github.com/christyepez/CodexCommonAgents
```

## Propósito

Este archivo define cómo `PortalCorporativo` debe integrarse con el repositorio común de agentes, reglas y playbooks para evitar duplicación de contexto en Codex.

## Orden de lectura recomendado

Codex debe leer únicamente lo necesario:

1. `AGENTS.md`.
2. `README.md`.
3. `codex/INSTRUCTIONS.md`.
4. `codex/ARCHITECTURE_RULES.md`.
5. `codex/REUSABLE_CAPABILITIES.md`.
6. `CodexCommonAgents/AGENTS.md` si se está trabajando con reglas comunes.
7. Playbook aplicable de `CodexCommonAgents/playbooks/`.

## Rol de PortalCorporativo

PortalCorporativo es la plataforma transversal y debe exponer capacidades reutilizables para otros dominios:

- Financiero.
- CRM.
- Otros módulos corporativos futuros.

## Regla de mantenimiento

Cuando se agregue una nueva API transversal, actualizar:

1. `README.md`.
2. `codex/REUSABLE_CAPABILITIES.md`.
3. Contratos OpenAPI o documentación técnica.
4. Plantillas del repositorio común si la capacidad impacta nuevos proyectos.

## Modo bajo consumo de tokens

Para tareas puntuales no leer todo el repositorio. Usar:

```text
AGENTS.md
codex/INSTRUCTIONS.md
codex/ARCHITECTURE_RULES.md
codex/REUSABLE_CAPABILITIES.md
```
