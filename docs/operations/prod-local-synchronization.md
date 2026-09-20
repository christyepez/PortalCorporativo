# PROD-local Synchronization Package

`trabajo` remains the authoritative local runtime. `MarketingIndo` is synchronized only when it is available.

## Generate the package

```powershell
./scripts/local/prod-local-sync-package.ps1
```

The generated `config/prod-local-sync-package.json` contains only non-secret data:

- Portal target branch (`main`);
- drift-baseline SHA-256;
- required local file names;
- required environment variable names only;
- external repository branch and exact revision;
- expected Compose services.

## Preflight a target machine

```powershell
./scripts/local/prod-local-sync-preflight.ps1
```

The preflight checks Docker Desktop availability, required local env file names, external repository revisions, free disk space and Compose configuration without exposing secret values.
Success marker: `PORTAL_PROD_LOCAL_SYNC_PREFLIGHT_PASS`.

## Apply repository synchronization

Review first; without `-Apply` the script refuses to modify repositories.

```powershell
./scripts/local/prod-local-sync-apply.ps1 -Apply
```

Safety rules:

- every repository must be clean;
- only fast-forward synchronization is allowed;
- Portal moves to `main`;
- external repositories move only to the exact branch/revision recorded in the package;
- no reset/force operation is used;
- environment files and backup data are never copied by this script.

Use `-Apply -WhatIf` to preview repository actions without changing them.

After synchronization, run:

```powershell
./scripts/local/prod-local-sync-preflight.ps1
./scripts/local/prod-local-maintenance.ps1 -ScanLogs
```
