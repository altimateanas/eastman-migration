/*
  Model: fct_daily_inventory
  Layer: Gold — Fact
  Purpose: Daily inventory snapshot for active (non-discontinued) products,
           showing stock levels, reorder status, and stock value at cost.
  Grain: One row per product per snapshot date (SnapshotDateKey = today's date key).
  Source: silver.stg_products, gold.dim_product, gold.dim_date
  Mirrors: TRANSFORMED.FactDailyInventory (usp_LoadFactDailyInventory)

  Note: The original stored procedure snapshots only today's date.
        In dbt this model does the same using GETDATE() to derive today's date key.
        Run incrementally to accumulate historical snapshots over time.
*/

WITH products AS (

    SELECT
        product_id,
        units_in_stock,
        reorder_level,
        cost_price,
        is_discontinued
    FROM {{ ref('stg_products') }}
    WHERE is_discontinued = 0

),

dim_product AS (

    SELECT
        product_key,
        product_id
    FROM {{ ref('dim_product') }}

),

snapshot AS (

    SELECT
        CAST(FORMAT(CAST(GETDATE() AS DATE), 'yyyyMMdd') AS INT)    AS snapshot_date_key,
        dp.product_key,
        p.units_in_stock,
        p.reorder_level,
        CASE
            WHEN p.units_in_stock = 0              THEN 'Out of Stock'
            WHEN p.units_in_stock <= p.reorder_level THEN 'Low Stock'
            ELSE 'In Stock'
        END                                                          AS stock_status,
        p.units_in_stock * p.cost_price                              AS stock_value,
        CAST(GETDATE() AS DATETIME2(6))                              AS dw_created_at
    FROM products p
    INNER JOIN dim_product dp ON p.product_id = dp.product_id

)

SELECT * FROM snapshot
