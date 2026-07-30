# Automatización Codex

## Objetivo

Convertir épicas e historias en ejecuciones repetibles sin copiar prompts entre repositorios.

## Workflow principal

```text
program-orchestrator
  → dependency-check
  → reuse-analysis
  → architecture-plan
  → implementation
  → tests
  → cross-repo-contract-validation
  → E2E
  → documentation
  → pull-request
```

## Contexto obligatorio

- `docs/program/` de PortalCorporativo.
- ADR del Portal.
- catálogo de capacidades reutilizables.
- documentación del dominio propietario.
- contratos API/eventos versionados.
- issue actual y dependencias.

## Comandos objetivo

```powershell
./automation/program-workflow.ps1 plan --issue PORTAL-RUNTIME-001
./automation/program-workflow.ps1 implement --repo CRM --issue CRM-CUSTOMER-001
./automation/program-workflow.ps1 validate-contract --provider PortalCorporativo --consumer Financiero
./automation/program-workflow.ps1 run-e2e --scenario portal-financiero
```

## Quality gates automáticos

- Prohibir autenticación, Gateway, Shell y auditoría duplicados.
- Verificar permisos backend.
- detectar secretos y connection strings.
- validar health/readiness.
- ejecutar pruebas y lint.
- verificar migraciones y compatibilidad de contratos.
- exigir evidencia para declarar PASS.

## Handoff automático

Cuando una historia consumidora descubre una dependencia:

1. Crear issue en el repositorio proveedor.
2. Vincular issue consumidor/proveedor.
3. asignar prioridad calculada.
4. registrar contrato esperado.
5. bloquear solo la historia afectada.
6. sugerir trabajo alternativo.

## Repositorio coordinador

`CodexCommonAgents` mantiene agentes y workflows; `PortalCorporativo/docs/program` mantiene la política y secuencia del programa.
