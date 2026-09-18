# Local centralization: controlled migration

Decision approved by the owner on 2026-09-18: trabajo becomes the principal local Docker Compose host. The currently active MarketingIndo Portal is the canonical source baseline; existing trabajo and legacy MarketingIndo databases must be preserved, not overwritten.

## Verified database preparation

17 source SQL backups were copied through authenticated encrypted SMB with matching SHA-256, restored under distinct staging names, and checked with DBCC CHECKDB. All 17 staging databases were ONLINE. Original databases and Docker volumes were retained. These are snapshots, NOT an ownership cutover or proof of reconciliation.

## Controlled Financial API preview

The Financial API on trabajo was restarting with exit code 139. MarketingIndo's Financial API was healthy. The migration preview uses an exact locally transferred source image against an isolated restored Financial database. It disables database initialization and migrations; it does not stop runtime writes from API endpoints. Do not connect users to the preview or use mutating smoke tests.

Required process variables: CENTRAL_FINANCIAL_IMAGE (verified imported image ID), CENTRAL_FINANCIAL_DATABASE (isolated restored database). Existing local secret variables are supplied by a protected, untracked environment file. Do not copy source SQL passwords over the active target SQL password.

Validate merged Compose configuration with --quiet before use. Apply docker-compose.centralization-preview.yml after the base and prod-local manifests, retain the existing Compose project name, and run only the preview service with --no-build --pull never --no-deps. Do not recreate SQL, Redis, MinIO or Seq. Preserve the previous image under a rollback tag before importing/replacing any existing tag.

## Remaining acceptance and ownership transfer

1. Verify preview readiness and application compatibility on trabajo.
2. Inventory and migrate all remaining persistent stores, local application configuration and project-specific file roots. PostgreSQL, MySQL, MinIO, queues, Redis and other application volumes are not covered by SQL backup acceptance.
3. Quiesce all source writers, take final backups, reconcile, and restore into new final target databases without overwriting preserved versions.
4. Switch Portal API connections together with a consistent identity/configuration baseline. Never run both source and target workers as competing owners.
5. Validate Gateway, frontend, protected routes and cross-domain integrations. Restrict host ports/firewall to required LAN clients.
6. Configure MarketingIndo as a client of trabajo only after target acceptance; preserve source rollback until explicitly retired.

## Rollback

Before ownership transfer, keep MarketingIndo active. Stop the target preview service if validation fails; source applications and original target databases remain untouched. Reapply the baseline Compose manifests to revert the preview override when appropriate. Never use docker compose down -v, delete source volumes, or claim production migration complete based on staging restoration alone.

## Transfer security

Use a temporary non-administrator account, a dedicated restricted-ACL incoming folder, per-share SMB encryption, and a TCP 445 rule scoped to the known source IPs. Transfer authentication secrets only in recipient-encrypted envelopes, never as plaintext tool output. Close the share, remove its temporary firewall rule and disable the temporary account after each transfer phase.
