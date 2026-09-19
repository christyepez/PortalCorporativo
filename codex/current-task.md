# Current Codex Task

Title: Docker Desktop PROD-local backup and recovery hardening.

Status: COMPLETE on `trabajo`. `MarketingIndo` remains a deferred synchronization target and never blocks implementation.

Objective: provide repeatable, local SQL Server backup, inventory, isolated restore validation and guarded live recovery for Portal-managed databases.

Evidence: 9/9 managed databases backed up with checksum and SHA-256 manifest; all 9 restored in an isolated disposable SQL Server and passed `DBCC CHECKDB`; live restore requires explicit `-Apply` and creates a safety backup by default; post-validation runtime returned `PROD_LOCAL_SMOKE_PASS` and `PORTAL_PROD_LOCAL_VERIFY_PASS` with zero restarts.

Guardrail: backup artifacts remain outside Git, unrelated/historical databases are excluded, real SRI production transmission remains disabled, and deployment stays local through Docker Desktop/Docker Compose.
