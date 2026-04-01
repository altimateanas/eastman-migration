-- ============================================================
-- POC: MS SQL Server to Fabric Migration
-- Script 4: Create TRANSFORMED Schema Tables (Dims & Facts)
-- ============================================================

USE RetailDW;
GO

-- ============================================================
-- DIMENSION TABLES
-- ============================================================

-- DimDate - Date dimension for time-based analysis
CREATE TABLE TRANSFORMED.DimDate (
    DateKey         INT PRIMARY KEY,          -- YYYYMMDD format
    FullDate        DATE NOT NULL,
    DayOfWeek       TINYINT NOT NULL,
    DayName         NVARCHAR(10) NOT NULL,
    DayOfMonth      TINYINT NOT NULL,
    DayOfYear       SMALLINT NOT NULL,
    WeekOfYear      TINYINT NOT NULL,
    MonthNumber     TINYINT NOT NULL,
    MonthName       NVARCHAR(10) NOT NULL,
    Quarter         TINYINT NOT NULL,
    QuarterName     NVARCHAR(2) NOT NULL,
    Year            SMALLINT NOT NULL,
    IsWeekend       BIT NOT NULL,
    FiscalMonth     TINYINT NOT NULL,
    FiscalQuarter   TINYINT NOT NULL,
    FiscalYear      SMALLINT NOT NULL
);
GO

-- DimCustomer - Customer dimension (SCD Type 1)
CREATE TABLE TRANSFORMED.DimCustomer (
    CustomerKey     INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID      INT NOT NULL,
    FullName        NVARCHAR(201) NOT NULL,
    Email           NVARCHAR(200),
    Phone           NVARCHAR(30),
    DateOfBirth     DATE,
    Gender          NVARCHAR(10),
    City            NVARCHAR(100),
    State           NVARCHAR(100),
    Country         NVARCHAR(100),
    PostalCode      NVARCHAR(20),
    CustomerSegment NVARCHAR(50),
    AgeGroup        NVARCHAR(20),
    RegistrationDate DATE,
    IsActive        BIT,
    LoadDate        DATETIME2 DEFAULT GETDATE(),
    UpdateDate      DATETIME2 DEFAULT GETDATE()
);
GO

-- DimProduct - Product dimension
CREATE TABLE TRANSFORMED.DimProduct (
    ProductKey      INT IDENTITY(1,1) PRIMARY KEY,
    ProductID       INT NOT NULL,
    ProductName     NVARCHAR(200) NOT NULL,
    SKU             NVARCHAR(50),
    CategoryName    NVARCHAR(100),
    SupplierName    NVARCHAR(200),
    UnitPrice       DECIMAL(18,2),
    CostPrice       DECIMAL(18,2),
    ProfitMargin    DECIMAL(5,2),
    IsDiscontinued  BIT,
    LoadDate        DATETIME2 DEFAULT GETDATE(),
    UpdateDate      DATETIME2 DEFAULT GETDATE()
);
GO

-- DimStore - Store dimension
CREATE TABLE TRANSFORMED.DimStore (
    StoreKey        INT IDENTITY(1,1) PRIMARY KEY,
    StoreID         INT NOT NULL,
    StoreName       NVARCHAR(200) NOT NULL,
    StoreType       NVARCHAR(50),
    City            NVARCHAR(100),
    State           NVARCHAR(100),
    Country         NVARCHAR(100),
    PostalCode      NVARCHAR(20),
    ManagerName     NVARCHAR(150),
    OpenDate        DATE,
    IsActive        BIT,
    LoadDate        DATETIME2 DEFAULT GETDATE(),
    UpdateDate      DATETIME2 DEFAULT GETDATE()
);
GO

-- DimEmployee - Employee dimension
CREATE TABLE TRANSFORMED.DimEmployee (
    EmployeeKey     INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID      INT NOT NULL,
    FullName        NVARCHAR(201) NOT NULL,
    Email           NVARCHAR(200),
    JobTitle        NVARCHAR(100),
    Department      NVARCHAR(100),
    StoreName       NVARCHAR(200),
    HireDate        DATE,
    YearsOfService  INT,
    IsActive        BIT,
    LoadDate        DATETIME2 DEFAULT GETDATE(),
    UpdateDate      DATETIME2 DEFAULT GETDATE()
);
GO

-- DimPaymentMethod - Payment method dimension (junk dimension)
CREATE TABLE TRANSFORMED.DimPaymentMethod (
    PaymentMethodKey INT IDENTITY(1,1) PRIMARY KEY,
    PaymentMethod    NVARCHAR(50) NOT NULL,
    PaymentCategory  NVARCHAR(30) NOT NULL,    -- 'Digital', 'Physical', 'Transfer'
    LoadDate         DATETIME2 DEFAULT GETDATE()
);
GO

-- ============================================================
-- FACT TABLES
-- ============================================================

-- FactSales - Grain: one row per order line item
CREATE TABLE TRANSFORMED.FactSales (
    SalesKey            INT IDENTITY(1,1) PRIMARY KEY,
    OrderID             INT NOT NULL,
    OrderItemID         INT NOT NULL,
    OrderDateKey        INT NOT NULL,
    CustomerKey         INT NOT NULL,
    ProductKey          INT NOT NULL,
    StoreKey            INT NOT NULL,
    EmployeeKey         INT NOT NULL,
    PaymentMethodKey    INT,
    OrderChannel        NVARCHAR(30),
    OrderStatus         NVARCHAR(30),
    Quantity            INT NOT NULL,
    UnitPrice           DECIMAL(18,2) NOT NULL,
    CostPrice           DECIMAL(18,2) NOT NULL,
    DiscountPercent     DECIMAL(5,2),
    LineTotal           DECIMAL(18,2) NOT NULL,
    LineCost            DECIMAL(18,2) NOT NULL,
    LineProfit          DECIMAL(18,2) NOT NULL,
    ShippingCost        DECIMAL(18,2),
    PaymentAmount       DECIMAL(18,2),
    LoadDate            DATETIME2 DEFAULT GETDATE()
);
GO

-- FactDailyInventory - Snapshot fact for inventory levels
CREATE TABLE TRANSFORMED.FactDailyInventory (
    InventoryKey        INT IDENTITY(1,1) PRIMARY KEY,
    SnapshotDateKey     INT NOT NULL,
    ProductKey          INT NOT NULL,
    UnitsInStock        INT NOT NULL,
    ReorderLevel        INT NOT NULL,
    StockStatus         NVARCHAR(20) NOT NULL,   -- 'In Stock', 'Low Stock', 'Out of Stock'
    StockValue          DECIMAL(18,2) NOT NULL,
    LoadDate            DATETIME2 DEFAULT GETDATE()
);
GO

PRINT 'All TRANSFORMED schema tables created successfully.';
GO
