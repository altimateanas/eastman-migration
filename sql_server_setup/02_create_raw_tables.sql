-- ============================================================
-- POC: MS SQL Server to Fabric Migration
-- Script 2: Create RAW Schema Tables (10 tables)
-- Domain: Retail / E-Commerce
-- ============================================================

USE RetailDW;
GO

-- ============================================================
-- 1. RAW.Categories
-- ============================================================
CREATE TABLE RAW.Categories (
    CategoryID      INT PRIMARY KEY,
    CategoryName    NVARCHAR(100) NOT NULL,
    Description     NVARCHAR(500),
    IsActive        BIT DEFAULT 1,
    CreatedDate     DATETIME2 DEFAULT GETDATE(),
    ModifiedDate    DATETIME2 DEFAULT GETDATE()
);
GO

-- ============================================================
-- 2. RAW.Suppliers
-- ============================================================
CREATE TABLE RAW.Suppliers (
    SupplierID      INT PRIMARY KEY,
    SupplierName    NVARCHAR(200) NOT NULL,
    ContactName     NVARCHAR(150),
    ContactEmail    NVARCHAR(200),
    Phone           NVARCHAR(30),
    Address         NVARCHAR(300),
    City            NVARCHAR(100),
    State           NVARCHAR(100),
    Country         NVARCHAR(100),
    PostalCode      NVARCHAR(20),
    IsActive        BIT DEFAULT 1,
    CreatedDate     DATETIME2 DEFAULT GETDATE(),
    ModifiedDate    DATETIME2 DEFAULT GETDATE()
);
GO

-- ============================================================
-- 3. RAW.Products
-- ============================================================
CREATE TABLE RAW.Products (
    ProductID       INT PRIMARY KEY,
    ProductName     NVARCHAR(200) NOT NULL,
    CategoryID      INT NOT NULL,
    SupplierID      INT NOT NULL,
    SKU             NVARCHAR(50),
    UnitPrice       DECIMAL(18,2) NOT NULL,
    CostPrice       DECIMAL(18,2) NOT NULL,
    UnitsInStock    INT DEFAULT 0,
    ReorderLevel    INT DEFAULT 0,
    IsDiscontinued  BIT DEFAULT 0,
    CreatedDate     DATETIME2 DEFAULT GETDATE(),
    ModifiedDate    DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (CategoryID) REFERENCES RAW.Categories(CategoryID),
    FOREIGN KEY (SupplierID) REFERENCES RAW.Suppliers(SupplierID)
);
GO

-- ============================================================
-- 4. RAW.Stores
-- ============================================================
CREATE TABLE RAW.Stores (
    StoreID         INT PRIMARY KEY,
    StoreName       NVARCHAR(200) NOT NULL,
    StoreType       NVARCHAR(50),         -- 'Retail', 'Online', 'Warehouse'
    Address         NVARCHAR(300),
    City            NVARCHAR(100),
    State           NVARCHAR(100),
    Country         NVARCHAR(100),
    PostalCode      NVARCHAR(20),
    Phone           NVARCHAR(30),
    ManagerName     NVARCHAR(150),
    OpenDate        DATE,
    IsActive        BIT DEFAULT 1,
    CreatedDate     DATETIME2 DEFAULT GETDATE(),
    ModifiedDate    DATETIME2 DEFAULT GETDATE()
);
GO

-- ============================================================
-- 5. RAW.Employees
-- ============================================================
CREATE TABLE RAW.Employees (
    EmployeeID      INT PRIMARY KEY,
    FirstName       NVARCHAR(100) NOT NULL,
    LastName        NVARCHAR(100) NOT NULL,
    Email           NVARCHAR(200),
    Phone           NVARCHAR(30),
    HireDate        DATE NOT NULL,
    JobTitle        NVARCHAR(100),
    Department      NVARCHAR(100),
    StoreID         INT,
    ManagerID       INT,
    Salary          DECIMAL(18,2),
    IsActive        BIT DEFAULT 1,
    CreatedDate     DATETIME2 DEFAULT GETDATE(),
    ModifiedDate    DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (StoreID) REFERENCES RAW.Stores(StoreID),
    FOREIGN KEY (ManagerID) REFERENCES RAW.Employees(EmployeeID)
);
GO

-- ============================================================
-- 6. RAW.Customers
-- ============================================================
CREATE TABLE RAW.Customers (
    CustomerID      INT PRIMARY KEY,
    FirstName       NVARCHAR(100) NOT NULL,
    LastName        NVARCHAR(100) NOT NULL,
    Email           NVARCHAR(200),
    Phone           NVARCHAR(30),
    DateOfBirth     DATE,
    Gender          NVARCHAR(10),
    Address         NVARCHAR(300),
    City            NVARCHAR(100),
    State           NVARCHAR(100),
    Country         NVARCHAR(100),
    PostalCode      NVARCHAR(20),
    CustomerSegment NVARCHAR(50),         -- 'Regular', 'Premium', 'VIP'
    RegistrationDate DATE,
    IsActive        BIT DEFAULT 1,
    CreatedDate     DATETIME2 DEFAULT GETDATE(),
    ModifiedDate    DATETIME2 DEFAULT GETDATE()
);
GO

-- ============================================================
-- 7. RAW.Orders
-- ============================================================
CREATE TABLE RAW.Orders (
    OrderID         INT PRIMARY KEY,
    CustomerID      INT NOT NULL,
    StoreID         INT NOT NULL,
    EmployeeID      INT,
    OrderDate       DATETIME2 NOT NULL,
    RequiredDate    DATETIME2,
    OrderStatus     NVARCHAR(30),         -- 'Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'
    OrderChannel    NVARCHAR(30),         -- 'Online', 'InStore', 'Phone'
    Notes           NVARCHAR(1000),
    CreatedDate     DATETIME2 DEFAULT GETDATE(),
    ModifiedDate    DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES RAW.Customers(CustomerID),
    FOREIGN KEY (StoreID) REFERENCES RAW.Stores(StoreID),
    FOREIGN KEY (EmployeeID) REFERENCES RAW.Employees(EmployeeID)
);
GO

-- ============================================================
-- 8. RAW.OrderItems
-- ============================================================
CREATE TABLE RAW.OrderItems (
    OrderItemID     INT PRIMARY KEY,
    OrderID         INT NOT NULL,
    ProductID       INT NOT NULL,
    Quantity        INT NOT NULL,
    UnitPrice       DECIMAL(18,2) NOT NULL,
    Discount        DECIMAL(5,2) DEFAULT 0,
    LineTotal       AS (Quantity * UnitPrice * (1 - Discount / 100)) PERSISTED,
    CreatedDate     DATETIME2 DEFAULT GETDATE(),
    ModifiedDate    DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (OrderID) REFERENCES RAW.Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES RAW.Products(ProductID)
);
GO

-- ============================================================
-- 9. RAW.Payments
-- ============================================================
CREATE TABLE RAW.Payments (
    PaymentID       INT PRIMARY KEY,
    OrderID         INT NOT NULL,
    PaymentDate     DATETIME2 NOT NULL,
    PaymentMethod   NVARCHAR(50),         -- 'CreditCard', 'DebitCard', 'Cash', 'BankTransfer', 'DigitalWallet'
    Amount          DECIMAL(18,2) NOT NULL,
    Currency        NVARCHAR(3) DEFAULT 'USD',
    PaymentStatus   NVARCHAR(30),         -- 'Completed', 'Pending', 'Failed', 'Refunded'
    TransactionRef  NVARCHAR(100),
    CreatedDate     DATETIME2 DEFAULT GETDATE(),
    ModifiedDate    DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (OrderID) REFERENCES RAW.Orders(OrderID)
);
GO

-- ============================================================
-- 10. RAW.Shipments
-- ============================================================
CREATE TABLE RAW.Shipments (
    ShipmentID      INT PRIMARY KEY,
    OrderID         INT NOT NULL,
    ShipDate        DATETIME2,
    DeliveryDate    DATETIME2,
    Carrier         NVARCHAR(100),        -- 'FedEx', 'UPS', 'USPS', 'DHL'
    TrackingNumber  NVARCHAR(100),
    ShipmentStatus  NVARCHAR(30),         -- 'Preparing', 'Shipped', 'InTransit', 'Delivered', 'Returned'
    ShippingCost    DECIMAL(18,2),
    Address         NVARCHAR(300),
    City            NVARCHAR(100),
    State           NVARCHAR(100),
    Country         NVARCHAR(100),
    PostalCode      NVARCHAR(20),
    CreatedDate     DATETIME2 DEFAULT GETDATE(),
    ModifiedDate    DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (OrderID) REFERENCES RAW.Orders(OrderID)
);
GO

PRINT 'All 10 RAW schema tables created successfully.';
GO
