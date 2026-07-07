IF DB_ID(N'PortalIntegration') IS NULL CREATE DATABASE PortalIntegration;
GO
USE PortalIntegration;
GO
IF SCHEMA_ID(N'integration') IS NULL EXEC(N'CREATE SCHEMA integration');
GO
CREATE TABLE integration.OutboxMessages (
    MessageId uniqueidentifier NOT NULL CONSTRAINT PK_OutboxMessages PRIMARY KEY,
    TenantId nvarchar(64) NOT NULL, AggregateType nvarchar(160) NOT NULL, AggregateId nvarchar(160) NOT NULL,
    EventType nvarchar(200) NOT NULL, PayloadJson nvarchar(max) NOT NULL, HeadersJson nvarchar(max) NULL,
    CorrelationId nvarchar(128) NOT NULL, CausationId nvarchar(128) NULL, IdempotencyKey nvarchar(200) NULL,
    Status int NOT NULL, Attempts int NOT NULL, NextRetryAtUtc datetimeoffset NULL,
    CreatedAtUtc datetimeoffset NOT NULL, ProcessedAtUtc datetimeoffset NULL, LastError nvarchar(2000) NULL
);
CREATE UNIQUE INDEX UX_Outbox_Tenant_Idempotency ON integration.OutboxMessages(TenantId, IdempotencyKey) WHERE IdempotencyKey IS NOT NULL;
CREATE INDEX IX_Outbox_Status_Retry ON integration.OutboxMessages(Status, NextRetryAtUtc, CreatedAtUtc);

CREATE TABLE integration.InboxMessages (
    MessageId uniqueidentifier NOT NULL CONSTRAINT PK_InboxMessages PRIMARY KEY,
    TenantId nvarchar(64) NOT NULL, Source nvarchar(160) NOT NULL, EventType nvarchar(200) NOT NULL,
    PayloadJson nvarchar(max) NOT NULL, HeadersJson nvarchar(max) NULL, CorrelationId nvarchar(128) NOT NULL,
    IdempotencyKey nvarchar(200) NOT NULL, Status int NOT NULL, ReceivedAtUtc datetimeoffset NOT NULL,
    ProcessedAtUtc datetimeoffset NULL, LastError nvarchar(2000) NULL
);
CREATE UNIQUE INDEX UX_Inbox_Tenant_Source_Idempotency ON integration.InboxMessages(TenantId, Source, IdempotencyKey);
GO
