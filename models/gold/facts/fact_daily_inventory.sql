/*
  Fact: Daily Inventory
  Migrated from: TRANSFORMED.usp_LoadFactDailyInventory
  Purpose: Daily inventory snapshot for active (non-discontinued) products
  Grain: One row per active product per snapshot day
  Notes:
    - SQL Server used GETDATE() for @TodayKey; dbt version uses getdate()
    - DELETE + INSERT pattern replaced with table materialization (full refresh)
    - In production, consider incremental materialization with delete+insert strategy
    - StockStatus classification and StockValue calculation preserved exactly
    - Column names preserved exactly from SQL Server
*/

{{ config(
    materialized='table',
    schema='gold',
    tags=['gold', 'fact']
) }}

with products as (
    select * from {{ ref('stg_products') }}
),

dim_products as (
    select * from {{ ref('dim_product') }}
),

inventory_snapshot as (
    select
        -- SnapshotDateKey: YYYYMMDD integer for today
        cast(
            year(getdate()) * 10000
            + month(getdate()) * 100
            + day(getdate())
            as int
        )                                                   as SnapshotDateKey,

        dp.ProductID                                        as ProductKey,
        p.UnitsInStock,
        p.ReorderLevel,

        case
            when p.UnitsInStock = 0               then 'Out of Stock'
            when p.UnitsInStock <= p.ReorderLevel  then 'Low Stock'
            else 'In Stock'
        end                                                 as StockStatus,

        p.UnitsInStock * p.CostPrice                        as StockValue

    from products p
    inner join dim_products dp on p.ProductID = dp.ProductID
    where p.IsDiscontinued = 0
)

select
    SnapshotDateKey,
    ProductKey,
    UnitsInStock,
    ReorderLevel,
    StockStatus,
    StockValue
from inventory_snapshot
