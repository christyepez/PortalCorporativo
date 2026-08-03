# Portal External Consumer Module Contract

## Required module metadata

- module code.
- display name.
- owner.
- relative route prefix.
- health endpoint contract.
- protected resource keys.
- permission codes.
- menu entries.
- configuration keys.
- audit events.
- notification templates or event intents.
- deployment owner.
- rollback owner.

## Rules

- Module metadata must not include secrets, tokens, certificates, private URLs or real customer data.
- Route prefixes must be relative.
- Module codes must be stable and lowercase.
- Portal owns platform registration and approval.
- Consumers own their domain behavior.

## Sprint 16 status

ConsumerModuleContractPrepared: true.
