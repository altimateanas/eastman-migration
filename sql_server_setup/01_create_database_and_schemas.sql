-- ============================================================
-- POC: MS SQL Server to Fabric Migration
-- Script 1: Create Database and Schemas
-- ============================================================

USE master;
GO

-- Drop database if it exists (for repeatable setup)
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'RetailDW')
BEGIN
    ALTER DATABASE RetailDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RetailDW;
END
GO

-- Create the database
CREATE DATABASE RetailDW;
GO

USE RetailDW;
GO

-- Create schemas
CREATE SCHEMA RAW;
GO

CREATE SCHEMA TRANSFORMED;
GO

PRINT 'Database and schemas created successfully.';
GO
