# Next Codex Task

## Repository

christyepez/PortalCorporativo

## Phase

Portal PROD-local Integrated Runtime - Security Hardening

## Objective Status

`PortalProdLocalObjectiveAchieved = true`

The integrated local runtime remains healthy. The non-breaking npm remediation is complete and validated.

## Current Security Evidence

- Initial npm audit: 61 findings (6 low, 26 moderate, 28 high, 1 critical).
- After non-breaking `npm audit fix`: 55 findings (6 low, 23 moderate, 25 high, 1 critical).
- Production dependencies only: 8 findings (5 moderate, 3 high, 0 critical).
- Remaining findings require semver-major Angular / CLI / build-tooling changes according to npm.
- No `--force` or unvalidated breaking upgrade was applied.
- Frontend shell tests: 8/8 PASS.
- Frontend lint: PASS.
- Frontend production build: PASS.
- Docker `portal-web` rebuild: PASS.
- Authenticated PROD-local smoke: PASS.
- Drift check: PASS.
- Runtime verify: PASS.
- Maintenance scan: PASS; integrated containers remain at zero restarts.

## Next Gate

`PortalAngularSecurityMajorUpgrade`

Execute an evidence-driven Angular security migration on a dedicated branch. Determine the lowest supported Angular major/patch line that clears the production Angular advisories and materially reduces build-tool findings. Upgrade incrementally using Angular migrations, never `npm audit fix --force`. After each supported migration step run shell tests, lint, production build and audit. Only keep a step if all gates pass.

Then rebuild `portal-web`, rerun authenticated PROD-local smoke, drift, runtime verify and maintenance, and refresh the synchronization baseline.

## Guardrails

- Do not commit secrets, private production URLs, certificates or real data.
- Keep SRI real production transmission disabled until explicitly approved.
- Keep CRM/Financial databases bounded by their own contexts; no direct cross-domain DB coupling.
- Use the Portal Gateway as the host-facing API boundary.
- Do not persist browser access tokens.
- Do not change cloud deployment; Docker Desktop on `trabajo` remains the primary runtime.
- `MarketingIndo` synchronization remains deferred until the device is online.

## Closure Expected

Close the frontend security gate with the lowest validated major upgrade that removes the production Angular advisories without regressing Portal behavior. Document any residual development-tool-only findings separately from runtime exposure.