# Local Docker Compose Workspace

Esta guia define un ambiente local raiz para ejecutar `PortalCorporativo` junto con dominios consumidores como `Financiero` y `CRM`.

## Principios

- Usar un solo contenedor SQL Server por ambiente local.
- Usar bases de datos separadas por dominio.
- No compartir bases entre dominios.
- No crear un SQL Server por dominio.
- No guardar secretos reales en Git.
- Usar una red Docker comun para todos los servicios.

## Estructura esperada

```text
PortalWorkspace/
  PortalCorporativo/
  Financiero/
  CRM/
```

El archivo `deploy/local/docker-compose.local.yml` vive dentro de `PortalCorporativo` y asume que `Financiero` y `CRM` estan al mismo nivel que `PortalCorporativo`.

## Servicios base

| Servicio | Proposito |
|---|---|
| sqlserver | SQL Server unico para todas las bases locales. |
| redis | Cache, locks o mensajeria liviana si aplica. |
| seq | Logs estructurados. |
| minio | Almacenamiento local compatible con S3 para archivos futuros. |
| portal-api | API principal de PortalCorporativo. |
| financiero-api | API del dominio financiero, activada con profile `financiero`. |
| crm-api | API del dominio CRM, activada con profile `crm`. |

## Bases de datos locales

Todas viven en el mismo contenedor `portal-sqlserver`:

```text
PortalCorporativoDb
FinancieroDb
CrmDb
```

## Preparacion

Desde la carpeta `PortalWorkspace`:

```powershell
git clone https://github.com/christyepez/PortalCorporativo.git
git clone https://github.com/christyepez/Financiero.git
git clone https://github.com/christyepez/CRM.git
```

Luego copia el archivo de ambiente:

```powershell
cd PortalCorporativo/deploy/local
copy .env.example .env.local
```

Edita `.env.local` y cambia valores sensibles. No subas `.env.local` al repositorio.

## Validar compose

Solo Portal:

```powershell
docker compose --env-file .env.local -f docker-compose.local.yml config
```

Portal + Financiero:

```powershell
docker compose --env-file .env.local -f docker-compose.local.yml --profile financiero config
```

Portal + Financiero + CRM:

```powershell
docker compose --env-file .env.local -f docker-compose.local.yml --profile financiero --profile crm config
```

## Levantar ambiente

Solo Portal:

```powershell
docker compose --env-file .env.local -f docker-compose.local.yml up -d --build
```

Portal + Financiero:

```powershell
docker compose --env-file .env.local -f docker-compose.local.yml --profile financiero up -d --build
```

Portal + Financiero + CRM:

```powershell
docker compose --env-file .env.local -f docker-compose.local.yml --profile financiero --profile crm up -d --build
```

## Validar SQL Server unico

```powershell
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}"
```

Debe existir solo un contenedor SQL Server:

```text
portal-sqlserver    mcr.microsoft.com/mssql/server:2022-latest    0.0.0.0:1433->1433/tcp
```

No debe existir:

```text
financiero-sqlserver
crm-sqlserver
```

## Puertos por defecto

| Servicio | URL local |
|---|---|
| portal-api | http://localhost:5001 |
| financiero-api | http://localhost:5010 |
| crm-api | http://localhost:5020 |
| seq | http://localhost:5341 |
| minio api | http://localhost:9000 |
| minio console | http://localhost:9001 |
| sqlserver | localhost,1433 |
| redis | localhost,6379 |

## Notas

- `financiero-api` y `crm-api` estan detras de profiles para evitar que fallen si los repos aun no tienen Dockerfile.
- Cuando `Financiero` o `CRM` tengan Dockerfile estable, activar su profile correspondiente.
- Si un dominio necesita migraciones, debe crear su propia base logica dentro del mismo contenedor SQL Server.
