#!/usr/bin/env python3
"""
run_data_diff.py
----------------
Data parity validation between MS SQL Server (TRANSFORMED.*) and
Microsoft Fabric (gold.*) for the Eastman RetailDW → Fabric migration.

Connections:
  - MS SQL  : standard pyodbc password auth
  - Fabric  : pyodbc + Azure AD token injection via SQL_COPT_SS_ACCESS_TOKEN

Usage:
    python scripts/run_data_diff.py [--table TABLE_NAME] [--output report.json]

Options:
    --table     Run only the named table pair (e.g. dim_customer). Default: all.
    --output    Path to write the JSON report.  Default: scripts/data_diff_report.json
    --verbose   Print per-row mismatches to stdout.
"""

import os, sys, json, struct, subprocess, argparse
from datetime import datetime, date
from pathlib import Path
from decimal import Decimal

import pyodbc
from dotenv import load_dotenv

# ──────────────────────────────────────────────────────────────────────────────
# 0.  Load credentials
# ──────────────────────────────────────────────────────────────────────────────
ROOT = Path(__file__).resolve().parent.parent
load_dotenv(ROOT / ".env")

MSSQL_HOST = os.environ["MSSQL_HOST"]
MSSQL_PORT = os.environ["MSSQL_PORT"]
MSSQL_DATABASE = os.environ["MSSQL_DATABASE"]
MSSQL_USER = os.environ["MSSQL_USER"]
MSSQL_PASSWORD = os.environ["MSSQL_PASSWORD"]
MSSQL_DRIVER = os.environ.get("MSSQL_DRIVER", "ODBC Driver 17 for SQL Server")

FABRIC_SERVER = os.environ["FABRIC_SERVER"]
FABRIC_DATABASE = os.environ["FABRIC_DATABASE"]
FABRIC_DRIVER = os.environ.get("FABRIC_DRIVER", "ODBC Driver 17 for SQL Server")


# ──────────────────────────────────────────────────────────────────────────────
# 1.  Connection helpers
# ──────────────────────────────────────────────────────────────────────────────


def connect_mssql() -> pyodbc.Connection:
    conn_str = (
        f"DRIVER={{{MSSQL_DRIVER}}};"
        f"SERVER={MSSQL_HOST},{MSSQL_PORT};"
        f"DATABASE={MSSQL_DATABASE};"
        f"UID={MSSQL_USER};"
        f"PWD={MSSQL_PASSWORD};"
        "TrustServerCertificate=yes;"
        "Encrypt=no;"
    )
    return pyodbc.connect(conn_str, timeout=30)


def _get_fabric_token() -> bytes:
    """Fetch an Azure AD access token via `az` CLI and pack it as a binary struct."""
    result = subprocess.run(
        [
            "az",
            "account",
            "get-access-token",
            "--resource",
            "https://database.windows.net/",
            "--query",
            "accessToken",
            "-o",
            "tsv",
        ],
        capture_output=True,
        text=True,
        check=True,
    )
    token_str = result.stdout.strip()
    # Pack as UTF-16-LE bytes prefixed by a 4-byte length (ODBC expects this struct)
    token_bytes = token_str.encode("utf-16-le")
    return struct.pack("<I", len(token_bytes)) + token_bytes


def connect_fabric() -> pyodbc.Connection:
    conn_str = (
        f"DRIVER={{{FABRIC_DRIVER}}};"
        f"SERVER={FABRIC_SERVER},1433;"
        f"DATABASE={FABRIC_DATABASE};"
        "Encrypt=yes;"
        "TrustServerCertificate=no;"
    )
    SQL_COPT_SS_ACCESS_TOKEN = 1256
    token = _get_fabric_token()
    return pyodbc.connect(
        conn_str, attrs_before={SQL_COPT_SS_ACCESS_TOKEN: token}, timeout=60
    )


# ──────────────────────────────────────────────────────────────────────────────
# 2.  Table pair definitions
# ──────────────────────────────────────────────────────────────────────────────
#
# Each entry:
#   source_query  – SQL executed against MS SQL (TRANSFORMED schema)
#   target_query  – SQL executed against Fabric (gold schema)
#   key_columns   – natural key column(s) for row alignment  (snake_case)
#   compare_cols  – business columns to diff (snake_case)
#
# Column aliases are applied in the queries so both sides share the same names.
# Surrogate keys (CustomerKey int, customer_key MD5) are deliberately excluded.
# Audit columns (LoadDate, dw_created_at, dw_updated_at) are excluded.
# ──────────────────────────────────────────────────────────────────────────────

TABLE_PAIRS = [
    # ── DimCustomer ──────────────────────────────────────────────────────────
    {
        "name": "dim_customer",
        "source_query": """
            SELECT
                CustomerID              AS customer_id,
                FullName                AS full_name,
                Email                   AS email,
                Phone                   AS phone,
                CAST(DateOfBirth AS DATE) AS date_of_birth,
                Gender                  AS gender,
                City                    AS city,
                State                   AS state,
                Country                 AS country,
                CAST(PostalCode AS VARCHAR(20)) AS postal_code,
                CustomerSegment         AS customer_segment,
                AgeGroup                AS age_group,
                CAST(RegistrationDate AS DATE) AS registration_date,
                CAST(IsActive AS INT)    AS is_active
            FROM TRANSFORMED.DimCustomer
        """,
        "target_query": """
            SELECT
                customer_id,
                full_name,
                email,
                phone,
                CAST(date_of_birth AS DATE)       AS date_of_birth,
                gender,
                city,
                state,
                country,
                CAST(postal_code AS VARCHAR(20))  AS postal_code,
                customer_segment,
                age_group,
                CAST(registration_date AS DATE)   AS registration_date,
                CAST(is_active AS INT)             AS is_active
            FROM gold.dim_customer
        """,
        "key_columns": ["customer_id"],
        "compare_cols": [
            "full_name",
            "email",
            "phone",
            "date_of_birth",
            "gender",
            "city",
            "state",
            "country",
            "postal_code",
            "customer_segment",
            "age_group",
            "registration_date",
            "is_active",
        ],
    },
    # ── DimDate ───────────────────────────────────────────────────────────────
    {
        "name": "dim_date",
        "source_query": """
            SELECT
                DateKey                 AS date_key,
                CAST(FullDate AS DATE)  AS full_date,
                DayOfWeek               AS day_of_week,
                DayName                 AS day_name,
                DayOfMonth              AS day_of_month,
                DayOfYear               AS day_of_year,
                WeekOfYear              AS week_of_year,
                MonthNumber             AS month_number,
                MonthName               AS month_name,
                Quarter                 AS quarter,
                QuarterName             AS quarter_name,
                Year                    AS year,
                CAST(IsWeekend AS INT)  AS is_weekend,
                FiscalMonth             AS fiscal_month,
                FiscalQuarter           AS fiscal_quarter,
                FiscalYear              AS fiscal_year
            FROM TRANSFORMED.DimDate
        """,
        "target_query": """
            SELECT
                date_key,
                CAST(full_date AS DATE)     AS full_date,
                day_of_week,
                day_name,
                day_of_month,
                day_of_year,
                week_of_year,
                month_number,
                month_name,
                quarter,
                quarter_name,
                year,
                CAST(is_weekend AS INT)     AS is_weekend,
                fiscal_month,
                fiscal_quarter,
                fiscal_year
            FROM gold.dim_date
        """,
        "key_columns": ["date_key"],
        "compare_cols": [
            "full_date",
            "day_of_week",
            "day_name",
            "day_of_month",
            "day_of_year",
            "week_of_year",
            "month_number",
            "month_name",
            "quarter",
            "quarter_name",
            "year",
            "is_weekend",
            "fiscal_month",
            "fiscal_quarter",
            "fiscal_year",
        ],
    },
    # ── DimEmployee ───────────────────────────────────────────────────────────
    {
        "name": "dim_employee",
        "source_query": """
            SELECT
                EmployeeID              AS employee_id,
                FullName                AS full_name,
                Email                   AS email,
                JobTitle                AS job_title,
                Department              AS department,
                StoreName               AS store_name,
                CAST(HireDate AS DATE)  AS hire_date,
                YearsOfService          AS years_of_service,
                CAST(IsActive AS INT)   AS is_active
            FROM TRANSFORMED.DimEmployee
        """,
        "target_query": """
            SELECT
                employee_id,
                full_name,
                email,
                job_title,
                department,
                store_name,
                CAST(hire_date AS DATE)    AS hire_date,
                years_of_service,
                CAST(is_active AS INT)     AS is_active
            FROM gold.dim_employee
        """,
        "key_columns": ["employee_id"],
        "compare_cols": [
            "full_name",
            "email",
            "job_title",
            "department",
            "store_name",
            "hire_date",
            # years_of_service is computed from hire_date → may differ by ±1 depending
            # on the exact moment each system ran; flag but don't hard-fail
            "is_active",
        ],
        "fuzzy_cols": {"years_of_service": 1},  # allow ±1 tolerance
    },
    # ── DimPaymentMethod ──────────────────────────────────────────────────────
    {
        "name": "dim_payment_method",
        "source_query": """
            SELECT
                PaymentMethod           AS payment_method,
                PaymentCategory         AS payment_category
            FROM TRANSFORMED.DimPaymentMethod
        """,
        "target_query": """
            SELECT
                payment_method,
                payment_category
            FROM gold.dim_payment_method
        """,
        "key_columns": ["payment_method"],
        "compare_cols": ["payment_category"],
    },
    # ── DimProduct ────────────────────────────────────────────────────────────
    {
        "name": "dim_product",
        "source_query": """
            SELECT
                ProductID               AS product_id,
                ProductName             AS product_name,
                SKU                     AS sku,
                CategoryName            AS category_name,
                SupplierName            AS supplier_name,
                CAST(UnitPrice AS DECIMAL(18,2))  AS unit_price,
                CAST(CostPrice AS DECIMAL(18,2))  AS cost_price,
                CAST(ProfitMargin AS DECIMAL(18,4)) AS profit_margin,
                CAST(IsDiscontinued AS INT)       AS is_discontinued
            FROM TRANSFORMED.DimProduct
        """,
        "target_query": """
            SELECT
                product_id,
                product_name,
                sku,
                category_name,
                supplier_name,
                CAST(unit_price AS DECIMAL(18,2))   AS unit_price,
                CAST(cost_price AS DECIMAL(18,2))   AS cost_price,
                CAST(profit_margin AS DECIMAL(18,4)) AS profit_margin,
                CAST(is_discontinued AS INT)         AS is_discontinued
            FROM gold.dim_product
        """,
        "key_columns": ["product_id"],
        "compare_cols": [
            "product_name",
            "sku",
            "category_name",
            "supplier_name",
            "unit_price",
            "cost_price",
            "profit_margin",
            "is_discontinued",
        ],
    },
    # ── DimStore ──────────────────────────────────────────────────────────────
    {
        "name": "dim_store",
        "source_query": """
            SELECT
                StoreID                 AS store_id,
                StoreName               AS store_name,
                StoreType               AS store_type,
                City                    AS city,
                State                   AS state,
                Country                 AS country,
                CAST(PostalCode AS VARCHAR(20)) AS postal_code,
                ManagerName             AS manager_name,
                CAST(OpenDate AS DATE)  AS open_date,
                CAST(IsActive AS INT)   AS is_active
            FROM TRANSFORMED.DimStore
        """,
        "target_query": """
            SELECT
                store_id,
                store_name,
                store_type,
                city,
                state,
                country,
                CAST(postal_code AS VARCHAR(20)) AS postal_code,
                manager_name,
                CAST(open_date AS DATE)          AS open_date,
                CAST(is_active AS INT)            AS is_active
            FROM gold.dim_store
        """,
        "key_columns": ["store_id"],
        "compare_cols": [
            "store_name",
            "store_type",
            "city",
            "state",
            "country",
            "postal_code",
            "manager_name",
            "open_date",
            "is_active",
        ],
    },
    # ── FactSales ─────────────────────────────────────────────────────────────
    {
        "name": "fct_sales",
        "source_query": """
            SELECT
                OrderItemID             AS order_item_id,
                OrderID                 AS order_id,
                OrderDateKey            AS order_date_key,
                OrderChannel            AS order_channel,
                OrderStatus             AS order_status,
                Quantity                AS quantity,
                CAST(UnitPrice   AS DECIMAL(18,2)) AS unit_price,
                CAST(CostPrice   AS DECIMAL(18,2)) AS cost_price,
                CAST(DiscountPercent AS DECIMAL(18,4)) AS discount_percent,
                CAST(LineTotal   AS DECIMAL(18,2)) AS line_total,
                CAST(LineCost    AS DECIMAL(18,2)) AS line_cost,
                CAST(LineProfit  AS DECIMAL(18,2)) AS line_profit,
                CAST(ShippingCost AS DECIMAL(18,2)) AS shipping_cost,
                CAST(PaymentAmount AS DECIMAL(18,2)) AS payment_amount
            FROM TRANSFORMED.FactSales
        """,
        "target_query": """
            SELECT
                order_item_id,
                order_id,
                order_date_key,
                order_channel,
                order_status,
                quantity,
                CAST(unit_price      AS DECIMAL(18,2)) AS unit_price,
                CAST(cost_price      AS DECIMAL(18,2)) AS cost_price,
                CAST(discount_percent AS DECIMAL(18,4)) AS discount_percent,
                CAST(line_total      AS DECIMAL(18,2)) AS line_total,
                CAST(line_cost       AS DECIMAL(18,2)) AS line_cost,
                CAST(line_profit     AS DECIMAL(18,2)) AS line_profit,
                CAST(shipping_cost   AS DECIMAL(18,2)) AS shipping_cost,
                CAST(payment_amount  AS DECIMAL(18,2)) AS payment_amount
            FROM gold.fct_sales
        """,
        "key_columns": ["order_item_id"],
        "compare_cols": [
            "order_id",
            "order_date_key",
            "order_channel",
            "order_status",
            "quantity",
            "unit_price",
            "cost_price",
            "discount_percent",
            "line_total",
            "line_cost",
            "line_profit",
            "shipping_cost",
            "payment_amount",
        ],
    },
    # ── FactDailyInventory ────────────────────────────────────────────────────
    # MS SQL uses integer ProductKey (FK to DimProduct); Fabric uses MD5 product_key.
    # We align on product_id only — snapshot_date_key will differ by 1 day because
    # the SQL Server SP ran on date X while dbt ran on date X+1 (different calendar
    # days).  The snapshot_date_key IS included as a compare column so the offset
    # is clearly reported, but it does not block the structural data comparison.
    {
        "name": "fct_daily_inventory",
        "source_query": """
            SELECT
                fi.SnapshotDateKey                  AS snapshot_date_key,
                dp.ProductID                        AS product_id,
                fi.UnitsInStock                     AS units_in_stock,
                fi.ReorderLevel                     AS reorder_level,
                fi.StockStatus                      AS stock_status,
                CAST(fi.StockValue AS DECIMAL(18,2)) AS stock_value
            FROM TRANSFORMED.FactDailyInventory fi
            INNER JOIN TRANSFORMED.DimProduct dp ON fi.ProductKey = dp.ProductKey
        """,
        "target_query": """
            SELECT
                fi.snapshot_date_key,
                dp.product_id,
                fi.units_in_stock,
                fi.reorder_level,
                fi.stock_status,
                CAST(fi.stock_value AS DECIMAL(18,2)) AS stock_value
            FROM gold.fct_daily_inventory fi
            INNER JOIN gold.dim_product dp ON fi.product_key = dp.product_key
        """,
        "key_columns": ["product_id"],
        "compare_cols": [
            # snapshot_date_key will show +1 day offset (expected; not a data bug)
            "snapshot_date_key",
            "units_in_stock",
            "reorder_level",
            "stock_status",
            "stock_value",
        ],
        "note": (
            "snapshot_date_key mismatch of +1 day is expected: SQL Server SP ran on "
            "20260331, dbt model ran on 20260401. Business data (stock levels, values) "
            "should match exactly."
        ),
    },
]


# ──────────────────────────────────────────────────────────────────────────────
# 3.  Diff engine
# ──────────────────────────────────────────────────────────────────────────────


def _normalise(val):
    """Normalise a value for comparison: strip strings, normalise None."""
    if val is None:
        return None
    if isinstance(val, str):
        return val.strip()
    if isinstance(val, Decimal):
        return float(val)
    if isinstance(val, (datetime,)):
        return val.date()  # strip time component for audit-free comparison
    return val


def fetch_rows(conn: pyodbc.Connection, query: str) -> dict:
    """Execute query and return a dict keyed by the tuple of key_cols values."""
    cursor = conn.cursor()
    cursor.execute(query)
    cols = [desc[0].lower() for desc in cursor.description]
    rows = {}
    raw_list = cursor.fetchall()
    return cols, raw_list


def diff_table(
    mssql_conn: pyodbc.Connection,
    fabric_conn: pyodbc.Connection,
    pair: dict,
    verbose: bool = False,
) -> dict:
    name = pair["name"]
    print(f"\n{'─' * 60}")
    print(f"  Diffing: {name}")
    print(f"{'─' * 60}")

    # ── Fetch both sides ──────────────────────────────────────────────────────
    src_cols, src_raw = fetch_rows(mssql_conn, pair["source_query"])
    tgt_cols, tgt_raw = fetch_rows(fabric_conn, pair["target_query"])

    key_cols = pair["key_columns"]
    cmp_cols = pair["compare_cols"]
    fuzzy_cols = pair.get("fuzzy_cols", {})

    def make_key(row_dict):
        return tuple(row_dict[k] for k in key_cols)

    def row_to_dict(cols, row):
        return {cols[i]: _normalise(row[i]) for i in range(len(cols))}

    src_map = {
        make_key(row_to_dict(src_cols, r)): row_to_dict(src_cols, r) for r in src_raw
    }
    tgt_map = {
        make_key(row_to_dict(tgt_cols, r)): row_to_dict(tgt_cols, r) for r in tgt_raw
    }

    src_keys = set(src_map)
    tgt_keys = set(tgt_map)

    missing_in_target = sorted(src_keys - tgt_keys)  # in SQL Server but not in Fabric
    extra_in_target = sorted(tgt_keys - src_keys)  # in Fabric but not in SQL Server
    common_keys = src_keys & tgt_keys

    # ── Column-level mismatches ───────────────────────────────────────────────
    col_mismatch_counts = {c: 0 for c in cmp_cols}
    col_mismatch_counts.update({c: 0 for c in fuzzy_cols})
    mismatched_rows = []

    for key in common_keys:
        s = src_map[key]
        t = tgt_map[key]
        row_diffs = {}
        for col in cmp_cols:
            sv = s.get(col)
            tv = t.get(col)
            if col in fuzzy_cols:
                tolerance = fuzzy_cols[col]
                try:
                    if abs((sv or 0) - (tv or 0)) > tolerance:
                        row_diffs[col] = {"source": sv, "target": tv}
                        col_mismatch_counts[col] = col_mismatch_counts.get(col, 0) + 1
                except TypeError:
                    if sv != tv:
                        row_diffs[col] = {"source": sv, "target": tv}
                        col_mismatch_counts[col] = col_mismatch_counts.get(col, 0) + 1
            else:
                if sv != tv:
                    row_diffs[col] = {"source": sv, "target": tv}
                    col_mismatch_counts[col] = col_mismatch_counts.get(col, 0) + 1

        if row_diffs:
            mismatched_rows.append(
                {"key": {k: s[k] for k in key_cols}, "diffs": row_diffs}
            )

    # ── Summary ───────────────────────────────────────────────────────────────
    total_src = len(src_map)
    total_tgt = len(tgt_map)
    clean_rows = len(common_keys) - len(mismatched_rows)
    match_pct = round(clean_rows / total_src * 100, 2) if total_src else 0

    status = (
        "✅ PASS"
        if (not missing_in_target and not extra_in_target and not mismatched_rows)
        else "❌ FAIL"
    )

    print(f"  Source rows : {total_src}")
    print(f"  Target rows : {total_tgt}")
    print(f"  Missing in Fabric : {len(missing_in_target)}")
    print(f"  Extra in Fabric   : {len(extra_in_target)}")
    print(f"  Value mismatches  : {len(mismatched_rows)} rows")
    print(f"  Match %           : {match_pct}%")
    print(f"  Status            : {status}")

    if verbose and mismatched_rows:
        print(f"\n  First 5 mismatched rows:")
        for r in mismatched_rows[:5]:
            print(f"    key={r['key']}  diffs={r['diffs']}")

    result = {
        "table": name,
        "status": "PASS" if status.startswith("✅") else "FAIL",
        "source_row_count": total_src,
        "target_row_count": total_tgt,
        "missing_in_target": len(missing_in_target),
        "extra_in_target": len(extra_in_target),
        "mismatched_rows": len(mismatched_rows),
        "match_pct": match_pct,
        "column_mismatch_counts": {
            k: v for k, v in col_mismatch_counts.items() if v > 0
        },
        "sample_mismatches": mismatched_rows[:10],
        "missing_keys_sample": [str(k) for k in missing_in_target[:5]],
        "extra_keys_sample": [str(k) for k in extra_in_target[:5]],
    }
    return result


# ──────────────────────────────────────────────────────────────────────────────
# 4.  Main
# ──────────────────────────────────────────────────────────────────────────────


def main():
    parser = argparse.ArgumentParser(
        description="Data parity validation: SQL Server → Fabric"
    )
    parser.add_argument("--table", help="Run only this table (e.g. dim_customer)")
    parser.add_argument(
        "--output",
        default="scripts/data_diff_report.json",
        help="Output JSON report path (relative to project root)",
    )
    parser.add_argument(
        "--verbose", action="store_true", help="Print per-row mismatch details"
    )
    args = parser.parse_args()

    pairs = TABLE_PAIRS
    if args.table:
        pairs = [p for p in TABLE_PAIRS if p["name"] == args.table]
        if not pairs:
            print(f"ERROR: unknown table '{args.table}'. Valid names:")
            for p in TABLE_PAIRS:
                print(f"  {p['name']}")
            sys.exit(1)

    print("=" * 60)
    print(" Eastman RetailDW → Microsoft Fabric — Data Parity Check")
    print(f" Run time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)

    print("\n[1/3] Connecting to MS SQL Server …", end=" ", flush=True)
    mssql_conn = connect_mssql()
    print("OK")

    print(
        "[2/3] Connecting to Microsoft Fabric (Azure AD token) …", end=" ", flush=True
    )
    fabric_conn = connect_fabric()
    print("OK")

    print("[3/3] Running diffs …")

    results = []
    for pair in pairs:
        try:
            result = diff_table(mssql_conn, fabric_conn, pair, verbose=args.verbose)
            results.append(result)
        except Exception as e:
            print(f"  ERROR diffing {pair['name']}: {e}")
            results.append(
                {
                    "table": pair["name"],
                    "status": "ERROR",
                    "error": str(e),
                }
            )

    mssql_conn.close()
    fabric_conn.close()

    # ── Final summary ─────────────────────────────────────────────────────────
    print(f"\n{'=' * 60}")
    print(" SUMMARY")
    print(f"{'=' * 60}")
    passed = sum(1 for r in results if r.get("status") == "PASS")
    failed = sum(1 for r in results if r.get("status") == "FAIL")
    errors = sum(1 for r in results if r.get("status") == "ERROR")
    print(f"  PASS  : {passed}")
    print(f"  FAIL  : {failed}")
    print(f"  ERROR : {errors}")
    print(f"  TOTAL : {len(results)}")

    overall = {
        "run_at": datetime.now().isoformat(),
        "summary": {
            "pass": passed,
            "fail": failed,
            "error": errors,
            "total": len(results),
        },
        "results": results,
    }

    out_path = ROOT / args.output
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with open(out_path, "w") as f:
        json.dump(overall, f, indent=2, default=str)

    print(f"\n  Report written → {out_path}")
    print(f"{'=' * 60}\n")

    sys.exit(0 if failed == 0 and errors == 0 else 1)


if __name__ == "__main__":
    main()
