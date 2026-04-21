/*
  Dimension: Product
  Migrated from: TRANSFORMED.usp_LoadDimProduct
  Purpose: Product dimension denormalized with category and supplier names, plus profit margin
  Grain: One row per product
  Notes:
    - Two INNER JOINs replicated exactly (products without matching category/supplier excluded)
    - ProfitMargin = ROUND(((UnitPrice - CostPrice) / UnitPrice) * 100, 2)
    - Division-by-zero guard when UnitPrice <= 0
    - Column names preserved exactly from SQL Server
*/

{{ config(
    materialized='table',
    schema='gold',
    tags=['gold', 'dimension']
) }}

with products as (
    select * from {{ ref('stg_products') }}
),

categories as (
    select * from {{ ref('stg_categories') }}
),

suppliers as (
    select * from {{ ref('stg_suppliers') }}
),

transformed as (
    select
        p.ProductID,
        p.ProductName,
        p.SKU,
        c.CategoryName,
        s.SupplierName,
        p.UnitPrice,
        p.CostPrice,
        case
            when p.UnitPrice > 0
            then round(((p.UnitPrice - p.CostPrice) / p.UnitPrice) * 100, 2)
            else 0
        end                     as ProfitMargin,
        p.IsDiscontinued
    from products p
    inner join categories c on p.CategoryID = c.CategoryID
    inner join suppliers s  on p.SupplierID = s.SupplierID
)

select
    ProductID,
    ProductName,
    SKU,
    CategoryName,
    SupplierName,
    UnitPrice,
    CostPrice,
    ProfitMargin,
    IsDiscontinued
from transformed
