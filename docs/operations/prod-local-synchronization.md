# PROD-local Synchronization Package

`trabajo` remains the authoritative local runtime. `MarketingIndo` is synchronized only when it is available.

## Generate the package

```powershell
./scripts/local/prod-local-sync-package.ps1
```

The generated `config/prod-local-sync-package.json` contains only non-secret data:

- Portal target branch (`main`);
- cross-platform normalized UTF-8/LF SHA-256 of the drift baseline;
- required local file names;
- required environment variable names only;
- external repository branch and exact revision;
- expected Compose services.

## Preflight a target machine

Use prerequisite mode before changing repositories:

```powershell
./scripts/local/prod-local-sync-preflight.ps1 -Mode Prerequisite
```

Prerequisite mode validates package schema, committed baseline SHA-256 integrity, required local files and environment names, Docker Desktop availability, repository cleanliness, free disk space, Compose configuration, and exact expected service inventory. Repository branch/revision differences are reported as `ALIGN_REQUIRED` instead of failing, because those differences are what the synchronization step is intended to correct.

Success markers:

- `PORTAL_PROD_LOCAL_SYNC_PREREQUISITE_PASS`
- `PORTAL_PROD_LOCAL_SYNC_PREFLIGHT_PASS`

After synchronization, use strict aligned mode:

```powershell
./scripts/local/prod-local-sync-preflight.ps1 -Mode Aligned
```

Aligned mode requires every external repository to match the exact branch and revision recorded in the package. `Aligned` remains the default for backward compatibility.

Success markers:

- `PORTAL_PROD_LOCAL_SYNC_ALIGNED_PASS`
- `PORTAL_PROD_LOCAL_SYNC_PREFLIGHT_PASS`

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

Recommended target-machine sequence:

```powershell
./scripts/local/prod-local-sync-preflight.ps1 -Mode Prerequisite
./scripts/local/prod-local-sync-apply.ps1 -Apply -WhatIf
./scripts/local/prod-local-sync-apply.ps1 -Apply
./scripts/local/prod-local-sync-preflight.ps1 -Mode Aligned
./scripts/local/prod-local-maintenance.ps1 -ScanLogs
```
