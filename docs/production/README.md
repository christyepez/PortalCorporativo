# External production activation preflight

This package validates whether the Portal has the minimum external inputs required before any real production activation is attempted.

It does **not** deploy infrastructure, configure an IdP, rotate secrets, enable SRI transmission, or contact external providers.

## Files

- `activation-inputs.template.json`: non-secret template. Copy it outside the repository and replace placeholders with approved values.
- `../../scripts/production/validate-activation-inputs.ps1`: validator used by operators and CI-style checks.
- `../../scripts/production/test-validate-activation-inputs.ps1`: self-test for PASS/NOGO and sensitive-property rejection.

## Usage

Create a working copy outside the repository, for example:

```powershell
Copy-Item .\docs\production\activation-inputs.template.json C:\Temp\portal-activation-inputs.json
```

Populate only identifiers, endpoints, owners and approval states. Never place passwords, client secrets, tokens, private keys, certificates or production credentials in the input file.

Run the validator:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\production\validate-activation-inputs.ps1 -Path C:\Temp\portal-activation-inputs.json
```

A successful preflight ends with `PRODUCTION_ACTIVATION_PREFLIGHT_PASS`. Missing placeholders, non-HTTPS identity URLs, incomplete approvals, prohibited sensitive properties or disabled guardrails end with `PRODUCTION_ACTIVATION_PREFLIGHT_NOGO`.

## Activation boundary

A PASS means only that the required inputs are present and structurally acceptable for the next review gate. It is not authorization to deploy to cloud production or enable irreversible integrations.

The following remain separate approval steps: IdP/OIDC registration, secret-provider provisioning, production network access, certificates, provider credentials, change/release approval and SRI production activation.
