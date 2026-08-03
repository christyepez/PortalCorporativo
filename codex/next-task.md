# Next Codex Task Template

## Repository

christyepez/PortalCorporativo

## Phase

Portal Sprint P2 - Controlled Deployment Baseline

## Base Main Commit

To be filled after Portal Sprint P1 PR is merged.

## Branch

portal-sprint-p2-controlled-deployment-baseline

## Commit sugerido

docs: add portal controlled deployment baseline

## PR title

docs: add portal controlled deployment baseline

## Objetivo

Crear baseline controlado de despliegue no productivo, validando Docker runtime, health checks, Gateway, Auth/Menu/Configuration/Audit/Notification y smoke seguro sin secretos reales.

## Guardrails

- No producción.
- No secretos reales.
- No `.env` versionado.
- No tokens/certificados/URLs privadas/datos reales.
- No acoplar Portal directamente a CRM o Financiero.
- No compartir bases entre dominios.

## Validaciones

- `git diff --check`.
- Build backend.
- Tests backend.
- Docker Compose config.
- Health checks runtime si se habilita ambiente local seguro.

## Cierre esperado

- PR hacia `main`.
- No merge automático.
- NextGate documentado.
