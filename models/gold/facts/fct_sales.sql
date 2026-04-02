/*
  Model: fct_sales
  Layer: Gold — Fact
  Purpose: Sales fact table at order-line-item grain, joining order items
           against all dimensions and allocating shipping cost and payment
           amount proportionally across line items.
  Grain: One row per order line item (order_id + order_item_id).
  Source: silver.stg_orders, silver.stg_order_items, silver.stg_products,
          gold.dim_customer, gold.dim_product, gold.dim_store,
          gold.dim_employee, gold.dim_payment_method, gold.dim_date
  Mirrors: TRANSFORMED.FactSales (usp_LoadFactSales)
*/

WITH orders AS (

    SELECT
        order_id,
        customer_id,
        store_id,
        employee_id,
        order_date,
        order_channel,
        order_status
    FROM {{ ref('stg_orders') }}

),

order_items AS (

    SELECT
        order_item_id,
        order_id,
        product_id,
        quantity,
        unit_price,
        discount_percent,
        line_total
    FROM {{ ref('stg_order_items') }}

),

products AS (

    SELECT
        product_id,
        cost_price
    FROM {{ ref('stg_products') }}

),

-- Aggregate order-level total for proportional allocation of shipping & payment
order_totals AS (

    SELECT
        order_id,
        SUM(line_total) AS order_line_total
    FROM {{ ref('stg_order_items') }}
    GROUP BY order_id

),

-- Take the first payment per order (by payment_date)
first_payment AS (

    SELECT
        order_id,
        payment_method,
        amount,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY payment_date
        )                   AS rn
    FROM {{ ref('stg_payments') }}

),

-- Take the first shipment per order (by ship_date)
first_shipment AS (

    SELECT
        order_id,
        shipping_cost,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY ship_date
        )                   AS rn
    FROM {{ ref('stg_shipments') }}

),

-- Dimensions
dim_customer AS (
    SELECT customer_key, customer_id   FROM {{ ref('dim_customer') }}
),
dim_product AS (
    SELECT product_key, product_id     FROM {{ ref('dim_product') }}
),
dim_store AS (
    SELECT store_key, store_id         FROM {{ ref('dim_store') }}
),
dim_employee AS (
    SELECT employee_key, employee_id   FROM {{ ref('dim_employee') }}
),
dim_payment_method AS (
    SELECT payment_method_key, payment_method  FROM {{ ref('dim_payment_method') }}
),
dim_date AS (
    SELECT date_key, full_date         FROM {{ ref('dim_date') }}
),

joined AS (

    SELECT
        o.order_id,
        oi.order_item_id,
        dd.date_key                                                 AS order_date_key,
        dc.customer_key,
        dp.product_key,
        ds.store_key,
        de.employee_key,
        dpm.payment_method_key,
        o.order_channel,
        o.order_status,
        oi.quantity,
        oi.unit_price,
        p.cost_price,
        oi.discount_percent,
        oi.line_total,
        oi.quantity * p.cost_price                                  AS line_cost,
        oi.line_total - (oi.quantity * p.cost_price)                AS line_profit,
        -- Proportional shipping cost allocation
        CASE
            WHEN ot.order_line_total > 0
                THEN ROUND(
                        ISNULL(sh.shipping_cost, 0)
                        * (oi.line_total / ot.order_line_total),
                        2
                     )
            ELSE 0
        END                                                         AS shipping_cost,
        -- Proportional payment amount allocation
        CASE
            WHEN ot.order_line_total > 0
                THEN ROUND(
                        ISNULL(pay.amount, 0)
                        * (oi.line_total / ot.order_line_total),
                        2
                     )
            ELSE 0
        END                                                         AS payment_amount,
        CAST(GETDATE() AS DATETIME2(6))                             AS dw_created_at
    FROM orders           o
    INNER JOIN order_items   oi  ON o.order_id     = oi.order_id
    INNER JOIN products       p  ON oi.product_id  = p.product_id
    INNER JOIN order_totals  ot  ON o.order_id     = ot.order_id
    INNER JOIN dim_customer  dc  ON o.customer_id  = dc.customer_id
    INNER JOIN dim_product   dp  ON oi.product_id  = dp.product_id
    INNER JOIN dim_store     ds  ON o.store_id     = ds.store_id
    INNER JOIN dim_employee  de  ON o.employee_id  = de.employee_id
    INNER JOIN dim_date      dd  ON o.order_date   = dd.full_date
    LEFT  JOIN (SELECT order_id, payment_method, amount FROM first_payment WHERE rn = 1)
                         pay     ON o.order_id     = pay.order_id
    LEFT  JOIN dim_payment_method dpm ON pay.payment_method = dpm.payment_method
    LEFT  JOIN (SELECT order_id, shipping_cost FROM first_shipment WHERE rn = 1)
                          sh     ON o.order_id     = sh.order_id

)

SELECT * FROM joined
