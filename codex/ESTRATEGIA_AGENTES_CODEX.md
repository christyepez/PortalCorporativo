# Estrategia de trabajo con agentes en Codex

Este documento define cómo usar Codex con tareas/agentes especializados para implementar el proyecto Portal Corporativo de forma ordenada, paralela y optimizada en consumo de tokens.

## Principio principal

No pedir a Codex que implemente todo el sistema en una sola tarea.

Cada agente debe tener:

- Una rama específica.
- Un objetivo concreto.
- Archivos de contexto limitados.
- Alcance cerrado.
- Criterios de aceptación.
- Resumen final.

## Regla global para todos los agentes

Antes de cada tarea usar estas reglas:

```text
1. Crea una rama nueva con el nombre indicado.
2. Lee solo los archivos indicados.
3. No leas todo el repositorio salvo que sea estrictamente necesario.
4. No implementes nada fuera del alcance.
5. No cambies decisiones de arquitectura.
6. No agregues secretos reales.
7. Mantén cambios pequeños y revisables.
8. No modifiques carpetas de otros agentes.
9. Ejecuta build y pruebas si aplica.
10. Al final resume archivos modificados, comandos ejecutados, pruebas realizadas y pendientes.
```

## Orden de rondas

### Ronda 1

Crear en paralelo:

- Agente 1: Arquitectura / Gobernanza. Rama: `chore/architecture-governance`.
- Agente 2: Backend Foundation. Rama: `feat/backend-foundation`.
- Agente 4: Frontend Foundation. Rama: `feat/angular-foundation`.

Orden de merge:

1. Arquitectura / Gobernanza.
2. Backend Foundation.
3. Frontend Foundation.

### Ronda 2

Crear después del merge de Backend Foundation:

- Agente 3: Shared Kernel. Rama: `feat/shared-kernel`.

### Ronda 3

Crear después del merge de Shared Kernel:

- Agente 5: Configuration API. Rama: `feat/configuration-api`.
- Agente 6: Catalog API. Rama: `feat/catalog-api`.
- Agente 7: Security API. Rama: `feat/security-api`.
- Agente 8: Audit API. Rama: `feat/audit-api`.

Orden de merge:

1. Configuration API.
2. Catalog API.
3. Security API.
4. Audit API.

### Ronda 4

Crear después de tener Configuration, Catalog, Security y Audit en main:

- Agente 9: Menu API. Rama: `feat/menu-api`.
- Agente 10: Angular Dynamic UI. Rama: `feat/angular-dynamic-ui`.
- Agente 11: Integration + Reporting. Rama: `feat/integration-reporting`.
- Agente 12: Content + Notification. Rama: `feat/content-notification`.
- Agente 13: Outbox + Kafka. Rama: `feat/outbox-kafka`.

Orden de merge:

1. Outbox + Kafka.
2. Menu API.
3. Integration + Reporting.
4. Content + Notification.
5. Angular Dynamic UI.

### Ronda 5

Crear al final:

- Agente 14: Docker / DevOps. Rama: `feat/docker-devops`.
- Agente 15: QA / Testing. Rama: `test/foundation-qa`.

Orden de merge:

1. Docker / DevOps.
2. QA / Testing.

## Matriz de dependencias

```text
Agente 1  Arquitectura        Sin dependencia
Agente 2  Backend Foundation  Sin dependencia
Agente 3  Shared Kernel       Depende de Agente 2
Agente 4  Frontend Foundation Sin dependencia
Agente 5  Configuration API   Depende de Agente 2 y 3
Agente 6  Catalog API         Depende de Agente 2 y 3
Agente 7  Security API        Depende de Agente 2 y 3
Agente 8  Audit API           Depende de Agente 2 y 3
Agente 9  Menu API            Depende de Agente 5 y 7
Agente 10 Angular Dynamic UI  Depende de Agente 4
Agente 11 Integration/Report  Depende de Agente 2 y 3
Agente 12 Content/Notify      Depende de Agente 2 y 3
Agente 13 Outbox/Kafka        Depende de Agente 2 y 3
Agente 14 Docker/DevOps       Depende de APIs y Angular
Agente 15 QA                  Depende de APIs implementadas
```

## Tiempo de supervisión recomendado

- PR pequeño: 15 a 30 minutos.
- PR mediano: 30 a 60 minutos.
- PR grande: 60 a 90 minutos.

Checklist de revisión:

```text
1. ¿Compila?
2. ¿Pasaron pruebas?
3. ¿Tocó archivos fuera del alcance?
4. ¿Agregó secretos?
5. ¿Quemó configuración visual?
6. ¿Cambió arquitectura sin permiso?
7. ¿El PR es demasiado grande?
```

## Prompt disparador de Ronda 1

Usar este prompt para iniciar el trabajo. Debe crear solo la primera ronda y no avanzar a rondas dependientes.

```text
Actúa como coordinador de implementación Codex para el repositorio PortalCorporativo.

Lee primero y únicamente:
- AGENTS.md
- README.md
- codex/INSTRUCTIONS.md
- codex/ARCHITECTURE_RULES.md
- codex/TASKS.md
- codex/ESTRATEGIA_AGENTES_CODEX.md

Objetivo:
Ejecutar únicamente la Ronda 1 de la estrategia de agentes.

Crea tareas o ramas separadas para:

1. Agente Arquitectura / Gobernanza
   Rama: chore/architecture-governance
   Alcance:
   - Crear docs/00-roadmap-implementacion.md
   - Crear docs/10-convenciones-codigo.md
   - Crear docs/11-estrategia-ramas-pr.md
   - Crear docs/12-matriz-servicios.md
   - Crear docs/13-contratos-entre-dominios.md
   - No crear código .NET
   - No crear Angular
   - No modificar docker-compose.yml

2. Agente Backend Foundation
   Rama: feat/backend-foundation
   Alcance:
   - Crear PortalCorporativo.sln
   - Crear estructura backend/src
   - Crear APIs ASP.NET Core para Security, Menu, Integration, Reporting, Audit, Notification, Content, Catalog y Configuration
   - Crear proyectos Domain, Application, Infrastructure y Api por cada API
   - Crear proyectos UnitTests por dominio
   - Configurar referencias entre capas
   - Crear endpoint /health en cada API
   - No implementar entidades de negocio
   - No implementar EF Core
   - No implementar autenticación

3. Agente Frontend Foundation
   Rama: feat/angular-foundation
   Alcance:
   - Crear proyecto Angular dentro de frontend/portal-angular
   - Crear estructura core, shared, layout, features, config, auth, navigation, dynamic-grid, dynamic-form y portal-shell
   - Crear shell con header, sidebar, content area y footer
   - Crear servicios base de configuration, menu, auth-context y theme
   - Crear modelos PortalTheme, MenuItem, GridDefinition, GridColumnDefinition, ActionDefinition y FormDefinition
   - Crear mocks JSON locales para tema, menú y layout
   - No implementar login real
   - No conectar APIs reales
   - No quemar colores, logos ni menús en componentes

Reglas:
- No avances a Ronda 2.
- No implementes Shared Kernel todavía.
- No implementes APIs funcionales todavía.
- No agregues secretos reales.
- No cambies el stack definido.
- Mantén cambios pequeños y revisables.
- Si no puedes crear tareas paralelas, implementa una rama por vez en el orden: arquitectura, backend, frontend.

Criterios de aceptación:
- Cada rama debe tener resumen claro.
- Backend debe ejecutar dotnet build y dotnet test si el SDK está disponible.
- Frontend debe ejecutar npm install y npm run build si Node está disponible.
- Arquitectura solo debe modificar documentación.
- No debe haber secretos reales.

Al final entrega:
- ramas creadas
- PRs creados o cambios preparados
- comandos ejecutados
- pruebas realizadas
- pendientes
```

## Prompt para correcciones cortas

Cuando un PR falle, no pedir arreglos abiertos. Usar prompts acotados:

```text
El PR falla en build/test.

Corrige únicamente el error indicado.
No agregues nuevos endpoints.
No cambies entidades.
No modifiques otros dominios.
Ejecuta build/test y resume el resultado.
```

## Prompt para revisión de PR

```text
Actúa como revisor técnico del PR actual.

Lee:
- AGENTS.md
- codex/ARCHITECTURE_RULES.md
- archivos modificados en este PR

Verifica:
1. No hay secretos reales.
2. No se quemó configuración visual.
3. No hay autorización en frontend.
4. No hay acceso directo entre bases de dominios.
5. No se cambió stack.
6. Build y tests pasan.
7. El alcance no se excedió.

Entrega:
- Observaciones críticas.
- Observaciones menores.
- Recomendación: aprobar o pedir cambios.
```

## Qué no hacer

No usar prompts como:

```text
Implementa todo el backend.
Implementa todo el portal.
Haz todo lo necesario.
Completa la aplicación.
```

Esto genera mayor consumo de tokens, PRs demasiado grandes, conflictos entre ramas y arquitectura inconsistente.
