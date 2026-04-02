/*
  Model: stg_order_items
  Layer: Silver
  Purpose: Cleansed order line item data from raw.seed_raw_order_items.
  Grain: One row per order line item (OrderItemID).
  Source: raw.seed_raw_order_items
*/

WITH source AS (

    SELECT
        OrderItemID,
        OrderID,
        ProductID,
        Quantity,
        UnitPrice,
        Discount,
        LineTotal
    FROM {{ source('raw', 'seed_raw_order_items') }}

),

cleaned AS (

    SELECT
        OrderItemID                             AS order_item_id,
        OrderID                                 AS order_id,
        ProductID                               AS product_id,
        CAST(Quantity AS INT)                   AS quantity,
        CAST(UnitPrice AS DECIMAL(18, 4))       AS unit_price,
        CAST(Discount AS DECIMAL(5, 2))         AS discount_percent,
        CAST(LineTotal AS DECIMAL(18, 4))       AS line_total
    FROM source

)

SELECT * FROM cleaned
