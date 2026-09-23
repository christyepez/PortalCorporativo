# 04 - Integration Reliability

Owns Outbox/Inbox idempotency, processing lease, retry/dead-letter, tenant ownership and local Log worker.
Acceptance: duplicate enqueue same messageId, single publish, expired lease recovery, cross-tenant reads denied, no external broker.
