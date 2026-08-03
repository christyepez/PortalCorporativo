# Portal External Consumer Security Contract

## Purpose

Define how external consumers integrate with Portal Security without duplicating identity, login or platform authorization.

## Contract

- Portal owns platform users, roles, protected resources and permission decisions.
- Consumers define domain resources and action permission codes for review.
- Claims must be trusted only after Portal Auth integration gates approve the source.
- Consumers must not create parallel login, global role stores or token stores.

## Required security inputs

- module code.
- resource keys.
- permission codes.
- role mapping proposal.
- least privilege notes.
- forbidden actions.
- audit requirements for permission-sensitive actions.

## Sprint 16 status

ConsumerSecurityContractPrepared: true.
