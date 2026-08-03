# Portal Secret Lifecycle

## Creation

Secrets are created outside Git through an approved provider or local untracked developer configuration. Every secret must have an owner, environment and purpose.

## Rotation

Rotation must define:

- rotation owner.
- target services.
- old and new secret overlap window.
- rollback plan.
- smoke validation.

## Expiration

Secrets should have explicit expiration metadata when supported by the provider. Expiration must trigger renewal before service impact.

## Revocation

Compromised secrets must be revoked immediately, followed by service restart, audit review and consumer notification when applicable.

## Audit

Secret access and changes must be audited by the provider and correlated with Portal deployment or incident records.

## Sprint 14 boundary

This sprint documents lifecycle only. It does not create, rotate, expire or revoke real secrets.
