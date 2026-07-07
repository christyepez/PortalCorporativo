IF DB_ID('PortalNotification') IS NULL CREATE DATABASE PortalNotification;
GO
USE PortalNotification;
GO
IF SCHEMA_ID('notification') IS NULL EXEC('CREATE SCHEMA notification');
GO
-- Runtime uses EF EnsureCreated for Sprint 1. This script establishes the isolated database/schema;
-- subsequent production migrations must own table evolution for Template, Message, Recipient and DeliveryAttempt.
