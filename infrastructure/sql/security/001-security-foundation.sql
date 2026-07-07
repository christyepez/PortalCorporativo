IF DB_ID(N'PortalSecurity') IS NULL
BEGIN
    CREATE DATABASE PortalSecurity;
END;
GO

USE PortalSecurity;
GO

IF SCHEMA_ID(N'security') IS NULL EXEC(N'CREATE SCHEMA security');
GO

CREATE TABLE security.Tenants (
    Id nvarchar(64) NOT NULL CONSTRAINT PK_Tenants PRIMARY KEY,
    Name nvarchar(160) NOT NULL
);

CREATE TABLE security.Users (
    Id uniqueidentifier NOT NULL CONSTRAINT PK_Users PRIMARY KEY,
    TenantId nvarchar(64) NOT NULL,
    Email nvarchar(320) NOT NULL,
    NormalizedEmail nvarchar(320) NOT NULL,
    Name nvarchar(160) NOT NULL,
    IsActive bit NOT NULL,
    CreatedAtUtc datetimeoffset NOT NULL,
    CONSTRAINT FK_Users_Tenants FOREIGN KEY (TenantId) REFERENCES security.Tenants(Id),
    CONSTRAINT UQ_Users_Tenant_Email UNIQUE (TenantId, NormalizedEmail)
);

CREATE TABLE security.Roles (
    Id uniqueidentifier NOT NULL CONSTRAINT PK_Roles PRIMARY KEY,
    TenantId nvarchar(64) NOT NULL,
    Name nvarchar(120) NOT NULL,
    NormalizedName nvarchar(120) NOT NULL,
    CONSTRAINT FK_Roles_Tenants FOREIGN KEY (TenantId) REFERENCES security.Tenants(Id),
    CONSTRAINT UQ_Roles_Tenant_Name UNIQUE (TenantId, NormalizedName)
);

CREATE TABLE security.Resources (
    Id uniqueidentifier NOT NULL CONSTRAINT PK_Resources PRIMARY KEY,
    TenantId nvarchar(64) NOT NULL,
    [Key] nvarchar(160) NOT NULL,
    Name nvarchar(160) NOT NULL,
    CONSTRAINT FK_Resources_Tenants FOREIGN KEY (TenantId) REFERENCES security.Tenants(Id),
    CONSTRAINT UQ_Resources_Tenant_Key UNIQUE (TenantId, [Key])
);

CREATE TABLE security.Permissions (
    Id uniqueidentifier NOT NULL CONSTRAINT PK_Permissions PRIMARY KEY,
    TenantId nvarchar(64) NOT NULL,
    Code nvarchar(180) NOT NULL,
    ResourceKey nvarchar(160) NOT NULL,
    Action nvarchar(80) NOT NULL,
    CONSTRAINT FK_Permissions_Tenants FOREIGN KEY (TenantId) REFERENCES security.Tenants(Id),
    CONSTRAINT UQ_Permissions_Tenant_Code UNIQUE (TenantId, Code),
    CONSTRAINT UQ_Permissions_Tenant_Resource_Action UNIQUE (TenantId, ResourceKey, Action)
);

CREATE TABLE security.UserRoles (
    TenantId nvarchar(64) NOT NULL,
    UserId uniqueidentifier NOT NULL,
    RoleId uniqueidentifier NOT NULL,
    CONSTRAINT PK_UserRoles PRIMARY KEY (TenantId, UserId, RoleId),
    CONSTRAINT FK_UserRoles_Users FOREIGN KEY (UserId) REFERENCES security.Users(Id) ON DELETE CASCADE,
    CONSTRAINT FK_UserRoles_Roles FOREIGN KEY (RoleId) REFERENCES security.Roles(Id) ON DELETE CASCADE
);

CREATE TABLE security.RolePermissions (
    TenantId nvarchar(64) NOT NULL,
    RoleId uniqueidentifier NOT NULL,
    PermissionId uniqueidentifier NOT NULL,
    CONSTRAINT PK_RolePermissions PRIMARY KEY (TenantId, RoleId, PermissionId),
    CONSTRAINT FK_RolePermissions_Roles FOREIGN KEY (RoleId) REFERENCES security.Roles(Id) ON DELETE CASCADE,
    CONSTRAINT FK_RolePermissions_Permissions FOREIGN KEY (PermissionId) REFERENCES security.Permissions(Id) ON DELETE CASCADE
);
GO

INSERT INTO security.Tenants (Id, Name) VALUES (N'default', N'Default Tenant');
INSERT INTO security.Roles (Id, TenantId, Name, NormalizedName) VALUES
('10000000-0000-0000-0000-000000000001', N'default', N'SuperAdmin', N'SUPERADMIN'),
('10000000-0000-0000-0000-000000000002', N'default', N'PortalAdmin', N'PORTALADMIN');

INSERT INTO security.Resources (Id, TenantId, [Key], Name) VALUES
('20000000-0000-0000-0000-000000000001', N'default', N'portal.security', N'Portal Security'),
('20000000-0000-0000-0000-000000000002', N'default', N'portal.menu', N'Portal Menu'),
('20000000-0000-0000-0000-000000000003', N'default', N'portal.configuration', N'Portal Configuration'),
('20000000-0000-0000-0000-000000000004', N'default', N'portal.audit', N'Portal Audit'),
('20000000-0000-0000-0000-000000000005', N'default', N'portal.notification', N'Portal Notification');

INSERT INTO security.Permissions (Id, TenantId, Code, ResourceKey, Action) VALUES
('30000000-0000-0000-0000-000000000001', N'default', N'portal.security.manage', N'portal.security', N'manage'),
('30000000-0000-0000-0000-000000000002', N'default', N'portal.menu.manage', N'portal.menu', N'manage'),
('30000000-0000-0000-0000-000000000003', N'default', N'portal.configuration.manage', N'portal.configuration', N'manage'),
('30000000-0000-0000-0000-000000000004', N'default', N'portal.audit.read', N'portal.audit', N'read'),
('30000000-0000-0000-0000-000000000005', N'default', N'portal.notification.manage', N'portal.notification', N'manage'),
('30000000-0000-0000-0000-000000000006', N'default', N'portal.notification.send', N'portal.notification', N'send'),
('30000000-0000-0000-0000-000000000007', N'default', N'portal.notification.read', N'portal.notification', N'read'),
('30000000-0000-0000-0000-000000000008', N'default', N'portal.configuration.read', N'portal.configuration', N'read'),
('30000000-0000-0000-0000-000000000009', N'default', N'portal.menu.read', N'portal.menu', N'read'),
('30000000-0000-0000-0000-000000000010', N'default', N'portal.audit.write', N'portal.audit', N'write');

INSERT INTO security.RolePermissions (TenantId, RoleId, PermissionId)
SELECT N'default', roleId, permissionId
FROM (VALUES
    (CAST('10000000-0000-0000-0000-000000000001' AS uniqueidentifier)),
    (CAST('10000000-0000-0000-0000-000000000002' AS uniqueidentifier))
) roles(roleId)
CROSS JOIN (VALUES
    (CAST('30000000-0000-0000-0000-000000000001' AS uniqueidentifier)),
    (CAST('30000000-0000-0000-0000-000000000002' AS uniqueidentifier)),
    (CAST('30000000-0000-0000-0000-000000000003' AS uniqueidentifier)),
    (CAST('30000000-0000-0000-0000-000000000004' AS uniqueidentifier)),
    (CAST('30000000-0000-0000-0000-000000000005' AS uniqueidentifier)),
    (CAST('30000000-0000-0000-0000-000000000006' AS uniqueidentifier)),
    (CAST('30000000-0000-0000-0000-000000000007' AS uniqueidentifier)),
    (CAST('30000000-0000-0000-0000-000000000008' AS uniqueidentifier)),
    (CAST('30000000-0000-0000-0000-000000000009' AS uniqueidentifier)),
    (CAST('30000000-0000-0000-0000-000000000010' AS uniqueidentifier))
) permissions(permissionId);
GO
