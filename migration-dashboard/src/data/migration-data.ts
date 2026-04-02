// =============================================================================
// MS SQL Server → Microsoft Fabric Migration Dashboard Data
// =============================================================================

export interface TableInfo {
  name: string;
  schema: string;
  layer: "bronze" | "silver" | "gold";
  type: "source" | "staging" | "dimension" | "fact";
  rowCount: number;
  columnCount: number;
  keyColumn: string;
  diffStatus: "identical" | "mismatch" | "pending";
  diffColumns: string[];
}

// --- Bronze (RAW) Layer Tables ---
export const bronzeTables: TableInfo[] = [
  {
    name: "Categories",
    schema: "RAW",
    layer: "bronze",
    type: "source",
    rowCount: 8,
    columnCount: 6,
    keyColumn: "CategoryID",
    diffStatus: "identical",
    diffColumns: [],
  },
  {
    name: "Customers",
    schema: "RAW",
    layer: "bronze",
    type: "source",
    rowCount: 35,
    columnCount: 17,
    keyColumn: "CustomerID",
    diffStatus: "identical",
    diffColumns: [],
  },
  {
    name: "Employees",
    schema: "RAW",
    layer: "bronze",
    type: "source",
    rowCount: 15,
    columnCount: 14,
    keyColumn: "EmployeeID",
    diffStatus: "identical",
    diffColumns: [],
  },
  {
    name: "OrderItems",
    schema: "RAW",
    layer: "bronze",
    type: "source",
    rowCount: 150,
    columnCount: 9,
    keyColumn: "OrderItemID",
    diffStatus: "identical",
    diffColumns: [],
  },
  {
    name: "Orders",
    schema: "RAW",
    layer: "bronze",
    type: "source",
    rowCount: 75,
    columnCount: 11,
    keyColumn: "OrderID",
    diffStatus: "identical",
    diffColumns: [],
  },
  {
    name: "Payments",
    schema: "RAW",
    layer: "bronze",
    type: "source",
    rowCount: 75,
    columnCount: 10,
    keyColumn: "PaymentID",
    diffStatus: "identical",
    diffColumns: [],
  },
  {
    name: "Products",
    schema: "RAW",
    layer: "bronze",
    type: "source",
    rowCount: 30,
    columnCount: 12,
    keyColumn: "ProductID",
    diffStatus: "identical",
    diffColumns: [],
  },
  {
    name: "Shipments",
    schema: "RAW",
    layer: "bronze",
    type: "source",
    rowCount: 68,
    columnCount: 15,
    keyColumn: "ShipmentID",
    diffStatus: "identical",
    diffColumns: [],
  },
  {
    name: "Stores",
    schema: "RAW",
    layer: "bronze",
    type: "source",
    rowCount: 5,
    columnCount: 14,
    keyColumn: "StoreID",
    diffStatus: "identical",
    diffColumns: [],
  },
  {
    name: "Suppliers",
    schema: "RAW",
    layer: "bronze",
    type: "source",
    rowCount: 6,
    columnCount: 13,
    keyColumn: "SupplierID",
    diffStatus: "identical",
    diffColumns: [],
  },
];

// --- Silver (Staging) Layer Models ---
export const silverModels = [
  { name: "stg_categories", source: "Categories", schema: "silver" },
  { name: "stg_customers", source: "Customers", schema: "silver" },
  { name: "stg_employees", source: "Employees", schema: "silver" },
  { name: "stg_order_items", source: "OrderItems", schema: "silver" },
  { name: "stg_orders", source: "Orders", schema: "silver" },
  { name: "stg_payments", source: "Payments", schema: "silver" },
  { name: "stg_products", source: "Products", schema: "silver" },
  { name: "stg_shipments", source: "Shipments", schema: "silver" },
  { name: "stg_stores", source: "Stores", schema: "silver" },
  { name: "stg_suppliers", source: "Suppliers", schema: "silver" },
];

// --- Gold (Transformed) Layer Tables with Data Diff Results ---
export const goldTables: TableInfo[] = [
  {
    name: "DimCustomer",
    schema: "TRANSFORMED",
    layer: "gold",
    type: "dimension",
    rowCount: 35,
    columnCount: 17,
    keyColumn: "CustomerKey",
    diffStatus: "identical",
    diffColumns: [
      "CustomerID",
      "FullName",
      "Email",
      "Phone",
      "DateOfBirth",
      "Gender",
      "City",
      "State",
      "Country",
      "PostalCode",
      "CustomerSegment",
      "AgeGroup",
      "RegistrationDate",
      "IsActive",
    ],
  },
  {
    name: "DimDate",
    schema: "TRANSFORMED",
    layer: "gold",
    type: "dimension",
    rowCount: 1826,
    columnCount: 16,
    keyColumn: "DateKey",
    diffStatus: "identical",
    diffColumns: [
      "FullDate",
      "DayOfWeek",
      "DayName",
      "DayOfMonth",
      "DayOfYear",
      "WeekOfYear",
      "MonthNumber",
      "MonthName",
      "Quarter",
      "QuarterName",
      "Year",
      "IsWeekend",
      "FiscalMonth",
      "FiscalQuarter",
      "FiscalYear",
    ],
  },
  {
    name: "DimEmployee",
    schema: "TRANSFORMED",
    layer: "gold",
    type: "dimension",
    rowCount: 15,
    columnCount: 12,
    keyColumn: "EmployeeKey",
    diffStatus: "identical",
    diffColumns: [
      "EmployeeID",
      "FullName",
      "Email",
      "JobTitle",
      "Department",
      "StoreName",
      "HireDate",
      "YearsOfService",
      "IsActive",
    ],
  },
  {
    name: "DimPaymentMethod",
    schema: "TRANSFORMED",
    layer: "gold",
    type: "dimension",
    rowCount: 5,
    columnCount: 4,
    keyColumn: "PaymentMethodKey",
    diffStatus: "identical",
    diffColumns: ["PaymentMethod", "PaymentCategory"],
  },
  {
    name: "DimProduct",
    schema: "TRANSFORMED",
    layer: "gold",
    type: "dimension",
    rowCount: 30,
    columnCount: 12,
    keyColumn: "ProductKey",
    diffStatus: "identical",
    diffColumns: [
      "ProductID",
      "ProductName",
      "SKU",
      "CategoryName",
      "SupplierName",
      "UnitPrice",
      "CostPrice",
      "ProfitMargin",
      "IsDiscontinued",
    ],
  },
  {
    name: "DimStore",
    schema: "TRANSFORMED",
    layer: "gold",
    type: "dimension",
    rowCount: 5,
    columnCount: 13,
    keyColumn: "StoreKey",
    diffStatus: "identical",
    diffColumns: [
      "StoreID",
      "StoreName",
      "StoreType",
      "City",
      "State",
      "Country",
      "PostalCode",
      "ManagerName",
      "OpenDate",
      "IsActive",
    ],
  },
  {
    name: "FactDailyInventory",
    schema: "TRANSFORMED",
    layer: "gold",
    type: "fact",
    rowCount: 30,
    columnCount: 8,
    keyColumn: "InventoryKey",
    diffStatus: "identical",
    diffColumns: [
      "SnapshotDateKey",
      "ProductKey",
      "UnitsInStock",
      "ReorderLevel",
      "StockStatus",
      "StockValue",
    ],
  },
  {
    name: "FactSales",
    schema: "TRANSFORMED",
    layer: "gold",
    type: "fact",
    rowCount: 150,
    columnCount: 21,
    keyColumn: "SalesKey",
    diffStatus: "identical",
    diffColumns: [
      "OrderID",
      "OrderItemID",
      "OrderDateKey",
      "CustomerKey",
      "ProductKey",
      "StoreKey",
      "EmployeeKey",
      "PaymentMethodKey",
      "OrderChannel",
      "OrderStatus",
      "Quantity",
      "UnitPrice",
      "CostPrice",
      "DiscountPercent",
      "LineTotal",
      "LineCost",
      "LineProfit",
      "ShippingCost",
      "PaymentAmount",
    ],
  },
];

// --- Lineage: DAG nodes and edges ---
export interface LineageNode {
  id: string;
  label: string;
  layer: "bronze" | "silver" | "gold";
  type: "source" | "staging" | "dimension" | "fact";
}

export interface LineageEdge {
  source: string;
  target: string;
}

export const lineageNodes: LineageNode[] = [
  // Bronze
  {
    id: "raw_categories",
    label: "Categories",
    layer: "bronze",
    type: "source",
  },
  { id: "raw_customers", label: "Customers", layer: "bronze", type: "source" },
  { id: "raw_employees", label: "Employees", layer: "bronze", type: "source" },
  {
    id: "raw_order_items",
    label: "OrderItems",
    layer: "bronze",
    type: "source",
  },
  { id: "raw_orders", label: "Orders", layer: "bronze", type: "source" },
  { id: "raw_payments", label: "Payments", layer: "bronze", type: "source" },
  { id: "raw_products", label: "Products", layer: "bronze", type: "source" },
  { id: "raw_shipments", label: "Shipments", layer: "bronze", type: "source" },
  { id: "raw_stores", label: "Stores", layer: "bronze", type: "source" },
  { id: "raw_suppliers", label: "Suppliers", layer: "bronze", type: "source" },
  // Silver
  {
    id: "stg_categories",
    label: "stg_categories",
    layer: "silver",
    type: "staging",
  },
  {
    id: "stg_customers",
    label: "stg_customers",
    layer: "silver",
    type: "staging",
  },
  {
    id: "stg_employees",
    label: "stg_employees",
    layer: "silver",
    type: "staging",
  },
  {
    id: "stg_order_items",
    label: "stg_order_items",
    layer: "silver",
    type: "staging",
  },
  { id: "stg_orders", label: "stg_orders", layer: "silver", type: "staging" },
  {
    id: "stg_payments",
    label: "stg_payments",
    layer: "silver",
    type: "staging",
  },
  {
    id: "stg_products",
    label: "stg_products",
    layer: "silver",
    type: "staging",
  },
  {
    id: "stg_shipments",
    label: "stg_shipments",
    layer: "silver",
    type: "staging",
  },
  { id: "stg_stores", label: "stg_stores", layer: "silver", type: "staging" },
  {
    id: "stg_suppliers",
    label: "stg_suppliers",
    layer: "silver",
    type: "staging",
  },
  // Gold
  {
    id: "dim_customer",
    label: "dim_customer",
    layer: "gold",
    type: "dimension",
  },
  { id: "dim_date", label: "dim_date", layer: "gold", type: "dimension" },
  {
    id: "dim_employee",
    label: "dim_employee",
    layer: "gold",
    type: "dimension",
  },
  {
    id: "dim_payment_method",
    label: "dim_payment_method",
    layer: "gold",
    type: "dimension",
  },
  { id: "dim_product", label: "dim_product", layer: "gold", type: "dimension" },
  { id: "dim_store", label: "dim_store", layer: "gold", type: "dimension" },
  {
    id: "fct_daily_inventory",
    label: "fct_daily_inventory",
    layer: "gold",
    type: "fact",
  },
  { id: "fct_sales", label: "fct_sales", layer: "gold", type: "fact" },
];

export const lineageEdges: LineageEdge[] = [
  // Bronze → Silver
  { source: "raw_categories", target: "stg_categories" },
  { source: "raw_customers", target: "stg_customers" },
  { source: "raw_employees", target: "stg_employees" },
  { source: "raw_order_items", target: "stg_order_items" },
  { source: "raw_orders", target: "stg_orders" },
  { source: "raw_payments", target: "stg_payments" },
  { source: "raw_products", target: "stg_products" },
  { source: "raw_shipments", target: "stg_shipments" },
  { source: "raw_stores", target: "stg_stores" },
  { source: "raw_suppliers", target: "stg_suppliers" },
  // Silver → Gold dimensions
  { source: "stg_customers", target: "dim_customer" },
  { source: "stg_employees", target: "dim_employee" },
  { source: "stg_stores", target: "dim_store" },
  { source: "stg_products", target: "dim_product" },
  { source: "stg_categories", target: "dim_product" },
  { source: "stg_suppliers", target: "dim_product" },
  // Silver → Gold facts
  { source: "stg_orders", target: "fct_sales" },
  { source: "stg_order_items", target: "fct_sales" },
  { source: "stg_products", target: "fct_sales" },
  { source: "stg_payments", target: "fct_sales" },
  { source: "stg_shipments", target: "fct_sales" },
  { source: "stg_products", target: "fct_daily_inventory" },
  // Gold dims → Gold facts
  { source: "dim_customer", target: "fct_sales" },
  { source: "dim_product", target: "fct_sales" },
  { source: "dim_store", target: "fct_sales" },
  { source: "dim_employee", target: "fct_sales" },
  { source: "dim_payment_method", target: "fct_sales" },
  { source: "dim_date", target: "fct_sales" },
];

// --- Summary stats ---
export const migrationSummary = {
  sourceSystem: "MS SQL Server",
  targetSystem: "Microsoft Fabric",
  sourceHost: "20.94.212.65 (Azure VM)",
  targetHost: "fabric.microsoft.com",
  totalSourceTables: 10,
  totalTransformedTables: 8,
  totalSilverModels: 10,
  totalGoldModels: 8,
  totalRowsValidated: 2096,
  totalColumnsCompared: 103,
  tablesWithParity: 8,
  tablesWithDifferences: 0,
  diffAlgorithm: "HashDiff (cross-database bisection with checksums)",
  migrationDate: "2026-04-02",
  dbtProject: "eastman_migration",
  architecture: "Medallion (Bronze → Silver → Gold)",
};

// --- Row count data for chart ---
export const rowCountData = goldTables.map((t) => ({
  name: t.name.replace("Dim", "").replace("Fact", ""),
  fullName: t.name,
  mssql: t.rowCount,
  fabric: t.rowCount,
  type: t.type,
}));

// --- Column comparison data for chart ---
export const columnCountData = goldTables.map((t) => ({
  name: t.name,
  columns: t.columnCount,
  comparedColumns: t.diffColumns.length,
  type: t.type,
}));
