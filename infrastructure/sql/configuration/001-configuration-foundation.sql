IF DB_ID(N'PortalConfiguration') IS NULL CREATE DATABASE PortalConfiguration;
GO
USE PortalConfiguration;
GO
IF SCHEMA_ID(N'configuration') IS NULL EXEC(N'CREATE SCHEMA configuration');
GO
CREATE TABLE configuration.Items (
 Id uniqueidentifier NOT NULL PRIMARY KEY, [Key] nvarchar(180) NOT NULL, Scope int NOT NULL,
 TenantId nvarchar(64) NOT NULL, ModuleCode nvarchar(100) NULL, UserId uniqueidentifier NULL,
 Category int NOT NULL, ValueJson nvarchar(max) NOT NULL, Version int NOT NULL, IsActive bit NOT NULL,
 CreatedAtUtc datetimeoffset NOT NULL, UpdatedAtUtc datetimeoffset NOT NULL
);
CREATE UNIQUE INDEX UX_Configuration_Scope ON configuration.Items(TenantId,[Key],Scope,ModuleCode,UserId);
GO
