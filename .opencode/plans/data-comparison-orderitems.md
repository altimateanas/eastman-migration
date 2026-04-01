# Data Comparison Plan: OrderItems Migration Validation

## Goal
Validate that `RetailDW.RAW.OrderItems` (MS SQL Server) was correctly migrated to `migration.raw.raw_order_items` (Microsoft Fabric).

---

## Context

| Property | Source (MS SQL) | Target (Fabric) |
|---|---|---|
| **Table** | `RetailDW.RAW.OrderItems` | `migration.raw.raw_order_items` |
| **Host** | `20.94.212.65:1433` | `*.datawarehouse.fabric.microsoft.com` |
| **Auth** | `sqladmin` / password | Azure CLI |
| **Rows** | ~100 | ~100 (loaded via dbt seed) |
| **Primary Key** | `OrderItemID` | `OrderItemID` |

### Column Mapping (7 shared columns)

| Source Column | Target Column | Type (Source) | Notes |
|---|---|---|---|
| `OrderItemID` | `OrderItemID` | INT | PK |
| `OrderID` | `OrderID` | INT | FK |
| `ProductID` | `ProductID` | INT | FK |
| `Quantity` | `Quantity` | INT | |
| `UnitPrice` | `UnitPrice` | DECIMAL(18,2) | |
| `Discount` | `Discount` | DECIMAL(5,2) | |
| `LineTotal` | `LineTotal` | Computed/PERSISTED | Pre-calculated in seed CSV |

### Excluded Columns (intentionally dropped during migration)
- `CreatedDate` (DATETIME2, DEFAULT GETDATE())
- `ModifiedDate` (DATETIME2, DEFAULT GETDATE())

---

## Steps

### Step 1: Add Source SQL Server Warehouse Connection

Add a new warehouse connection `eastman_sqlserver` pointing to the source MS SQL VM:

```
name: eastman_sqlserver
config:
  type: sqlserver
  host: 20.94.212.65
  port: 1433
  database: RetailDW
  user: sqladmin
  password: <from .vscode/settings.json>
  encrypt: true
  trust_server_certificate: true
```

### Step 2: Verify Both Connections

Test connectivity to both warehouses:
- `eastman_sqlserver` (source MS SQL)
- `eastman_migration_dev` (target Fabric)

If the `mssql` driver is not installed, install it via `npm install mssql` in the altimate-code packages/opencode directory. Both connections use the SQL Server wire protocol so both need this driver.

### Step 3: Profile Comparison (Column-Level Statistics)

Run the `data_diff` tool with `algorithm: profile` to compare column-level statistics without doing a full row-by-row diff:

```
source: "RAW.OrderItems"
target: "raw.raw_order_items"
key_columns: ["OrderItemID"]
source_warehouse: "eastman_sqlserver"
target_warehouse: "eastman_migration_dev"
algorithm: "profile"
extra_columns: ["OrderID", "ProductID", "Quantity", "UnitPrice", "Discount", "LineTotal"]
```

This will show per-column: count, null count, min, max, distinct values -- giving a quick high-level view of whether the data landed correctly.

### Step 4: Row-Level Diff (HashDiff)

Run the `data_diff` tool with `algorithm: hashdiff` for exact row-by-row comparison across the two databases:

```
source: "RAW.OrderItems"
target: "raw.raw_order_items"
key_columns: ["OrderItemID"]
source_warehouse: "eastman_sqlserver"
target_warehouse: "eastman_migration_dev"
algorithm: "hashdiff"
extra_columns: ["OrderID", "ProductID", "Quantity", "UnitPrice", "Discount", "LineTotal"]
numeric_tolerance: 0.01
```

This will identify:
- **Missing rows**: present in source but not in target (or vice versa)
- **Modified rows**: same key but different values in one or more columns
- **Identical rows**: confirmed matches

A `numeric_tolerance` of 0.01 accounts for any minor floating-point rounding in `LineTotal` between the computed column and the seed CSV.

### Step 5: Review Results and Report

Analyze the diff output:
- If **IDENTICAL**: migration is validated
- If **DIFFER**: examine sample differences to determine root cause (type casting, rounding, missing rows, etc.)

---

## Risks / Notes

- **LineTotal precision**: SQL Server computes `LineTotal` as a persisted expression (`Quantity * UnitPrice * (1 - Discount / 100)`). The seed CSV contains pre-computed values with 6 decimal places (e.g. `999.990000`). Minor rounding differences are possible -- hence the `numeric_tolerance: 0.01`.
- **Driver dependency**: Both connections (SQL Server and Fabric DW) use the TDS protocol and require the `mssql` npm package.
- **Fabric auth**: The `eastman_migration_dev` connection uses Azure CLI authentication. Ensure `az login` has been run and the token is current.
- **Cross-database algorithm**: Since source and target are on different servers, `hashdiff` (bisection with checksums) is the correct algorithm. `joindiff` would not work across databases.
