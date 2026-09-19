# External Production Activation Input Review Checklist

Use this checklist only after the non-secret activation input file passes `validate-activation-inputs.ps1`.

## Identity and access

- [ ] OIDC/OAuth2 authority was supplied by the approved identity team.
- [ ] Audience/API identifier is approved for Portal.
- [ ] Client ID belongs to the Portal production registration.
- [ ] Redirect and logout URIs are HTTPS and match the production registration.
- [ ] Permission claim mapping is documented and mapped to Portal permission policies.
- [ ] HTTPS metadata remains required.
- [ ] No client secret, token, certificate material or private key is stored in the input file or repository.

## Secret provider

- [ ] Secret provider technology is approved.
- [ ] Platform owner is named.
- [ ] Rotation owner is named.
- [ ] Rotation interval and emergency rotation procedure exist outside source control.
- [ ] Application identities have least-privilege access to required secrets only.

## Network and infrastructure

- [ ] SQL Server endpoint is approved and reachable only from intended runtime networks.
- [ ] Redis endpoint is approved and access controlled.
- [ ] Object storage endpoint is approved and access controlled.
- [ ] Observability endpoint is approved.
- [ ] Firewall/private endpoint/DNS ownership is identified.
- [ ] Backup and restore responsibilities are accepted.

## Operations

- [ ] Release approver is named.
- [ ] Incident owner is named.
- [ ] Backup owner is named.
- [ ] Observability owner is named.
- [ ] Rollback runbook has been reviewed.
- [ ] Health/readiness and smoke validation are part of release verification.

## Architecture, security and operations approvals

- [ ] Architecture approval = Approved.
- [ ] Security approval = Approved.
- [ ] Operations approval = Approved.

## Guardrails that must remain false

- [ ] Real SRI transmission is disabled.
- [ ] Browser token persistence is disabled.
- [ ] Secrets in repository are disabled.

## Exit criteria

The review may advance to a deployment-specific change plan only when:
1. the validator returns `PRODUCTION_ACTIVATION_PREFLIGHT_PASS`;
2. every checklist item is evidenced;
3. required approvals are explicit;
4. production credentials remain outside the repository.

A completed review is not itself authorization to deploy or enable irreversible integrations.
