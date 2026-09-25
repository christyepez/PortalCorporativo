# Local Compose Checklist

> **Legacy checklist:** the active runtime checklist is the root PROD-local lifecycle (`scripts/local/prod-local-*.ps1`). This file documents the older profile-based `deploy/local` workspace and must not be used to validate the current integrated Portal runtime.
>
> Current validation:
> ```powershell
> ./scripts/local/prod-local-status.ps1
> ./scripts/local/prod-local-verify.ps1 -ScanLogs
> ./scripts/local/prod-local-drift-check.ps1
> ```

## Antes de ejecutar

- [ ] `.env.local` existe y no esta versionado.
- [ ] `SQL_PASSWORD` fue cambiado y no usa el valor de ejemplo.
- [ ] `docker-compose.local.yml` valida correctamente.
- [ ] Solo hay un servicio SQL Server.
- [ ] `Financiero` y `CRM` estan al mismo nivel que `PortalCorporativo` si se usan profiles.

## Validacion

```powershell
cd deploy/local
.\scripts\validate-local-compose.ps1
```

## Validacion con dominios

```powershell
.\scripts\validate-local-compose.ps1 -WithFinanciero
.\scripts\validate-local-compose.ps1 -WithFinanciero -WithCrm
```

## Resultado esperado

```text
OK: exactly one SQL Server service is configured.
Expected logical databases: PortalCorporativoDb, FinancieroDb, CrmDb.
```

## Regla de arquitectura

```text
Un contenedor SQL Server por ambiente local.
Una base de datos por dominio.
Sin bases compartidas entre dominios.
Sin contenedores SQL por dominio.
```
