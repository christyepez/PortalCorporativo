# Current Codex Task

Title: Docker Desktop PROD-local maintenance automation.

Status: COMPLETE on `trabajo`. `MarketingIndo` remains deferred and never blocks implementation.

Objective: provide one-command operational checks for backup freshness/integrity, retention, disk capacity and Portal runtime health, plus optional daily backup scheduling without embedding secrets.

Evidence: `prod-local-maintenance.ps1 -ScanLogs` returned `PORTAL_PROD_LOCAL_MAINTENANCE_PASS`, including SHA-256 verification, free-space guardrail, zero restarts, authenticated smoke and log scan. Scheduled-task installation was validated safely with `-WhatIf`.

Guardrail: scheduled task registration is optional, backup/environment secrets are never committed or embedded, real SRI production transmission remains disabled, and execution stays local on Docker Desktop.
