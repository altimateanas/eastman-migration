-- ============================================================
-- POC: MS SQL Server to Fabric Migration
-- Script 3: Populate RAW Schema Tables with Sample Data
-- Domain: Retail / E-Commerce
-- ============================================================

USE RetailDW;
GO

-- ============================================================
-- 1. Load Categories (8 categories)
-- ============================================================
INSERT INTO RAW.Categories (CategoryID, CategoryName, Description, IsActive)
VALUES
    (1, 'Electronics',      'Phones, laptops, tablets, and accessories',           1),
    (2, 'Clothing',         'Men, women, and children apparel',                    1),
    (3, 'Home & Kitchen',   'Furniture, appliances, and kitchenware',              1),
    (4, 'Sports & Outdoors','Equipment, gear, and outdoor accessories',            1),
    (5, 'Books',            'Physical and digital books across all genres',         1),
    (6, 'Health & Beauty',  'Personal care, cosmetics, and wellness products',     1),
    (7, 'Toys & Games',     'Children toys, board games, and puzzles',             1),
    (8, 'Grocery',          'Food, beverages, and household consumables',          1);
GO

-- ============================================================
-- 2. Load Suppliers (6 suppliers)
-- ============================================================
INSERT INTO RAW.Suppliers (SupplierID, SupplierName, ContactName, ContactEmail, Phone, Address, City, State, Country, PostalCode, IsActive)
VALUES
    (1, 'TechSource Inc.',       'Alice Johnson',   'alice@techsource.com',    '555-0101', '100 Tech Blvd',       'San Jose',      'CA', 'USA', '95110', 1),
    (2, 'Fashion Forward LLC',   'Bob Martinez',    'bob@fashionforward.com',  '555-0102', '200 Style Ave',       'New York',      'NY', 'USA', '10001', 1),
    (3, 'HomeCraft Supplies',    'Carol Lee',       'carol@homecraft.com',     '555-0103', '300 Home St',         'Chicago',       'IL', 'USA', '60601', 1),
    (4, 'SportMax Global',       'David Kim',       'david@sportmax.com',      '555-0104', '400 Athletic Way',    'Portland',      'OR', 'USA', '97201', 1),
    (5, 'BookWorld Distributors','Emily Chen',      'emily@bookworld.com',     '555-0105', '500 Library Ln',      'Boston',        'MA', 'USA', '02101', 1),
    (6, 'FreshGoods Co.',        'Frank Wilson',    'frank@freshgoods.com',    '555-0106', '600 Market St',       'Seattle',       'WA', 'USA', '98101', 1);
GO

-- ============================================================
-- 3. Load Products (30 products across categories)
-- ============================================================
INSERT INTO RAW.Products (ProductID, ProductName, CategoryID, SupplierID, SKU, UnitPrice, CostPrice, UnitsInStock, ReorderLevel, IsDiscontinued)
VALUES
    -- Electronics (Supplier 1)
    (1,  'Smartphone Pro X',           1, 1, 'ELEC-001', 999.99,  650.00, 150, 20, 0),
    (2,  'Laptop UltraBook 15',        1, 1, 'ELEC-002', 1299.99, 850.00, 80,  10, 0),
    (3,  'Wireless Earbuds Elite',      1, 1, 'ELEC-003', 199.99,  90.00,  300, 50, 0),
    (4,  'Tablet Air 10',              1, 1, 'ELEC-004', 499.99,  280.00, 120, 15, 0),
    -- Clothing (Supplier 2)
    (5,  'Men Cotton T-Shirt',          2, 2, 'CLTH-001', 29.99,   12.00,  500, 100, 0),
    (6,  'Women Denim Jacket',          2, 2, 'CLTH-002', 89.99,   40.00,  200, 30,  0),
    (7,  'Kids Winter Coat',            2, 2, 'CLTH-003', 59.99,   25.00,  150, 25,  0),
    (8,  'Unisex Running Shoes',        2, 2, 'CLTH-004', 119.99,  55.00,  250, 40,  0),
    -- Home & Kitchen (Supplier 3)
    (9,  'Stainless Steel Cookware Set',3, 3, 'HOME-001', 149.99,  70.00,  100, 15, 0),
    (10, 'Memory Foam Pillow',          3, 3, 'HOME-002', 49.99,   18.00,  400, 60, 0),
    (11, 'Robot Vacuum Cleaner',        3, 3, 'HOME-003', 349.99,  180.00, 60,  10, 0),
    (12, 'LED Desk Lamp',               3, 3, 'HOME-004', 39.99,   15.00,  350, 50, 0),
    -- Sports & Outdoors (Supplier 4)
    (13, 'Mountain Bike Pro',           4, 4, 'SPRT-001', 799.99,  420.00, 40,  5,  0),
    (14, 'Yoga Mat Premium',            4, 4, 'SPRT-002', 34.99,   12.00,  600, 80, 0),
    (15, 'Camping Tent 4-Person',       4, 4, 'SPRT-003', 189.99,  85.00,  75,  10, 0),
    (16, 'Dumbbell Set 50lb',           4, 4, 'SPRT-004', 129.99,  60.00,  100, 15, 0),
    -- Books (Supplier 5)
    (17, 'Data Engineering Handbook',   5, 5, 'BOOK-001', 44.99,   15.00,  200, 30, 0),
    (18, 'Modern SQL Mastery',          5, 5, 'BOOK-002', 39.99,   13.00,  180, 25, 0),
    (19, 'Cloud Architecture Guide',    5, 5, 'BOOK-003', 54.99,   20.00,  150, 20, 0),
    (20, 'Python for Data Science',     5, 5, 'BOOK-004', 49.99,   17.00,  220, 35, 0),
    -- Health & Beauty (Supplier 6)
    (21, 'Organic Face Cream',          6, 6, 'HLTH-001', 24.99,   8.00,   400, 60, 0),
    (22, 'Vitamin D Supplements',       6, 6, 'HLTH-002', 19.99,   6.00,   500, 80, 0),
    (23, 'Electric Toothbrush',         6, 6, 'HLTH-003', 79.99,   35.00,  200, 30, 0),
    (24, 'Hair Care Kit',               6, 6, 'HLTH-004', 34.99,   12.00,  300, 45, 0),
    -- Toys & Games (Supplier 3)
    (25, 'Building Blocks Set 500pc',   7, 3, 'TOYS-001', 44.99,   15.00,  250, 40, 0),
    (26, 'Strategy Board Game',         7, 3, 'TOYS-002', 29.99,   10.00,  300, 50, 0),
    (27, 'Remote Control Car',          7, 3, 'TOYS-003', 54.99,   22.00,  180, 25, 0),
    -- Grocery (Supplier 6)
    (28, 'Organic Coffee Beans 1lb',    8, 6, 'GROC-001', 14.99,   5.00,   600, 100, 0),
    (29, 'Mixed Nuts Premium 2lb',      8, 6, 'GROC-002', 19.99,   7.00,   400, 70,  0),
    (30, 'Green Tea Sampler Pack',      8, 6, 'GROC-003', 12.99,   4.00,   500, 80,  0);
GO

-- ============================================================
-- 4. Load Stores (5 stores)
-- ============================================================
INSERT INTO RAW.Stores (StoreID, StoreName, StoreType, Address, City, State, Country, PostalCode, Phone, ManagerName, OpenDate, IsActive)
VALUES
    (1, 'Downtown Flagship Store',      'Retail',    '10 Main St',        'Nashville',     'TN', 'USA', '37201', '615-555-0001', 'Sarah Thompson',  '2018-03-15', 1),
    (2, 'Mall Plaza Store',             'Retail',    '250 Mall Dr',       'Atlanta',       'GA', 'USA', '30301', '404-555-0002', 'James Rivera',    '2019-06-01', 1),
    (3, 'Online Store',                 'Online',    '500 Digital Way',   'Austin',        'TX', 'USA', '73301', '512-555-0003', 'Karen White',     '2020-01-10', 1),
    (4, 'West Coast Hub',               'Retail',    '800 Pacific Ave',   'Los Angeles',   'CA', 'USA', '90001', '213-555-0004', 'Michael Chang',   '2020-09-20', 1),
    (5, 'Distribution Center',          'Warehouse', '1200 Logistics Pkwy','Memphis',      'TN', 'USA', '38101', '901-555-0005', 'Patricia Adams',  '2017-11-01', 1);
GO

-- ============================================================
-- 5. Load Employees (15 employees)
-- ============================================================
INSERT INTO RAW.Employees (EmployeeID, FirstName, LastName, Email, Phone, HireDate, JobTitle, Department, StoreID, ManagerID, Salary, IsActive)
VALUES
    (1,  'Sarah',    'Thompson', 'sarah.thompson@company.com',   '615-555-1001', '2018-03-15', 'Store Manager',       'Management',   1, NULL, 85000.00, 1),
    (2,  'James',    'Rivera',   'james.rivera@company.com',     '404-555-1002', '2019-06-01', 'Store Manager',       'Management',   2, NULL, 82000.00, 1),
    (3,  'Karen',    'White',    'karen.white@company.com',      '512-555-1003', '2020-01-10', 'E-Commerce Manager',  'Management',   3, NULL, 90000.00, 1),
    (4,  'Michael',  'Chang',    'michael.chang@company.com',    '213-555-1004', '2020-09-20', 'Store Manager',       'Management',   4, NULL, 83000.00, 1),
    (5,  'Patricia', 'Adams',    'patricia.adams@company.com',   '901-555-1005', '2017-11-01', 'Warehouse Manager',   'Operations',   5, NULL, 78000.00, 1),
    (6,  'Tom',      'Baker',    'tom.baker@company.com',        '615-555-1006', '2019-01-20', 'Sales Associate',     'Sales',        1, 1,    42000.00, 1),
    (7,  'Lisa',     'Garcia',   'lisa.garcia@company.com',      '615-555-1007', '2019-04-15', 'Sales Associate',     'Sales',        1, 1,    41000.00, 1),
    (8,  'Kevin',    'Brown',    'kevin.brown@company.com',      '404-555-1008', '2019-08-10', 'Sales Associate',     'Sales',        2, 2,    40000.00, 1),
    (9,  'Amanda',   'Davis',    'amanda.davis@company.com',     '404-555-1009', '2020-02-01', 'Cashier',             'Sales',        2, 2,    35000.00, 1),
    (10, 'Ryan',     'Miller',   'ryan.miller@company.com',      '512-555-1010', '2020-03-15', 'Customer Support',    'Support',      3, 3,    45000.00, 1),
    (11, 'Jessica',  'Wilson',   'jessica.wilson@company.com',   '512-555-1011', '2020-06-01', 'Digital Marketing',   'Marketing',    3, 3,    52000.00, 1),
    (12, 'Daniel',   'Taylor',   'daniel.taylor@company.com',    '213-555-1012', '2021-01-10', 'Sales Associate',     'Sales',        4, 4,    41000.00, 1),
    (13, 'Megan',    'Anderson', 'megan.anderson@company.com',   '213-555-1013', '2021-03-20', 'Sales Associate',     'Sales',        4, 4,    40000.00, 1),
    (14, 'Chris',    'Martin',   'chris.martin@company.com',     '901-555-1014', '2018-02-01', 'Warehouse Associate', 'Operations',   5, 5,    38000.00, 1),
    (15, 'Natalie',  'Lewis',    'natalie.lewis@company.com',    '901-555-1015', '2019-07-15', 'Shipping Coordinator','Operations',   5, 5,    40000.00, 1);
GO

-- ============================================================
-- 6. Load Customers (25 customers)
-- ============================================================
INSERT INTO RAW.Customers (CustomerID, FirstName, LastName, Email, Phone, DateOfBirth, Gender, Address, City, State, Country, PostalCode, CustomerSegment, RegistrationDate, IsActive)
VALUES
    (1,  'John',      'Smith',      'john.smith@email.com',       '555-2001', '1985-04-12', 'Male',   '101 Oak St',       'Nashville',    'TN', 'USA', '37201', 'Premium',  '2021-01-15', 1),
    (2,  'Emily',     'Johnson',    'emily.j@email.com',          '555-2002', '1990-08-25', 'Female', '202 Elm Ave',      'Atlanta',      'GA', 'USA', '30301', 'VIP',      '2020-06-10', 1),
    (3,  'Robert',    'Williams',   'rob.w@email.com',            '555-2003', '1978-12-03', 'Male',   '303 Pine Rd',     'Austin',       'TX', 'USA', '73301', 'Regular',  '2021-03-22', 1),
    (4,  'Maria',     'Garcia',     'maria.g@email.com',          '555-2004', '1992-02-14', 'Female', '404 Cedar Ln',    'Los Angeles',  'CA', 'USA', '90001', 'Premium',  '2021-05-01', 1),
    (5,  'David',     'Brown',      'david.b@email.com',          '555-2005', '1988-07-30', 'Male',   '505 Maple Dr',    'Nashville',    'TN', 'USA', '37203', 'Regular',  '2021-07-18', 1),
    (6,  'Jennifer',  'Jones',      'jen.jones@email.com',        '555-2006', '1995-11-08', 'Female', '606 Birch Way',   'Atlanta',      'GA', 'USA', '30302', 'Regular',  '2021-09-05', 1),
    (7,  'Michael',   'Davis',      'mike.d@email.com',           '555-2007', '1982-01-20', 'Male',   '707 Walnut St',   'Chicago',      'IL', 'USA', '60601', 'VIP',      '2020-11-30', 1),
    (8,  'Ashley',    'Miller',     'ashley.m@email.com',         '555-2008', '1993-06-15', 'Female', '808 Spruce Ave',  'Memphis',      'TN', 'USA', '38101', 'Regular',  '2022-01-12', 1),
    (9,  'Christopher','Wilson',    'chris.w@email.com',          '555-2009', '1987-09-22', 'Male',   '909 Ash Blvd',    'Portland',     'OR', 'USA', '97201', 'Premium',  '2021-04-25', 1),
    (10, 'Jessica',   'Moore',      'jessica.m@email.com',        '555-2010', '1991-03-18', 'Female', '1010 Redwood Ct', 'Seattle',      'WA', 'USA', '98101', 'Regular',  '2022-02-28', 1),
    (11, 'Matthew',   'Taylor',     'matt.t@email.com',           '555-2011', '1980-05-05', 'Male',   '111 First St',    'Nashville',    'TN', 'USA', '37205', 'VIP',      '2020-08-14', 1),
    (12, 'Amanda',    'Thomas',     'amanda.t@email.com',         '555-2012', '1996-10-11', 'Female', '222 Second Ave',  'Austin',       'TX', 'USA', '73302', 'Regular',  '2022-04-10', 1),
    (13, 'Andrew',    'Jackson',    'andrew.j@email.com',         '555-2013', '1984-08-28', 'Male',   '333 Third Blvd',  'Los Angeles',  'CA', 'USA', '90002', 'Premium',  '2021-06-15', 1),
    (14, 'Stephanie', 'White',      'steph.w@email.com',          '555-2014', '1994-12-01', 'Female', '444 Fourth Ln',   'Atlanta',      'GA', 'USA', '30303', 'Regular',  '2022-05-20', 1),
    (15, 'Joshua',    'Harris',     'josh.h@email.com',           '555-2015', '1989-02-19', 'Male',   '555 Fifth Dr',    'Nashville',    'TN', 'USA', '37206', 'Premium',  '2021-08-08', 1),
    (16, 'Lauren',    'Martin',     'lauren.m@email.com',         '555-2016', '1997-04-07', 'Female', '666 Sixth Way',   'Memphis',      'TN', 'USA', '38102', 'Regular',  '2022-07-01', 1),
    (17, 'Daniel',    'Thompson',   'dan.t@email.com',            '555-2017', '1983-11-14', 'Male',   '777 Seventh St',  'Chicago',      'IL', 'USA', '60602', 'Regular',  '2022-03-15', 1),
    (18, 'Rachel',    'Robinson',   'rachel.r@email.com',         '555-2018', '1990-07-26', 'Female', '888 Eighth Ave',  'Portland',     'OR', 'USA', '97202', 'Premium',  '2021-10-22', 1),
    (19, 'Brandon',   'Clark',      'brandon.c@email.com',        '555-2019', '1986-01-30', 'Male',   '999 Ninth Rd',    'Seattle',      'WA', 'USA', '98102', 'Regular',  '2022-08-18', 1),
    (20, 'Samantha',  'Lewis',      'sam.l@email.com',            '555-2020', '1998-09-09', 'Female', '1000 Tenth Ct',   'Austin',       'TX', 'USA', '73303', 'VIP',      '2021-02-05', 1),
    (21, 'Tyler',     'Walker',     'tyler.w@email.com',          '555-2021', '1981-06-17', 'Male',   '1111 Oak Hill',   'Nashville',    'TN', 'USA', '37207', 'Regular',  '2022-09-12', 1),
    (22, 'Megan',     'Hall',       'megan.h@email.com',          '555-2022', '1993-03-24', 'Female', '1222 Elm Park',   'Los Angeles',  'CA', 'USA', '90003', 'Premium',  '2021-12-01', 1),
    (23, 'Jacob',     'Allen',      'jacob.a@email.com',          '555-2023', '1975-08-08', 'Male',   '1333 Pine View',  'Atlanta',      'GA', 'USA', '30304', 'Regular',  '2022-10-05', 1),
    (24, 'Brittany',  'Young',      'brittany.y@email.com',       '555-2024', '1999-05-21', 'Female', '1444 Cedar Path', 'Memphis',      'TN', 'USA', '38103', 'Regular',  '2022-11-18', 1),
    (25, 'Aaron',     'King',       'aaron.k@email.com',          '555-2025', '1977-10-02', 'Male',   '1555 Maple Ct',   'Chicago',      'IL', 'USA', '60603', 'VIP',      '2020-04-20', 1);
GO

-- ============================================================
-- 7. Load Orders (50 orders spanning 2023-2025)
-- ============================================================
INSERT INTO RAW.Orders (OrderID, CustomerID, StoreID, EmployeeID, OrderDate, RequiredDate, OrderStatus, OrderChannel, Notes)
VALUES
    (1001, 1,  1, 6,  '2023-01-15 10:30:00', '2023-01-22', 'Delivered',   'InStore',  NULL),
    (1002, 2,  3, 10, '2023-01-20 14:15:00', '2023-01-27', 'Delivered',   'Online',   NULL),
    (1003, 3,  3, 10, '2023-02-05 09:00:00', '2023-02-12', 'Delivered',   'Online',   NULL),
    (1004, 7,  2, 8,  '2023-02-14 11:45:00', '2023-02-21', 'Delivered',   'InStore',  'Valentine gift'),
    (1005, 4,  4, 12, '2023-03-01 16:20:00', '2023-03-08', 'Delivered',   'InStore',  NULL),
    (1006, 5,  1, 7,  '2023-03-18 13:00:00', '2023-03-25', 'Delivered',   'InStore',  NULL),
    (1007, 11, 3, 10, '2023-04-02 08:30:00', '2023-04-09', 'Delivered',   'Online',   NULL),
    (1008, 2,  3, 10, '2023-04-15 19:00:00', '2023-04-22', 'Delivered',   'Online',   'Express shipping requested'),
    (1009, 9,  3, 10, '2023-05-10 12:15:00', '2023-05-17', 'Delivered',   'Online',   NULL),
    (1010, 6,  2, 9,  '2023-05-28 15:30:00', '2023-06-04', 'Delivered',   'InStore',  NULL),
    (1011, 13, 4, 13, '2023-06-12 10:00:00', '2023-06-19', 'Delivered',   'InStore',  NULL),
    (1012, 20, 3, 10, '2023-06-25 17:45:00', '2023-07-02', 'Delivered',   'Online',   NULL),
    (1013, 8,  1, 6,  '2023-07-04 09:30:00', '2023-07-11', 'Delivered',   'InStore',  'Holiday sale'),
    (1014, 15, 3, 10, '2023-07-20 14:00:00', '2023-07-27', 'Delivered',   'Online',   NULL),
    (1015, 10, 3, 10, '2023-08-08 11:15:00', '2023-08-15', 'Delivered',   'Online',   NULL),
    (1016, 25, 2, 8,  '2023-08-22 16:30:00', '2023-08-29', 'Delivered',   'InStore',  NULL),
    (1017, 1,  3, 10, '2023-09-05 10:00:00', '2023-09-12', 'Delivered',   'Online',   'Return customer'),
    (1018, 14, 2, 9,  '2023-09-18 13:45:00', '2023-09-25', 'Delivered',   'InStore',  NULL),
    (1019, 18, 3, 10, '2023-10-01 08:00:00', '2023-10-08', 'Delivered',   'Online',   NULL),
    (1020, 7,  3, 10, '2023-10-15 11:30:00', '2023-10-22', 'Delivered',   'Online',   NULL),
    (1021, 22, 4, 12, '2023-11-10 14:15:00', '2023-11-17', 'Delivered',   'InStore',  NULL),
    (1022, 3,  3, 10, '2023-11-24 09:00:00', '2023-12-01', 'Delivered',   'Online',   'Black Friday order'),
    (1023, 12, 3, 10, '2023-12-10 18:30:00', '2023-12-17', 'Delivered',   'Online',   NULL),
    (1024, 5,  1, 7,  '2023-12-22 12:00:00', '2023-12-29', 'Delivered',   'InStore',  'Christmas gift'),
    (1025, 11, 3, 10, '2024-01-08 10:30:00', '2024-01-15', 'Delivered',   'Online',   NULL),
    (1026, 16, 1, 6,  '2024-01-20 15:00:00', '2024-01-27', 'Delivered',   'InStore',  NULL),
    (1027, 4,  3, 10, '2024-02-12 09:15:00', '2024-02-19', 'Delivered',   'Online',   NULL),
    (1028, 19, 3, 10, '2024-02-28 14:30:00', '2024-03-06', 'Delivered',   'Online',   NULL),
    (1029, 2,  2, 8,  '2024-03-15 11:00:00', '2024-03-22', 'Delivered',   'InStore',  NULL),
    (1030, 21, 3, 10, '2024-03-30 17:00:00', '2024-04-06', 'Delivered',   'Online',   NULL),
    (1031, 9,  4, 13, '2024-04-10 10:45:00', '2024-04-17', 'Delivered',   'InStore',  NULL),
    (1032, 23, 3, 10, '2024-04-25 13:30:00', '2024-05-02', 'Delivered',   'Online',   NULL),
    (1033, 17, 2, 8,  '2024-05-08 16:15:00', '2024-05-15', 'Delivered',   'InStore',  NULL),
    (1034, 6,  3, 10, '2024-05-22 08:45:00', '2024-05-29', 'Delivered',   'Online',   NULL),
    (1035, 24, 1, 7,  '2024-06-05 12:30:00', '2024-06-12', 'Delivered',   'InStore',  NULL),
    (1036, 13, 3, 10, '2024-06-18 15:45:00', '2024-06-25', 'Delivered',   'Online',   NULL),
    (1037, 15, 4, 12, '2024-07-02 09:00:00', '2024-07-09', 'Delivered',   'InStore',  NULL),
    (1038, 10, 3, 10, '2024-07-20 14:15:00', '2024-07-27', 'Delivered',   'Online',   NULL),
    (1039, 20, 3, 10, '2024-08-05 11:30:00', '2024-08-12', 'Delivered',   'Online',   NULL),
    (1040, 8,  2, 9,  '2024-08-18 16:00:00', '2024-08-25', 'Delivered',   'InStore',  NULL),
    (1041, 25, 3, 10, '2024-09-01 10:00:00', '2024-09-08', 'Shipped',     'Online',   NULL),
    (1042, 1,  1, 6,  '2024-09-15 13:30:00', '2024-09-22', 'Shipped',     'InStore',  NULL),
    (1043, 22, 3, 10, '2024-10-03 08:15:00', '2024-10-10', 'Processing',  'Online',   NULL),
    (1044, 7,  4, 13, '2024-10-18 17:30:00', '2024-10-25', 'Processing',  'InStore',  NULL),
    (1045, 14, 3, 10, '2024-11-01 12:00:00', '2024-11-08', 'Pending',     'Online',   NULL),
    (1046, 3,  3, 10, '2024-11-15 09:45:00', '2024-11-22', 'Pending',     'Online',   NULL),
    (1047, 16, 2, 8,  '2024-12-01 14:30:00', '2024-12-08', 'Pending',     'InStore',  NULL),
    (1048, 11, 3, 10, '2024-12-10 11:00:00', '2024-12-17', 'Cancelled',   'Online',   'Customer requested cancellation'),
    (1049, 5,  1, 7,  '2025-01-05 10:30:00', '2025-01-12', 'Pending',     'InStore',  NULL),
    (1050, 20, 3, 10, '2025-01-20 15:15:00', '2025-01-27', 'Pending',     'Online',   NULL);
GO

-- ============================================================
-- 8. Load OrderItems (100 line items)
-- ============================================================
INSERT INTO RAW.OrderItems (OrderItemID, OrderID, ProductID, Quantity, UnitPrice, Discount)
VALUES
    -- Order 1001
    (1,   1001, 1,  1, 999.99,  0),
    (2,   1001, 3,  2, 199.99,  5),
    -- Order 1002
    (3,   1002, 5,  3, 29.99,   0),
    (4,   1002, 6,  1, 89.99,   10),
    (5,   1002, 8,  1, 119.99,  0),
    -- Order 1003
    (6,   1003, 17, 2, 44.99,   0),
    (7,   1003, 20, 1, 49.99,   0),
    -- Order 1004
    (8,   1004, 21, 2, 24.99,   0),
    (9,   1004, 24, 1, 34.99,   0),
    (10,  1004, 10, 2, 49.99,   15),
    -- Order 1005
    (11,  1005, 2,  1, 1299.99, 0),
    (12,  1005, 4,  1, 499.99,  5),
    -- Order 1006
    (13,  1006, 14, 2, 34.99,   0),
    (14,  1006, 16, 1, 129.99,  0),
    -- Order 1007
    (15,  1007, 1,  1, 999.99,  10),
    (16,  1007, 3,  1, 199.99,  10),
    -- Order 1008
    (17,  1008, 9,  1, 149.99,  0),
    (18,  1008, 11, 1, 349.99,  5),
    -- Order 1009
    (19,  1009, 13, 1, 799.99,  0),
    (20,  1009, 15, 1, 189.99,  0),
    -- Order 1010
    (21,  1010, 5,  4, 29.99,   0),
    (22,  1010, 7,  2, 59.99,   0),
    -- Order 1011
    (23,  1011, 2,  1, 1299.99, 5),
    (24,  1011, 12, 2, 39.99,   0),
    -- Order 1012
    (25,  1012, 28, 5, 14.99,   0),
    (26,  1012, 29, 3, 19.99,   0),
    (27,  1012, 30, 4, 12.99,   0),
    -- Order 1013
    (28,  1013, 25, 2, 44.99,   0),
    (29,  1013, 26, 1, 29.99,   10),
    (30,  1013, 27, 1, 54.99,   0),
    -- Order 1014
    (31,  1014, 19, 1, 54.99,   0),
    (32,  1014, 18, 1, 39.99,   0),
    -- Order 1015
    (33,  1015, 22, 3, 19.99,   0),
    (34,  1015, 23, 1, 79.99,   0),
    -- Order 1016
    (35,  1016, 1,  1, 999.99,  0),
    (36,  1016, 4,  1, 499.99,  10),
    -- Order 1017
    (37,  1017, 8,  2, 119.99,  5),
    (38,  1017, 6,  1, 89.99,   0),
    -- Order 1018
    (39,  1018, 10, 3, 49.99,   0),
    (40,  1018, 12, 1, 39.99,   0),
    -- Order 1019
    (41,  1019, 17, 1, 44.99,   0),
    (42,  1019, 19, 1, 54.99,   0),
    -- Order 1020
    (43,  1020, 11, 1, 349.99,  0),
    (44,  1020, 9,  1, 149.99,  10),
    -- Order 1021
    (45,  1021, 5,  2, 29.99,   0),
    (46,  1021, 7,  1, 59.99,   0),
    (47,  1021, 8,  1, 119.99,  0),
    -- Order 1022
    (48,  1022, 2,  1, 1299.99, 15),
    (49,  1022, 3,  2, 199.99,  15),
    -- Order 1023
    (50,  1023, 28, 3, 14.99,   0),
    (51,  1023, 30, 2, 12.99,   0),
    -- Order 1024
    (52,  1024, 25, 3, 44.99,   0),
    (53,  1024, 27, 1, 54.99,   0),
    -- Order 1025
    (54,  1025, 1,  1, 999.99,  5),
    (55,  1025, 4,  1, 499.99,  5),
    -- Order 1026
    (56,  1026, 14, 1, 34.99,   0),
    (57,  1026, 22, 2, 19.99,   0),
    -- Order 1027
    (58,  1027, 6,  2, 89.99,   0),
    (59,  1027, 8,  1, 119.99,  10),
    -- Order 1028
    (60,  1028, 29, 4, 19.99,   0),
    (61,  1028, 28, 2, 14.99,   0),
    -- Order 1029
    (62,  1029, 9,  1, 149.99,  5),
    (63,  1029, 10, 2, 49.99,   0),
    (64,  1029, 12, 3, 39.99,   0),
    -- Order 1030
    (65,  1030, 17, 1, 44.99,   0),
    (66,  1030, 20, 2, 49.99,   0),
    -- Order 1031
    (67,  1031, 13, 1, 799.99,  5),
    (68,  1031, 16, 1, 129.99,  0),
    -- Order 1032
    (69,  1032, 21, 3, 24.99,   0),
    (70,  1032, 23, 1, 79.99,   0),
    -- Order 1033
    (71,  1033, 5,  5, 29.99,   0),
    (72,  1033, 6,  1, 89.99,   5),
    -- Order 1034
    (73,  1034, 15, 1, 189.99,  0),
    (74,  1034, 14, 3, 34.99,   0),
    -- Order 1035
    (75,  1035, 26, 2, 29.99,   0),
    (76,  1035, 25, 1, 44.99,   0),
    -- Order 1036
    (77,  1036, 2,  1, 1299.99, 10),
    (78,  1036, 3,  1, 199.99,  0),
    -- Order 1037
    (79,  1037, 8,  2, 119.99,  0),
    (80,  1037, 5,  3, 29.99,   10),
    -- Order 1038
    (81,  1038, 24, 2, 34.99,   0),
    (82,  1038, 22, 1, 19.99,   0),
    -- Order 1039
    (83,  1039, 11, 1, 349.99,  5),
    (84,  1039, 12, 2, 39.99,   0),
    -- Order 1040
    (85,  1040, 7,  3, 59.99,   0),
    (86,  1040, 5,  2, 29.99,   0),
    -- Order 1041
    (87,  1041, 1,  1, 999.99,  0),
    (88,  1041, 2,  1, 1299.99, 5),
    -- Order 1042
    (89,  1042, 9,  1, 149.99,  0),
    (90,  1042, 10, 4, 49.99,   0),
    -- Order 1043
    (91,  1043, 19, 2, 54.99,   0),
    (92,  1043, 18, 1, 39.99,   0),
    -- Order 1044
    (93,  1044, 13, 1, 799.99,  10),
    (94,  1044, 14, 2, 34.99,   0),
    -- Order 1045
    (95,  1045, 6,  1, 89.99,   0),
    (96,  1045, 7,  2, 59.99,   5),
    -- Order 1046
    (97,  1046, 20, 1, 49.99,   0),
    (98,  1046, 17, 2, 44.99,   0),
    -- Order 1047
    (99,  1047, 23, 1, 79.99,   0),
    (100, 1047, 21, 2, 24.99,   0);
GO

-- ============================================================
-- 9. Load Payments (50 payments - one per order)
-- ============================================================
INSERT INTO RAW.Payments (PaymentID, OrderID, PaymentDate, PaymentMethod, Amount, Currency, PaymentStatus, TransactionRef)
VALUES
    (1,  1001, '2023-01-15 10:35:00', 'CreditCard',    1379.97, 'USD', 'Completed', 'TXN-2023-0001'),
    (2,  1002, '2023-01-20 14:20:00', 'DebitCard',       299.96, 'USD', 'Completed', 'TXN-2023-0002'),
    (3,  1003, '2023-02-05 09:05:00', 'CreditCard',      139.97, 'USD', 'Completed', 'TXN-2023-0003'),
    (4,  1004, '2023-02-14 11:50:00', 'DigitalWallet',   169.93, 'USD', 'Completed', 'TXN-2023-0004'),
    (5,  1005, '2023-03-01 16:25:00', 'CreditCard',     1774.98, 'USD', 'Completed', 'TXN-2023-0005'),
    (6,  1006, '2023-03-18 13:05:00', 'Cash',            199.97, 'USD', 'Completed', 'TXN-2023-0006'),
    (7,  1007, '2023-04-02 08:35:00', 'CreditCard',     1079.98, 'USD', 'Completed', 'TXN-2023-0007'),
    (8,  1008, '2023-04-15 19:05:00', 'DigitalWallet',   482.48, 'USD', 'Completed', 'TXN-2023-0008'),
    (9,  1009, '2023-05-10 12:20:00', 'CreditCard',      989.98, 'USD', 'Completed', 'TXN-2023-0009'),
    (10, 1010, '2023-05-28 15:35:00', 'DebitCard',       239.94, 'USD', 'Completed', 'TXN-2023-0010'),
    (11, 1011, '2023-06-12 10:05:00', 'CreditCard',     1314.97, 'USD', 'Completed', 'TXN-2023-0011'),
    (12, 1012, '2023-06-25 17:50:00', 'DigitalWallet',   186.89, 'USD', 'Completed', 'TXN-2023-0012'),
    (13, 1013, '2023-07-04 09:35:00', 'Cash',            184.96, 'USD', 'Completed', 'TXN-2023-0013'),
    (14, 1014, '2023-07-20 14:05:00', 'CreditCard',       94.98, 'USD', 'Completed', 'TXN-2023-0014'),
    (15, 1015, '2023-08-08 11:20:00', 'DebitCard',       139.96, 'USD', 'Completed', 'TXN-2023-0015'),
    (16, 1016, '2023-08-22 16:35:00', 'CreditCard',     1449.98, 'USD', 'Completed', 'TXN-2023-0016'),
    (17, 1017, '2023-09-05 10:05:00', 'DigitalWallet',   317.96, 'USD', 'Completed', 'TXN-2023-0017'),
    (18, 1018, '2023-09-18 13:50:00', 'CreditCard',      189.96, 'USD', 'Completed', 'TXN-2023-0018'),
    (19, 1019, '2023-10-01 08:05:00', 'CreditCard',       99.98, 'USD', 'Completed', 'TXN-2023-0019'),
    (20, 1020, '2023-10-15 11:35:00', 'BankTransfer',    484.98, 'USD', 'Completed', 'TXN-2023-0020'),
    (21, 1021, '2023-11-10 14:20:00', 'DebitCard',       239.96, 'USD', 'Completed', 'TXN-2023-0021'),
    (22, 1022, '2023-11-24 09:05:00', 'CreditCard',     1444.97, 'USD', 'Completed', 'TXN-2023-0022'),
    (23, 1023, '2023-12-10 18:35:00', 'DigitalWallet',    70.95, 'USD', 'Completed', 'TXN-2023-0023'),
    (24, 1024, '2023-12-22 12:05:00', 'Cash',            189.96, 'USD', 'Completed', 'TXN-2023-0024'),
    (25, 1025, '2024-01-08 10:35:00', 'CreditCard',     1424.98, 'USD', 'Completed', 'TXN-2024-0025'),
    (26, 1026, '2024-01-20 15:05:00', 'DebitCard',        74.97, 'USD', 'Completed', 'TXN-2024-0026'),
    (27, 1027, '2024-02-12 09:20:00', 'CreditCard',      291.97, 'USD', 'Completed', 'TXN-2024-0027'),
    (28, 1028, '2024-02-28 14:35:00', 'DigitalWallet',   109.94, 'USD', 'Completed', 'TXN-2024-0028'),
    (29, 1029, '2024-03-15 11:05:00', 'CreditCard',      362.43, 'USD', 'Completed', 'TXN-2024-0029'),
    (30, 1030, '2024-03-30 17:05:00', 'BankTransfer',    144.97, 'USD', 'Completed', 'TXN-2024-0030'),
    (31, 1031, '2024-04-10 10:50:00', 'CreditCard',      889.98, 'USD', 'Completed', 'TXN-2024-0031'),
    (32, 1032, '2024-04-25 13:35:00', 'DigitalWallet',   154.96, 'USD', 'Completed', 'TXN-2024-0032'),
    (33, 1033, '2024-05-08 16:20:00', 'DebitCard',       235.44, 'USD', 'Completed', 'TXN-2024-0033'),
    (34, 1034, '2024-05-22 08:50:00', 'CreditCard',      294.96, 'USD', 'Completed', 'TXN-2024-0034'),
    (35, 1035, '2024-06-05 12:35:00', 'Cash',            104.97, 'USD', 'Completed', 'TXN-2024-0035'),
    (36, 1036, '2024-06-18 15:50:00', 'CreditCard',     1369.98, 'USD', 'Completed', 'TXN-2024-0036'),
    (37, 1037, '2024-07-02 09:05:00', 'DebitCard',       320.95, 'USD', 'Completed', 'TXN-2024-0037'),
    (38, 1038, '2024-07-20 14:20:00', 'DigitalWallet',    89.97, 'USD', 'Completed', 'TXN-2024-0038'),
    (39, 1039, '2024-08-05 11:35:00', 'CreditCard',      412.47, 'USD', 'Completed', 'TXN-2024-0039'),
    (40, 1040, '2024-08-18 16:05:00', 'Cash',            239.95, 'USD', 'Completed', 'TXN-2024-0040'),
    (41, 1041, '2024-09-01 10:05:00', 'CreditCard',     2234.98, 'USD', 'Completed', 'TXN-2024-0041'),
    (42, 1042, '2024-09-15 13:35:00', 'DebitCard',       349.95, 'USD', 'Completed', 'TXN-2024-0042'),
    (43, 1043, '2024-10-03 08:20:00', 'CreditCard',      149.97, 'USD', 'Pending',   'TXN-2024-0043'),
    (44, 1044, '2024-10-18 17:35:00', 'BankTransfer',    789.97, 'USD', 'Pending',   'TXN-2024-0044'),
    (45, 1045, '2024-11-01 12:05:00', 'CreditCard',      203.96, 'USD', 'Pending',   'TXN-2024-0045'),
    (46, 1046, '2024-11-15 09:50:00', 'DigitalWallet',   139.97, 'USD', 'Pending',   'TXN-2024-0046'),
    (47, 1047, '2024-12-01 14:35:00', 'DebitCard',       129.97, 'USD', 'Pending',   'TXN-2024-0047'),
    (48, 1048, '2024-12-10 11:05:00', 'CreditCard',     1424.98, 'USD', 'Refunded',  'TXN-2024-0048'),
    (49, 1049, '2025-01-05 10:35:00', 'Cash',            149.99, 'USD', 'Pending',   'TXN-2025-0049'),
    (50, 1050, '2025-01-20 15:20:00', 'CreditCard',      412.47, 'USD', 'Pending',   'TXN-2025-0050');
GO

-- ============================================================
-- 10. Load Shipments (45 shipments - not all orders shipped)
-- ============================================================
INSERT INTO RAW.Shipments (ShipmentID, OrderID, ShipDate, DeliveryDate, Carrier, TrackingNumber, ShipmentStatus, ShippingCost, Address, City, State, Country, PostalCode)
VALUES
    (1,  1001, '2023-01-16 08:00:00', '2023-01-19 14:00:00', 'UPS',   'UPS1001001', 'Delivered', 12.99, '101 Oak St',       'Nashville',   'TN', 'USA', '37201'),
    (2,  1002, '2023-01-21 09:00:00', '2023-01-25 11:00:00', 'FedEx', 'FDX1002001', 'Delivered', 15.99, '202 Elm Ave',      'Atlanta',     'GA', 'USA', '30301'),
    (3,  1003, '2023-02-06 10:00:00', '2023-02-10 13:00:00', 'USPS',  'USP1003001', 'Delivered',  8.99, '303 Pine Rd',     'Austin',      'TX', 'USA', '73301'),
    (4,  1004, '2023-02-15 08:30:00', '2023-02-18 15:00:00', 'UPS',   'UPS1004001', 'Delivered', 10.99, '707 Walnut St',   'Chicago',     'IL', 'USA', '60601'),
    (5,  1005, '2023-03-02 09:00:00', '2023-03-06 12:00:00', 'FedEx', 'FDX1005001', 'Delivered', 19.99, '404 Cedar Ln',    'Los Angeles', 'CA', 'USA', '90001'),
    (6,  1006, '2023-03-19 08:00:00', '2023-03-22 14:30:00', 'UPS',   'UPS1006001', 'Delivered', 12.99, '505 Maple Dr',    'Nashville',   'TN', 'USA', '37203'),
    (7,  1007, '2023-04-03 09:30:00', '2023-04-07 11:00:00', 'DHL',   'DHL1007001', 'Delivered', 22.99, '111 First St',    'Nashville',   'TN', 'USA', '37205'),
    (8,  1008, '2023-04-16 08:00:00', '2023-04-18 10:00:00', 'FedEx', 'FDX1008001', 'Delivered', 24.99, '202 Elm Ave',      'Atlanta',     'GA', 'USA', '30301'),
    (9,  1009, '2023-05-11 09:00:00', '2023-05-15 13:00:00', 'UPS',   'UPS1009001', 'Delivered', 29.99, '909 Ash Blvd',    'Portland',    'OR', 'USA', '97201'),
    (10, 1010, '2023-05-29 08:30:00', '2023-06-01 14:00:00', 'USPS',  'USP1010001', 'Delivered',  9.99, '606 Birch Way',   'Atlanta',     'GA', 'USA', '30302'),
    (11, 1011, '2023-06-13 09:00:00', '2023-06-17 12:00:00', 'FedEx', 'FDX1011001', 'Delivered', 19.99, '333 Third Blvd',  'Los Angeles', 'CA', 'USA', '90002'),
    (12, 1012, '2023-06-26 08:00:00', '2023-06-30 11:00:00', 'USPS',  'USP1012001', 'Delivered',  7.99, '1000 Tenth Ct',   'Austin',      'TX', 'USA', '73303'),
    (13, 1013, '2023-07-05 09:30:00', '2023-07-08 14:00:00', 'UPS',   'UPS1013001', 'Delivered', 10.99, '808 Spruce Ave',  'Memphis',     'TN', 'USA', '38101'),
    (14, 1014, '2023-07-21 08:00:00', '2023-07-25 12:00:00', 'FedEx', 'FDX1014001', 'Delivered', 12.99, '555 Fifth Dr',    'Nashville',   'TN', 'USA', '37206'),
    (15, 1015, '2023-08-09 09:00:00', '2023-08-13 13:00:00', 'USPS',  'USP1015001', 'Delivered',  8.99, '1010 Redwood Ct', 'Seattle',     'WA', 'USA', '98101'),
    (16, 1016, '2023-08-23 08:30:00', '2023-08-27 15:00:00', 'DHL',   'DHL1016001', 'Delivered', 22.99, '1555 Maple Ct',   'Chicago',     'IL', 'USA', '60603'),
    (17, 1017, '2023-09-06 09:00:00', '2023-09-10 11:00:00', 'FedEx', 'FDX1017001', 'Delivered', 15.99, '101 Oak St',      'Nashville',   'TN', 'USA', '37201'),
    (18, 1018, '2023-09-19 08:00:00', '2023-09-22 14:00:00', 'UPS',   'UPS1018001', 'Delivered', 10.99, '444 Fourth Ln',   'Atlanta',     'GA', 'USA', '30303'),
    (19, 1019, '2023-10-02 09:30:00', '2023-10-06 12:00:00', 'USPS',  'USP1019001', 'Delivered',  8.99, '888 Eighth Ave',  'Portland',    'OR', 'USA', '97202'),
    (20, 1020, '2023-10-16 08:00:00', '2023-10-20 13:00:00', 'FedEx', 'FDX1020001', 'Delivered', 19.99, '707 Walnut St',   'Chicago',     'IL', 'USA', '60601'),
    (21, 1021, '2023-11-11 09:00:00', '2023-11-14 14:00:00', 'UPS',   'UPS1021001', 'Delivered', 12.99, '1222 Elm Park',   'Los Angeles', 'CA', 'USA', '90003'),
    (22, 1022, '2023-11-25 08:30:00', '2023-11-29 11:00:00', 'DHL',   'DHL1022001', 'Delivered', 24.99, '303 Pine Rd',     'Austin',      'TX', 'USA', '73301'),
    (23, 1023, '2023-12-11 09:00:00', '2023-12-15 13:00:00', 'USPS',  'USP1023001', 'Delivered',  7.99, '222 Second Ave',  'Austin',      'TX', 'USA', '73302'),
    (24, 1024, '2023-12-23 08:00:00', '2023-12-26 14:00:00', 'UPS',   'UPS1024001', 'Delivered', 12.99, '505 Maple Dr',    'Nashville',   'TN', 'USA', '37203'),
    (25, 1025, '2024-01-09 09:30:00', '2024-01-13 11:00:00', 'FedEx', 'FDX1025001', 'Delivered', 19.99, '111 First St',    'Nashville',   'TN', 'USA', '37205'),
    (26, 1026, '2024-01-21 08:00:00', '2024-01-24 14:00:00', 'UPS',   'UPS1026001', 'Delivered', 10.99, '666 Sixth Way',   'Memphis',     'TN', 'USA', '38102'),
    (27, 1027, '2024-02-13 09:00:00', '2024-02-17 12:00:00', 'FedEx', 'FDX1027001', 'Delivered', 15.99, '404 Cedar Ln',    'Los Angeles', 'CA', 'USA', '90001'),
    (28, 1028, '2024-03-01 08:30:00', '2024-03-05 13:00:00', 'USPS',  'USP1028001', 'Delivered',  7.99, '999 Ninth Rd',    'Seattle',     'WA', 'USA', '98102'),
    (29, 1029, '2024-03-16 09:00:00', '2024-03-20 14:00:00', 'UPS',   'UPS1029001', 'Delivered', 12.99, '202 Elm Ave',     'Atlanta',     'GA', 'USA', '30301'),
    (30, 1030, '2024-03-31 08:00:00', '2024-04-04 11:00:00', 'FedEx', 'FDX1030001', 'Delivered', 12.99, '1111 Oak Hill',   'Nashville',   'TN', 'USA', '37207'),
    (31, 1031, '2024-04-11 09:30:00', '2024-04-15 13:00:00', 'DHL',   'DHL1031001', 'Delivered', 24.99, '909 Ash Blvd',    'Portland',    'OR', 'USA', '97201'),
    (32, 1032, '2024-04-26 08:00:00', '2024-04-30 14:00:00', 'USPS',  'USP1032001', 'Delivered',  8.99, '1333 Pine View',  'Atlanta',     'GA', 'USA', '30304'),
    (33, 1033, '2024-05-09 09:00:00', '2024-05-13 12:00:00', 'UPS',   'UPS1033001', 'Delivered', 10.99, '777 Seventh St',  'Chicago',     'IL', 'USA', '60602'),
    (34, 1034, '2024-05-23 08:30:00', '2024-05-27 13:00:00', 'FedEx', 'FDX1034001', 'Delivered', 15.99, '606 Birch Way',   'Atlanta',     'GA', 'USA', '30302'),
    (35, 1035, '2024-06-06 09:00:00', '2024-06-09 14:00:00', 'UPS',   'UPS1035001', 'Delivered', 10.99, '1444 Cedar Path', 'Memphis',     'TN', 'USA', '38103'),
    (36, 1036, '2024-06-19 08:00:00', '2024-06-23 11:00:00', 'DHL',   'DHL1036001', 'Delivered', 22.99, '333 Third Blvd',  'Los Angeles', 'CA', 'USA', '90002'),
    (37, 1037, '2024-07-03 09:30:00', '2024-07-07 13:00:00', 'FedEx', 'FDX1037001', 'Delivered', 12.99, '555 Fifth Dr',    'Nashville',   'TN', 'USA', '37206'),
    (38, 1038, '2024-07-21 08:00:00', '2024-07-25 14:00:00', 'USPS',  'USP1038001', 'Delivered',  8.99, '1010 Redwood Ct', 'Seattle',     'WA', 'USA', '98101'),
    (39, 1039, '2024-08-06 09:00:00', '2024-08-10 12:00:00', 'FedEx', 'FDX1039001', 'Delivered', 15.99, '1000 Tenth Ct',   'Austin',      'TX', 'USA', '73303'),
    (40, 1040, '2024-08-19 08:30:00', '2024-08-22 14:00:00', 'UPS',   'UPS1040001', 'Delivered', 10.99, '808 Spruce Ave',  'Memphis',     'TN', 'USA', '38101'),
    (41, 1041, '2024-09-02 09:00:00', '2024-09-06 13:00:00', 'DHL',   'DHL1041001', 'InTransit', 24.99, '1555 Maple Ct',   'Chicago',     'IL', 'USA', '60603'),
    (42, 1042, '2024-09-16 08:00:00', '2024-09-19 11:00:00', 'UPS',   'UPS1042001', 'InTransit', 12.99, '101 Oak St',      'Nashville',   'TN', 'USA', '37201'),
    (43, 1043, '2024-10-04 09:30:00', NULL,                   'FedEx', 'FDX1043001', 'Shipped',   15.99, '1222 Elm Park',   'Los Angeles', 'CA', 'USA', '90003'),
    (44, 1044, '2024-10-19 08:00:00', NULL,                   'UPS',   'UPS1044001', 'Shipped',   19.99, '707 Walnut St',   'Chicago',     'IL', 'USA', '60601'),
    (45, 1048, NULL,                  NULL,                   NULL,     NULL,         'Returned',   0.00, '111 First St',    'Nashville',   'TN', 'USA', '37205');
GO

PRINT 'All RAW tables populated with sample data successfully.';
GO
