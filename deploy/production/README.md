# External production activation package

This folder prepares the Portal for a future external/cloud production activation gate. It does not contain production credentials and does not authorize deployment.

## Inputs

Copy `activation-inputs.example.json` outside the repository or to a local ignored file and replace every placeholder with approved deployment metadata.

The file contains only non-secret activation metadata: OIDC authority/audience/client registration identifiers, redirect/logout URIs, provider ownership, network endpoint names, operational owners, approvals and guardrails.

Do not add client secrets, passwords, tokens, private keys or certificates to this file.

## Preflight

Run:

```powershell
./scripts/production/validate-activation-inputs.ps1 -Path <local-input-file>
```

The validator never prints configured values. It reports only field names and PASS/FAIL status.

`PRODUCTION_ACTIVATION_PREFLIGHT_PASS` means the required metadata and approvals are present. It does not deploy anything and it does not override Security, Architecture or Operations approval processes.

`PRODUCTION_ACTIVATION_PREFLIGHT_NOGO` means at least one required input is missing, is still a placeholder, violates the HTTPS/guardrail rules, or lacks approval.

## Runtime mapping

When activation is approved, backend OIDC validation maps the approved authority and audience to `Jwt__Authority` and `Jwt__Audience`. `Jwt__RequireHttpsMetadata` remains `true`.

Browser token persistence remains disabled. Real SRI transmission remains disabled until separately approved.
