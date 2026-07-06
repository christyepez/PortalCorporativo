# Local Compose Checklist

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
