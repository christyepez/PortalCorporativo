IF DB_ID(N'PortalMenu') IS NULL CREATE DATABASE PortalMenu;
GO
USE PortalMenu;
GO
IF SCHEMA_ID(N'menu') IS NULL EXEC(N'CREATE SCHEMA menu');
GO
CREATE TABLE menu.Menus(Id uniqueidentifier NOT NULL PRIMARY KEY,TenantId nvarchar(64) NOT NULL,ModuleCode nvarchar(100) NOT NULL,Name nvarchar(160) NOT NULL,IsActive bit NOT NULL);
CREATE UNIQUE INDEX UX_Menu_Module ON menu.Menus(TenantId,ModuleCode);
CREATE TABLE menu.Items(Id uniqueidentifier NOT NULL PRIMARY KEY,MenuId uniqueidentifier NOT NULL,ParentId uniqueidentifier NULL,Code nvarchar(100) NOT NULL,Label nvarchar(160) NOT NULL,Route nvarchar(300) NOT NULL,Icon nvarchar(max) NULL,[Order] int NOT NULL,IsActive bit NOT NULL,ResourceKey nvarchar(160) NOT NULL,PermissionCode nvarchar(180) NOT NULL,MetadataJson nvarchar(max) NULL,CONSTRAINT FK_MenuItem_Menu FOREIGN KEY(MenuId) REFERENCES menu.Menus(Id));
CREATE UNIQUE INDEX UX_MenuItem_Code ON menu.Items(MenuId,Code);
CREATE TABLE menu.Actions(Id uniqueidentifier NOT NULL PRIMARY KEY,MenuItemId uniqueidentifier NOT NULL,Code nvarchar(80) NOT NULL,Label nvarchar(120) NOT NULL,PermissionCode nvarchar(180) NOT NULL,[Order] int NOT NULL,IsActive bit NOT NULL,CONSTRAINT FK_MenuAction_Item FOREIGN KEY(MenuItemId) REFERENCES menu.Items(Id));
GO
