# AGENTS.md

## Reglas para agentes de código

Lee primero:

- README.md
- codex/INSTRUCTIONS.md
- codex/ARCHITECTURE_RULES.md
- codex/TASKS.md

No leas todo el repositorio si la tarea no lo requiere.

## Stack

- Backend: .NET 8 / ASP.NET Core
- Frontend: Angular
- Docker Compose
- SQL Server
- Redis
- SQL Outbox inicial
- Kafka preparado para fase futura

## Reglas principales

- No rediseñar arquitectura sin justificar.
- No quemar configuración visual en código.
- No implementar autorización en frontend.
- No pasar tokens reales por URL.
- No crear dependencia directa entre bases de distintos dominios.
- Cada API debe mantener su bounded context.
- Usar Clean Architecture, DDD y SOLID.
- Crear pruebas unitarias para reglas de dominio.
- Mantener cambios pequeños y revisables.

## Antes de modificar

1. Explica brevemente qué archivos tocarás.
2. Implementa solo el alcance solicitado.
3. Ejecuta build y pruebas cuando aplique.
4. Resume cambios y comandos ejecutados.

## Principio de configuración

Todo lo visual y funcional debe ser parametrizable y administrable:

- Menús
- Logos
- Imágenes
- Temas
- Colores
- Layouts
- Grids
- Buscadores
- Paginación
- Acciones
- Formularios
- Permisos
- Integraciones

## Modelo de negocio

El modelo debe ser agnóstico al giro de negocio. No crear entidades acopladas a una industria específica si pueden modelarse como sistemas, recursos, catálogos, formularios, reportes, contenidos o metadata configurable.
