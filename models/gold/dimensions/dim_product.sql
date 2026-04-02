/*
  Model: dim_product
  Layer: Gold — Dimension
  Purpose: Product dimension enriched with category and supplier names,
           plus calculated profit margin.
  Grain: One row per product.
  Source: silver.stg_products, silver.stg_categories, silver.stg_suppliers
  Mirrors: TRANSFORMED.DimProduct (usp_LoadDimProduct)
*/

WITH products AS (

    SELECT
        product_id,
        product_name,
        sku,
        category_id,
        supplier_id,
        unit_price,
        cost_price,
        units_in_stock,
        reorder_level,
        is_discontinued
    FROM {{ ref('stg_products') }}

),

categories AS (

    SELECT
        category_id,
        category_name
    FROM {{ ref('stg_categories') }}

),

suppliers AS (

    SELECT
        supplier_id,
        supplier_name
    FROM {{ ref('stg_suppliers') }}

),

enriched AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['p.product_id']) }}     AS product_key,
        p.product_id,
        p.product_name,
        p.sku,
        c.category_name,
        s.supplier_name,
        p.unit_price,
        p.cost_price,
        CASE
            WHEN p.unit_price > 0
                THEN ROUND(((p.unit_price - p.cost_price) / p.unit_price) * 100, 2)
            ELSE 0
        END                                                          AS profit_margin,
        p.is_discontinued,
        CAST(GETDATE() AS DATETIME2(6))                              AS dw_created_at,
        CAST(GETDATE() AS DATETIME2(6))                              AS dw_updated_at
    FROM products p
    INNER JOIN categories c ON p.category_id = c.category_id
    INNER JOIN suppliers  s ON p.supplier_id = s.supplier_id

)

SELECT * FROM enriched
