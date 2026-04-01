-- ============================================================
-- POC: MS SQL Server to Fabric Migration
-- Script 6: Execute the TRANSFORMED Layer Load
-- Run this after all tables and SPs are created
-- ============================================================

USE RetailDW;
GO

-- Execute the master orchestration procedure
EXEC TRANSFORMED.usp_LoadAllTransformed;
GO

-- ============================================================
-- Verification Queries
-- ============================================================

PRINT '';
PRINT '=== RAW Layer Row Counts ===';

SELECT 'RAW.Categories'  AS TableName, COUNT(*) AS RowCount FROM RAW.Categories
UNION ALL
SELECT 'RAW.Suppliers',    COUNT(*) FROM RAW.Suppliers
UNION ALL
SELECT 'RAW.Products',     COUNT(*) FROM RAW.Products
UNION ALL
SELECT 'RAW.Stores',       COUNT(*) FROM RAW.Stores
UNION ALL
SELECT 'RAW.Employees',    COUNT(*) FROM RAW.Employees
UNION ALL
SELECT 'RAW.Customers',    COUNT(*) FROM RAW.Customers
UNION ALL
SELECT 'RAW.Orders',       COUNT(*) FROM RAW.Orders
UNION ALL
SELECT 'RAW.OrderItems',   COUNT(*) FROM RAW.OrderItems
UNION ALL
SELECT 'RAW.Payments',     COUNT(*) FROM RAW.Payments
UNION ALL
SELECT 'RAW.Shipments',    COUNT(*) FROM RAW.Shipments
ORDER BY TableName;
GO

PRINT '';
PRINT '=== TRANSFORMED Layer Row Counts ===';

SELECT 'TRANSFORMED.DimDate'            AS TableName, COUNT(*) AS RowCount FROM TRANSFORMED.DimDate
UNION ALL
SELECT 'TRANSFORMED.DimCustomer',        COUNT(*) FROM TRANSFORMED.DimCustomer
UNION ALL
SELECT 'TRANSFORMED.DimProduct',         COUNT(*) FROM TRANSFORMED.DimProduct
UNION ALL
SELECT 'TRANSFORMED.DimStore',           COUNT(*) FROM TRANSFORMED.DimStore
UNION ALL
SELECT 'TRANSFORMED.DimEmployee',        COUNT(*) FROM TRANSFORMED.DimEmployee
UNION ALL
SELECT 'TRANSFORMED.DimPaymentMethod',   COUNT(*) FROM TRANSFORMED.DimPaymentMethod
UNION ALL
SELECT 'TRANSFORMED.FactSales',          COUNT(*) FROM TRANSFORMED.FactSales
UNION ALL
SELECT 'TRANSFORMED.FactDailyInventory', COUNT(*) FROM TRANSFORMED.FactDailyInventory
ORDER BY TableName;
GO

-- Quick data quality checks
PRINT '';
PRINT '=== FactSales Summary ===';
SELECT
    COUNT(*)                    AS TotalLineItems,
    COUNT(DISTINCT OrderID)     AS TotalOrders,
    SUM(LineTotal)              AS TotalRevenue,
    SUM(LineCost)               AS TotalCost,
    SUM(LineProfit)             AS TotalProfit,
    AVG(DiscountPercent)        AS AvgDiscount
FROM TRANSFORMED.FactSales;
GO

PRINT '=== Sales by Channel ===';
SELECT
    OrderChannel,
    COUNT(DISTINCT OrderID)     AS Orders,
    SUM(LineTotal)              AS Revenue
FROM TRANSFORMED.FactSales
GROUP BY OrderChannel
ORDER BY Revenue DESC;
GO

PRINT '=== Top 5 Products by Revenue ===';
SELECT TOP 5
    dp.ProductName,
    dp.CategoryName,
    SUM(fs.Quantity)    AS TotalUnitsSold,
    SUM(fs.LineTotal)   AS TotalRevenue,
    SUM(fs.LineProfit)  AS TotalProfit
FROM TRANSFORMED.FactSales fs
INNER JOIN TRANSFORMED.DimProduct dp ON fs.ProductKey = dp.ProductKey
GROUP BY dp.ProductName, dp.CategoryName
ORDER BY TotalRevenue DESC;
GO
