# Consumer Runtime Pilot Contract Minimums

## Module metadata

Consumer modules must provide a stable module code, display name, lifecycle status and ownership metadata.

## Navigation

Navigation must be registered through Portal Menu contracts. Sprint 20 allows documentary relative placeholders only.

## Permissions and claims

Permissions must be evaluated through Portal Security contracts. Consumers must not create an independent login, identity store or permission model for the pilot.

## Audit

Consumer activity must use the Portal audit contract for append-only operational evidence.

## Configuration

Consumer configuration must use the Portal configuration contract for feature flags and controlled route metadata.

## Notifications

Consumer notifications must use the Portal notification contract. Real providers remain disabled.

## Health

Consumers must expose a health contract that can be checked during NonProduction validation.

## Deployment ownership

The consumer team owns its runtime. Portal owns Gateway, navigation contract and platform-level rollback coordination.
