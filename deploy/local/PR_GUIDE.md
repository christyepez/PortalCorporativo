# PR Guide for Codex Workspace Changes

Los cambios generados por Codex en una ruta local de Windows no pueden subirse desde GitHub automaticamente. Deben empujarse desde la maquina donde existen los archivos.

## PortalCorporativo Sprint 1 Foundation

```powershell
cd "C:\\Users\\ChristianYepez\\Documents\\Codex\\2026-07-06\\act-a-como-coordinator-agent-usando\\work\\PortalCorporativo"

git status
git diff --check

dotnet restore
dotnet build
dotnet test

docker compose config
.\\scripts\\smoke\\sprint1-smoke.ps1

git checkout -b sprint-1-foundation
git add .
git commit -m "feat: implement portal sprint 1 foundation"
git push origin sprint-1-foundation
```

PR sugerido:

```text
Title: feat: implement portal sprint 1 foundation
```

```text
Implementa y documenta Sprint 1 Foundation de PortalCorporativo.

Incluye:
- Platform Bootstrap.
- Security API foundation.
- Audit API.
- Outbox/Inbox.
- Workers.
- Configuration API.
- Menu API.
- Notification API.
- Autorizacion granular backend.
- QA integrado.
- Matriz de autorizacion.
- Smoke Sprint 1.
- Guia de onboarding para consumidores.
- Roadmap Sprint 2.

Validaciones reportadas:
- Build sin errores.
- Tests 50/50.
- Smoke Gateway/APIs/SQL/Worker OK.
- CorrelationId verificado.
- Notification LogDev procesado.
- Sin secretos reales.
```

## Financiero Sprint 0.1 y Diseno Contabilidad Core

```powershell
cd "C:\\Users\\ChristianYepez\\Documents\\Codex\\2026-07-06\\act-a-como-coordinator-agent-usando\\work\\Financiero"

git status
git diff --check

git checkout -b financiero-sprint-0-1-accounting-design
git add .
git commit -m "docs: prepare financiero discovery and accounting core design"
git push origin financiero-sprint-0-1-accounting-design
```

PR sugerido:

```text
Title: docs: prepare financiero discovery and accounting core design
```

```text
Prepara la base documental de Financiero alineada a PortalCorporativo y CodexCommonAgents.

Incluye:
- Sprint 0.1 documentacion base.
- PROJECT_CONTEXT.
- TASKS.
- PORTAL_INTEGRATION_CONTRACTS.
- Financial Sprint 0 Discovery.
- Arquitectura de dominio financiero.
- ADR de integracion con Portal.
- Diseno Sprint 1 Contabilidad Core.
- Matriz REUSE/EXTEND/ADAPT/CREATE/BLOCKED.

No incluye implementacion de codigo.
No incluye SRI productivo, firma, XML/RIDE, reporting ni frontend.
```

## Helper script

Tambien se incluye `scripts/push-codex-workspace.ps1` para preparar ramas desde rutas locales.

Ejemplo:

```powershell
.\\scripts\\push-codex-workspace.ps1 `
  -RepoPath "C:\\Users\\ChristianYepez\\Documents\\Codex\\2026-07-06\\act-a-como-coordinator-agent-usando\\work\\PortalCorporativo" `
  -BranchName "sprint-1-foundation" `
  -CommitMessage "feat: implement portal sprint 1 foundation"
```
