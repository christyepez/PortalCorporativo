# Portal Frontend Shell Runbook

## Install

```powershell
cd frontend
npm install
```

## Build

```powershell
cd frontend
npm run build
```

## Test

```powershell
cd frontend
npm run test
```

The current test is a non-interactive structural baseline check.

## Lint

```powershell
cd frontend
npm run lint
```

The current lint command is a non-interactive baseline check. Add full ESLint rules in a later frontend hardening gate.

## Restrictions

- Keep API paths relative or local-only.
- Do not add browser credential storage.
- Do not activate external module navigation.
- Do not add real SSO/OIDC configuration.
- Do not add private URLs or real data.
