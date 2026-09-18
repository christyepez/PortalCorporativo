# ADR: trabajo as principal local deployment host

Status: owner-approved migration direction; runtime cutover pending acceptance.
Date: 2026-09-18.

## Context

The owner requested centralizing all applications, persistent state and local configuration on trabajo. MarketingIndo will connect to services on trabajo. Both devices currently have independent Portal databases and deployments. The owner explicitly selected the currently active MarketingIndo Portal as the canonical source, while preserving all other versions.

## Decision

Deploy through local Docker Compose only. Migrate non-destructively through verified backup snapshots, isolated test restores, exact private local image transfers and controlled compatibility previews. Preserve databases, volumes, images and independent domain boundaries. Do not overwrite existing target databases or switch service ownership merely because a backup restored successfully.

## Alternatives

Keeping two independent writing deployments was rejected because it does not meet centralization and risks divergence. Replacing trabajo databases directly was rejected because existing target state must be retained. Cloud deployment is outside the owner's chosen runtime policy.

## Consequences

A final writer-quiescence, backup, reconciliation and coordinated connection/worker switch are required. MarketingIndo remains the active owner until acceptance. Distinct staging names are temporary test snapshots, not final application ownership. Capacity, port collisions, file roots, secrets, auxiliary data stores and LAN access must be validated per application. This ADR does not approve deleting preserved versions or weaken authorization/security requirements.
