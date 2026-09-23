# 01 - Core Security & Multi-tenancy

Owns JWT tenant resolution, Security, Configuration, Menu, Audit, Notification and tenant boundaries.
Acceptance: tenant A cannot read/update tenant B; body/query TenantId cannot override authenticated context; JWT/header mismatch rejected; default remains backward compatible.
