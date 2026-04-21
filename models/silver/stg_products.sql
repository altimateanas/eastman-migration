/*
  Staging: Products
  Source: RAW.Products (seed_raw_products)
  Purpose: 1:1 staging of product master data with type casting
  Grain: One row per product
*/

with source as (
    select * from {{ source('raw', 'seed_raw_products') }}
),

staged as (
    select
        cast(ProductID as int)              as ProductID,
        cast(ProductName as varchar)        as ProductName,
        cast(CategoryID as int)             as CategoryID,
        cast(SupplierID as int)             as SupplierID,
        cast(SKU as varchar)                as SKU,
        cast(UnitPrice as decimal(18,2))    as UnitPrice,
        cast(CostPrice as decimal(18,2))    as CostPrice,
        cast(UnitsInStock as int)           as UnitsInStock,
        cast(ReorderLevel as int)           as ReorderLevel,
        cast(IsDiscontinued as int)         as IsDiscontinued
    from source
)

select * from staged
