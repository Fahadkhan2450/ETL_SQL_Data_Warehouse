

/*
=============================================================
 Project: Data Warehouse Setup
 Description:
 This script creates the Data Warehouse database and
 the Bronze, Silver, and Gold schemas following the
 Medallion Architecture.

 Author: Fahad Khan
=============================================================
*/

-- ==========================================================
-- Create Data Warehouse Database
-- ==========================================================

CREATE DATABASE Datawarehouse;
GO

USE Datawarehouse;
GO

-- ==========================================================
-- Create Bronze Schema
-- Stores raw data directly from source systems.
-- ==========================================================

CREATE SCHEMA bronze;
GO

-- ==========================================================
-- Create Silver Schema
-- Stores cleaned and transformed data.
-- ==========================================================

CREATE SCHEMA silver;
GO

-- ==========================================================
-- Create Gold Schema
-- Stores business-ready, aggregated, and analytical data.
-- ==========================================================

CREATE SCHEMA gold;
GO
