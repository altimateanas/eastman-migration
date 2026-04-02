/*
  Model: stg_products
  Layer: Silver
  Purpose: Cleansed product master data from raw.seed_raw_products.
  Grain: One row per product.
  Source: raw.seed_raw_products
*/

WITH source AS (

    SELECT
        ProductID,
        ProductName,
        CategoryID,
        SupplierID,
        SKU,
        UnitPrice,
        CostPrice,
        UnitsInStock,
        ReorderLevel,
        IsDiscontinued
    FROM {{ source('raw', 'seed_raw_products') }}

),

cleaned AS (

    SELECT
        ProductID                               AS product_id,
        LTRIM(RTRIM(ProductName))               AS product_name,
        CategoryID                              AS category_id,
        SupplierID                              AS supplier_id,
        LTRIM(RTRIM(SKU))                       AS sku,
        CAST(UnitPrice AS DECIMAL(18, 4))       AS unit_price,
        CAST(CostPrice AS DECIMAL(18, 4))       AS cost_price,
        CAST(UnitsInStock AS INT)               AS units_in_stock,
        CAST(ReorderLevel AS INT)               AS reorder_level,
        CAST(IsDiscontinued AS INT)             AS is_discontinued
    FROM source

)

SELECT * FROM cleaned
