-- ============================================================
-- POC: MS SQL Server to Fabric Migration
-- Script 5: Stored Procedures to Load TRANSFORMED Layer
-- ============================================================

USE RetailDW;
GO

-- ============================================================
-- SP 1: Load DimDate
-- Generates a date dimension covering 2022-01-01 to 2026-12-31
-- Fiscal year starts in July (common for retail)
-- ============================================================
CREATE OR ALTER PROCEDURE TRANSFORMED.usp_LoadDimDate
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE TRANSFORMED.DimDate;

    DECLARE @StartDate DATE = '2022-01-01';
    DECLARE @EndDate   DATE = '2026-12-31';
    DECLARE @Date      DATE = @StartDate;

    WHILE @Date <= @EndDate
    BEGIN
        INSERT INTO TRANSFORMED.DimDate (
            DateKey, FullDate, DayOfWeek, DayName, DayOfMonth, DayOfYear,
            WeekOfYear, MonthNumber, MonthName, Quarter, QuarterName,
            Year, IsWeekend, FiscalMonth, FiscalQuarter, FiscalYear
        )
        SELECT
            CONVERT(INT, FORMAT(@Date, 'yyyyMMdd'))     AS DateKey,
            @Date                                        AS FullDate,
            DATEPART(WEEKDAY, @Date)                     AS DayOfWeek,
            DATENAME(WEEKDAY, @Date)                     AS DayName,
            DAY(@Date)                                   AS DayOfMonth,
            DATEPART(DAYOFYEAR, @Date)                   AS DayOfYear,
            DATEPART(WEEK, @Date)                        AS WeekOfYear,
            MONTH(@Date)                                 AS MonthNumber,
            DATENAME(MONTH, @Date)                       AS MonthName,
            DATEPART(QUARTER, @Date)                     AS Quarter,
            'Q' + CAST(DATEPART(QUARTER, @Date) AS CHAR) AS QuarterName,
            YEAR(@Date)                                  AS Year,
            CASE WHEN DATEPART(WEEKDAY, @Date) IN (1, 7) THEN 1 ELSE 0 END AS IsWeekend,
            -- Fiscal year starts July: Jul=1, Aug=2, ..., Jun=12
            CASE
                WHEN MONTH(@Date) >= 7 THEN MONTH(@Date) - 6
                ELSE MONTH(@Date) + 6
            END                                          AS FiscalMonth,
            CASE
                WHEN MONTH(@Date) >= 7 THEN (MONTH(@Date) - 7) / 3 + 1
                ELSE (MONTH(@Date) + 5) / 3
            END                                          AS FiscalQuarter,
            CASE
                WHEN MONTH(@Date) >= 7 THEN YEAR(@Date) + 1
                ELSE YEAR(@Date)
            END                                          AS FiscalYear;

        SET @Date = DATEADD(DAY, 1, @Date);
    END

    PRINT 'DimDate loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END;
GO

-- ============================================================
-- SP 2: Load DimCustomer
-- Transforms customer data with derived age group
-- ============================================================
CREATE OR ALTER PROCEDURE TRANSFORMED.usp_LoadDimCustomer
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE TRANSFORMED.DimCustomer;

    INSERT INTO TRANSFORMED.DimCustomer (
        CustomerID, FullName, Email, Phone, DateOfBirth, Gender,
        City, State, Country, PostalCode, CustomerSegment,
        AgeGroup, RegistrationDate, IsActive
    )
    SELECT
        c.CustomerID,
        CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
        c.Email,
        c.Phone,
        c.DateOfBirth,
        c.Gender,
        c.City,
        c.State,
        c.Country,
        c.PostalCode,
        c.CustomerSegment,
        CASE
            WHEN DATEDIFF(YEAR, c.DateOfBirth, GETDATE()) < 25 THEN '18-24'
            WHEN DATEDIFF(YEAR, c.DateOfBirth, GETDATE()) < 35 THEN '25-34'
            WHEN DATEDIFF(YEAR, c.DateOfBirth, GETDATE()) < 45 THEN '35-44'
            WHEN DATEDIFF(YEAR, c.DateOfBirth, GETDATE()) < 55 THEN '45-54'
            ELSE '55+'
        END AS AgeGroup,
        c.RegistrationDate,
        c.IsActive
    FROM RAW.Customers c;

    PRINT 'DimCustomer loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END;
GO

-- ============================================================
-- SP 3: Load DimProduct
-- Joins Products with Categories and Suppliers, calculates profit margin
-- ============================================================
CREATE OR ALTER PROCEDURE TRANSFORMED.usp_LoadDimProduct
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE TRANSFORMED.DimProduct;

    INSERT INTO TRANSFORMED.DimProduct (
        ProductID, ProductName, SKU, CategoryName, SupplierName,
        UnitPrice, CostPrice, ProfitMargin, IsDiscontinued
    )
    SELECT
        p.ProductID,
        p.ProductName,
        p.SKU,
        c.CategoryName,
        s.SupplierName,
        p.UnitPrice,
        p.CostPrice,
        CASE
            WHEN p.UnitPrice > 0
            THEN ROUND(((p.UnitPrice - p.CostPrice) / p.UnitPrice) * 100, 2)
            ELSE 0
        END AS ProfitMargin,
        p.IsDiscontinued
    FROM RAW.Products p
    INNER JOIN RAW.Categories c ON p.CategoryID = c.CategoryID
    INNER JOIN RAW.Suppliers s  ON p.SupplierID = s.SupplierID;

    PRINT 'DimProduct loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END;
GO

-- ============================================================
-- SP 4: Load DimStore
-- ============================================================
CREATE OR ALTER PROCEDURE TRANSFORMED.usp_LoadDimStore
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE TRANSFORMED.DimStore;

    INSERT INTO TRANSFORMED.DimStore (
        StoreID, StoreName, StoreType, City, State, Country,
        PostalCode, ManagerName, OpenDate, IsActive
    )
    SELECT
        st.StoreID,
        st.StoreName,
        st.StoreType,
        st.City,
        st.State,
        st.Country,
        st.PostalCode,
        st.ManagerName,
        st.OpenDate,
        st.IsActive
    FROM RAW.Stores st;

    PRINT 'DimStore loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END;
GO

-- ============================================================
-- SP 5: Load DimEmployee
-- Joins with Stores, calculates years of service
-- ============================================================
CREATE OR ALTER PROCEDURE TRANSFORMED.usp_LoadDimEmployee
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE TRANSFORMED.DimEmployee;

    INSERT INTO TRANSFORMED.DimEmployee (
        EmployeeID, FullName, Email, JobTitle, Department,
        StoreName, HireDate, YearsOfService, IsActive
    )
    SELECT
        e.EmployeeID,
        CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
        e.Email,
        e.JobTitle,
        e.Department,
        s.StoreName,
        e.HireDate,
        DATEDIFF(YEAR, e.HireDate, GETDATE()) AS YearsOfService,
        e.IsActive
    FROM RAW.Employees e
    INNER JOIN RAW.Stores s ON e.StoreID = s.StoreID;

    PRINT 'DimEmployee loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END;
GO

-- ============================================================
-- SP 6: Load DimPaymentMethod
-- Derives payment category from raw payment data
-- ============================================================
CREATE OR ALTER PROCEDURE TRANSFORMED.usp_LoadDimPaymentMethod
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE TRANSFORMED.DimPaymentMethod;

    INSERT INTO TRANSFORMED.DimPaymentMethod (PaymentMethod, PaymentCategory)
    SELECT DISTINCT
        p.PaymentMethod,
        CASE
            WHEN p.PaymentMethod IN ('CreditCard', 'DebitCard')  THEN 'Card'
            WHEN p.PaymentMethod = 'Cash'                        THEN 'Physical'
            WHEN p.PaymentMethod = 'DigitalWallet'               THEN 'Digital'
            WHEN p.PaymentMethod = 'BankTransfer'                THEN 'Transfer'
            ELSE 'Other'
        END AS PaymentCategory
    FROM RAW.Payments p
    WHERE p.PaymentMethod IS NOT NULL;

    PRINT 'DimPaymentMethod loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END;
GO

-- ============================================================
-- SP 7: Load FactSales
-- Grain: one row per order line item
-- Joins orders, items, products, payments, shipments
-- Calculates cost, profit, and integrates shipping
-- ============================================================
CREATE OR ALTER PROCEDURE TRANSFORMED.usp_LoadFactSales
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE TRANSFORMED.FactSales;

    INSERT INTO TRANSFORMED.FactSales (
        OrderID, OrderItemID, OrderDateKey, CustomerKey, ProductKey,
        StoreKey, EmployeeKey, PaymentMethodKey, OrderChannel, OrderStatus,
        Quantity, UnitPrice, CostPrice, DiscountPercent,
        LineTotal, LineCost, LineProfit, ShippingCost, PaymentAmount
    )
    SELECT
        o.OrderID,
        oi.OrderItemID,
        CONVERT(INT, FORMAT(o.OrderDate, 'yyyyMMdd'))   AS OrderDateKey,
        dc.CustomerKey,
        dp.ProductKey,
        ds.StoreKey,
        de.EmployeeKey,
        dpm.PaymentMethodKey,
        o.OrderChannel,
        o.OrderStatus,
        oi.Quantity,
        oi.UnitPrice,
        p.CostPrice,
        oi.Discount                                      AS DiscountPercent,
        oi.LineTotal,
        oi.Quantity * p.CostPrice                        AS LineCost,
        oi.LineTotal - (oi.Quantity * p.CostPrice)       AS LineProfit,
        -- Distribute shipping cost proportionally across line items
        CASE
            WHEN order_totals.OrderLineTotal > 0
            THEN ROUND(ISNULL(sh.ShippingCost, 0) * (oi.LineTotal / order_totals.OrderLineTotal), 2)
            ELSE 0
        END                                              AS ShippingCost,
        -- Distribute payment amount proportionally across line items
        CASE
            WHEN order_totals.OrderLineTotal > 0
            THEN ROUND(ISNULL(pay.Amount, 0) * (oi.LineTotal / order_totals.OrderLineTotal), 2)
            ELSE 0
        END                                              AS PaymentAmount
    FROM RAW.Orders o
    INNER JOIN RAW.OrderItems oi           ON o.OrderID = oi.OrderID
    INNER JOIN RAW.Products p              ON oi.ProductID = p.ProductID
    INNER JOIN TRANSFORMED.DimCustomer dc  ON o.CustomerID = dc.CustomerID
    INNER JOIN TRANSFORMED.DimProduct dp   ON oi.ProductID = dp.ProductID
    INNER JOIN TRANSFORMED.DimStore ds     ON o.StoreID = ds.StoreID
    INNER JOIN TRANSFORMED.DimEmployee de  ON o.EmployeeID = de.EmployeeID
    -- Payment (take the first completed/pending payment per order)
    LEFT JOIN (
        SELECT OrderID, PaymentMethod, Amount,
               ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY PaymentDate) AS rn
        FROM RAW.Payments
    ) pay ON o.OrderID = pay.OrderID AND pay.rn = 1
    LEFT JOIN TRANSFORMED.DimPaymentMethod dpm ON pay.PaymentMethod = dpm.PaymentMethod
    -- Shipment (take the first shipment per order)
    LEFT JOIN (
        SELECT OrderID, ShippingCost,
               ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY ShipDate) AS rn
        FROM RAW.Shipments
    ) sh ON o.OrderID = sh.OrderID AND sh.rn = 1
    -- Order totals for proportional distribution
    CROSS APPLY (
        SELECT SUM(oi2.LineTotal) AS OrderLineTotal
        FROM RAW.OrderItems oi2
        WHERE oi2.OrderID = o.OrderID
    ) order_totals;

    PRINT 'FactSales loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END;
GO

-- ============================================================
-- SP 8: Load FactDailyInventory
-- Snapshot of current inventory levels with stock status
-- ============================================================
CREATE OR ALTER PROCEDURE TRANSFORMED.usp_LoadFactDailyInventory
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert a snapshot for today (append, not truncate)
    DECLARE @TodayKey INT = CONVERT(INT, FORMAT(GETDATE(), 'yyyyMMdd'));

    -- Remove today's snapshot if it already exists (idempotent)
    DELETE FROM TRANSFORMED.FactDailyInventory
    WHERE SnapshotDateKey = @TodayKey;

    INSERT INTO TRANSFORMED.FactDailyInventory (
        SnapshotDateKey, ProductKey, UnitsInStock, ReorderLevel,
        StockStatus, StockValue
    )
    SELECT
        @TodayKey                                       AS SnapshotDateKey,
        dp.ProductKey,
        p.UnitsInStock,
        p.ReorderLevel,
        CASE
            WHEN p.UnitsInStock = 0               THEN 'Out of Stock'
            WHEN p.UnitsInStock <= p.ReorderLevel  THEN 'Low Stock'
            ELSE 'In Stock'
        END                                             AS StockStatus,
        p.UnitsInStock * p.CostPrice                    AS StockValue
    FROM RAW.Products p
    INNER JOIN TRANSFORMED.DimProduct dp ON p.ProductID = dp.ProductID
    WHERE p.IsDiscontinued = 0;

    PRINT 'FactDailyInventory snapshot loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END;
GO

-- ============================================================
-- MASTER ORCHESTRATION SP
-- Executes all dimension loads first, then fact loads
-- ============================================================
CREATE OR ALTER PROCEDURE TRANSFORMED.usp_LoadAllTransformed
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME2 = GETDATE();
    PRINT '========================================';
    PRINT 'Starting TRANSFORMED layer load at ' + CONVERT(VARCHAR, @StartTime, 120);
    PRINT '========================================';

    -- Load dimensions first (order matters for referential integrity)
    PRINT '';
    PRINT '--- Loading Dimensions ---';
    EXEC TRANSFORMED.usp_LoadDimDate;
    EXEC TRANSFORMED.usp_LoadDimCustomer;
    EXEC TRANSFORMED.usp_LoadDimProduct;
    EXEC TRANSFORMED.usp_LoadDimStore;
    EXEC TRANSFORMED.usp_LoadDimEmployee;
    EXEC TRANSFORMED.usp_LoadDimPaymentMethod;

    -- Load facts (depend on dimensions)
    PRINT '';
    PRINT '--- Loading Facts ---';
    EXEC TRANSFORMED.usp_LoadFactSales;
    EXEC TRANSFORMED.usp_LoadFactDailyInventory;

    DECLARE @EndTime DATETIME2 = GETDATE();
    PRINT '';
    PRINT '========================================';
    PRINT 'TRANSFORMED layer load completed at ' + CONVERT(VARCHAR, @EndTime, 120);
    PRINT 'Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds';
    PRINT '========================================';
END;
GO

PRINT 'All stored procedures created successfully.';
GO
