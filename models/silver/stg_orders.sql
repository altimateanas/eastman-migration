/*
  Model: stg_orders
  Layer: Silver
  Purpose: Cleansed and standardised order header data from raw.seed_raw_orders.
  Grain: One row per order.
  Source: raw.seed_raw_orders
*/

WITH source AS (

    SELECT
        OrderID,
        CustomerID,
        StoreID,
        EmployeeID,
        OrderDate,
        RequiredDate,
        OrderStatus,
        OrderChannel,
        Notes
    FROM {{ source('raw', 'seed_raw_orders') }}

),

cleaned AS (

    SELECT
        OrderID                                 AS order_id,
        CustomerID                              AS customer_id,
        StoreID                                 AS store_id,
        EmployeeID                              AS employee_id,
        CAST(OrderDate AS DATE)                 AS order_date,
        CAST(RequiredDate AS DATE)              AS required_date,
        LTRIM(RTRIM(OrderChannel))              AS order_channel,
        LTRIM(RTRIM(OrderStatus))               AS order_status,
        LTRIM(RTRIM(Notes))                     AS notes
    FROM source

)

SELECT * FROM cleaned
