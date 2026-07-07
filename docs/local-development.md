# Ejecucion local

## Requisitos

- Docker con Compose v2.
- .NET 8 SDK para desarrollo fuera de contenedores. Un SDK posterior puede compilar si dispone de los targeting packs de .NET 8.

## Inicio

1. Copiar `.env.example` a `.env`.
2. Reemplazar todos los valores `CHANGE_ME`; `.env` no se versiona.
3. Ejecutar `./scripts/run-local.ps1` desde PowerShell.
4. Consultar Gateway en `http://localhost:8080/` y sus checks en `/health/live` y `/health/ready`.
5. Consultar Seq en `http://localhost:5341`.

Para detener los contenedores, ejecutar `./scripts/stop-local.ps1`. Los datos persisten en volumenes Docker; `docker compose down -v` solo debe usarse cuando se desee eliminarlos deliberadamente.

## Build sin Docker

Desde `backend/`:

```powershell
dotnet restore PortalCorporativo.sln
dotnet build PortalCorporativo.sln --no-restore
```

El Gateway y las APIs protegidas exigen `Jwt__Secret`. Sprint 1 expone Security, Configuration, Menu, Audit y Notification bajo Gateway; cada endpoint valida JWT y el claim `permission` correspondiente. Health permanece anónimo. Para validar el conjunto usar `scripts/smoke/sprint1-smoke.ps1`.
