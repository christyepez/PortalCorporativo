# Root Workspace Setup

## Objetivo

Ejecutar localmente `PortalCorporativo` junto con dominios consumidores sin duplicar infraestructura.

## Layout recomendado

```text
C:\Dev\PortalWorkspace
  PortalCorporativo
  Financiero
  CRM
```

## Clonar repos

```powershell
mkdir C:\Dev\PortalWorkspace
cd C:\Dev\PortalWorkspace

git clone https://github.com/christyepez/PortalCorporativo.git
git clone https://github.com/christyepez/Financiero.git
git clone https://github.com/christyepez/CRM.git
```

## Cambiar ramas de trabajo

```powershell
cd C:\Dev\PortalWorkspace\PortalCorporativo
git checkout sprint-1-foundation

cd C:\Dev\PortalWorkspace\Financiero
git checkout financiero-sprint-0-1-accounting-design
```

## Configurar variables locales

```powershell
cd C:\Dev\PortalWorkspace\PortalCorporativo\deploy\local
copy .env.example .env.local
notepad .env.local
```

## Validar compose

```powershell
.\scripts\validate-local-compose.ps1
```

Con Financiero:

```powershell
.\scripts\validate-local-compose.ps1 -WithFinanciero
```

Con CRM:

```powershell
.\scripts\validate-local-compose.ps1 -WithFinanciero -WithCrm
```

## Levantar servicios

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

Debe existir solo:

```text
portal-sqlserver
```

No deben existir:

```text
financiero-sqlserver
crm-sqlserver
```
