# Current Codex Task

Title: Portal frontend dependency vulnerability remediation.

Status: NON-BREAKING REMEDIATION COMPLETE on `trabajo`. `MarketingIndo` remains deferred and never blocks implementation.

Objective: reduce npm audit exposure without forcing a major Angular upgrade, then prove the PROD-local runtime remains stable.

Evidence: npm audit reduced from 61 to 55 total findings after compatible lockfile remediation; production dependency audit is 8 findings (5 moderate, 3 high, 0 critical). Shell contract tests remain 8/8 PASS, TypeScript/policy lint PASS, Angular production build PASS, Docker `portal-web` rebuild PASS, authenticated PROD-local smoke PASS, drift PASS, runtime verify PASS and maintenance PASS with zero restarts.

Decision: no `npm audit fix --force` was used. Remaining findings are rooted in Angular 18 / CLI / build-tooling dependency lines and npm proposes semver-major upgrades.

Guardrail: preserve Gateway boundaries, local-production operation and browser-token persistence protections. Real SRI, OIDC/SSO, external notifications and integration transport remain disabled.