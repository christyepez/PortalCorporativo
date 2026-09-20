# PROD-local Drift Detection

`trabajo` is the authoritative local Docker Desktop runtime.

## Capture or refresh the baseline

```powershell
./scripts/local/prod-local-drift-baseline.ps1
```

The baseline is stored in `config/prod-local-baseline.json` and contains only non-secret metadata:

- external repository branch and commit SHA;
- SHA-256 of Compose files;
- required environment variable names only;
- expected Compose services;
- runtime service/image identities.

The Portal repository itself uses `RevisionPolicy=self`, so its own branch/SHA is intentionally neutralized and does not create false drift after each Portal PR.

## Check drift

```powershell
./scripts/local/prod-local-drift-check.ps1
```

Success marker: `PORTAL_PROD_LOCAL_DRIFT_CHECK_PASS`.
The check fails when:

- an external domain repository changes branch or revision;
- a Compose file hash changes without refreshing the baseline;
- a required environment variable name is missing;
- expected Compose/runtime services differ;
- a runtime service image identity differs from the captured baseline.

Secret values are never stored or compared.

## Daily maintenance integration

`prod-local-maintenance.ps1` runs drift detection automatically when the baseline exists:

```powershell
./scripts/local/prod-local-maintenance.ps1 -ScanLogs
```

Use `-SkipDrift` only for an intentional transition where the baseline is being refreshed.

`MarketingIndo` should consume this baseline only when synchronization is performed; its offline state never blocks work on `trabajo`.
