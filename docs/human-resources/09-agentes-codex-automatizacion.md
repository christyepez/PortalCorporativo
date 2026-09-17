# Agentes Codex y automatización

## Objetivo

Evitar el flujo manual de copiar y pegar prompts entre agentes. La implementación debe iniciarse desde una historia o issue y ejecutarse mediante workflows declarativos que carguen el contexto correcto, asignen responsabilidades, validen resultados y generen un pull request.

## Repositorio común

```text
christyepez/CodexCommonAgents
```

Debe contener agentes, políticas, plantillas y workflows reutilizables. El repositorio del Portal mantiene únicamente configuración específica, referencias de versión y contexto del proyecto.

## Agentes comunes

```text
agents/
├── orchestrator
├── product-owner
├── business-analysis
├── architecture
├── reuse-discovery
├── backend-dotnet
├── frontend-angular
├── database
├── integration
├── security
├── testing
├── devops
├── documentation
└── code-review
```

## Agentes de Talento Humano

```text
agents/hr/
├── hr-domain
├── hr-core
├── recruitment
├── employee-lifecycle
├── time-attendance
├── performance
├── learning
├── employee-experience
├── compensation
├── payroll-integration
└── hr-compliance
```

## Flujo automatizado

```text
Issue
  → Orchestrator
  → Business Analysis
  → Reuse Discovery
  → Architecture
  → Security/Data review
  → Implementation agents
  → Tests
  → Code review
  → Documentation
  → Pull request
```

## Estructura sugerida

```text
automation/
├── project.yaml
├── architecture.yaml
├── modules.yaml
├── agents.yaml
├── quality-gates.yaml
├── context-manifest.yaml
├── workflows/
│   ├── analyze-epic.yaml
│   ├── implement-feature.yaml
│   ├── create-module.yaml
│   ├── fix-bug.yaml
│   ├── generate-tests.yaml
│   ├── review-pr.yaml
│   └── update-documentation.yaml
└── templates/
    ├── issue.md
    ├── implementation-plan.md
    ├── adr.md
    └── pull-request.md
```

## Ejemplo de workflow

```yaml
name: implement-feature
input:
  issue: HR-CORE-001
  module: hr-core

context:
  include:
    - docs/human-resources/README.md
    - docs/human-resources/03-mapa-reutilizacion-portal.md
    - docs/human-resources/04-arquitectura-objetivo.md
    - docs/human-resources/06-seguridad-datos-cumplimiento.md
    - src/Modules/HumanResources/Core
  exclude:
    - artifacts
    - bin
    - obj

agents:
  - business-analysis
  - reuse-discovery
  - architecture
  - hr-core
  - backend-dotnet
  - frontend-angular
  - testing
  - security
  - code-review
  - documentation

outputs:
  - implementation-plan
  - code
  - migrations
  - tests
  - api-contract
  - documentation
  - pull-request
```

## Comando objetivo

```powershell
./automation/run.ps1 implement-feature --issue HR-CORE-001
```

O en Linux:

```bash
./automation/run.sh implement-feature --issue HR-CORE-001
```

## Responsabilidad del orquestador

- Leer el issue.
- resolver dependencias.
- cargar contexto selectivo.
- ejecutar análisis de reutilización.
- crear un plan.
- asignar tareas.
- impedir cambios fuera del alcance.
- ejecutar pruebas y validaciones.
- consolidar resultados.
- crear rama, commits y PR.
- actualizar documentación y trazabilidad.

## Salida obligatoria de Reuse Discovery

```yaml
reuse_analysis:
  portal_capabilities_checked: []
  reusable: []
  extensions: []
  adapters: []
  new_domain_components: []
  prohibited_duplicates: []
  dependencies: []
  adr_required: false
```

## Controles contra prompts repetidos

- Instrucciones permanentes versionadas.
- Context manifest por workflow.
- ADR como memoria arquitectónica.
- Contratos API versionados.
- Resúmenes de módulo generados automáticamente.
- Lectura selectiva de archivos.
- Referencias al catálogo de reutilización.
- Plantillas de historias y PR.

## Límites automáticos

El workflow se detiene cuando detecta:

- Cambio de autenticación.
- acceso directo a otra base.
- nueva capacidad compartida sin ADR.
- modificación de salario o nómina sin revisión.
- datos restringidos sin permisos.
- pruebas críticas fallidas.
- secreto dentro del código.
- duplicación de un componente Portal.

## Revisión humana

Obligatoria para:

- Arquitectura nueva.
- seguridad.
- privacidad.
- contratos laborales.
- compensación.
- nómina.
- cambios destructivos de datos.
- despliegue productivo.
