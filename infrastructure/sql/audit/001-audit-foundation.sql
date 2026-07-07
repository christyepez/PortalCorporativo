IF DB_ID(N'PortalAudit') IS NULL CREATE DATABASE PortalAudit;
GO
USE PortalAudit;
GO
IF SCHEMA_ID(N'audit') IS NULL EXEC(N'CREATE SCHEMA audit');
GO
CREATE TABLE audit.AuditLogs (
    Id uniqueidentifier NOT NULL CONSTRAINT PK_AuditLogs PRIMARY KEY,
    ActorId nvarchar(160) NOT NULL, TenantId nvarchar(64) NOT NULL,
    Resource nvarchar(160) NOT NULL, Action nvarchar(80) NOT NULL,
    EntityName nvarchar(160) NOT NULL, EntityId nvarchar(160) NULL,
    BeforeJson nvarchar(max) NULL, AfterJson nvarchar(max) NULL, MetadataJson nvarchar(max) NULL,
    CorrelationId nvarchar(128) NOT NULL, CausationId nvarchar(128) NULL, RequestId nvarchar(128) NULL,
    IpAddress nvarchar(64) NULL, UserAgent nvarchar(512) NULL,
    Severity int NOT NULL, CreatedAtUtc datetimeoffset NOT NULL
);
CREATE INDEX IX_AuditLogs_Tenant_Created ON audit.AuditLogs(TenantId, CreatedAtUtc);
CREATE INDEX IX_AuditLogs_Tenant_Resource_Action ON audit.AuditLogs(TenantId, Resource, Action);
CREATE INDEX IX_AuditLogs_Correlation ON audit.AuditLogs(CorrelationId);
GO
