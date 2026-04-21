/*
  Fact: Sales
  Migrated from: TRANSFORMED.usp_LoadFactSales
  Purpose: Central sales fact table at order line item grain
  Grain: One row per order line item (OrderItemID)
  Notes:
    - 9-table join replicated exactly from SQL Server SP
    - ROW_NUMBER() for first payment and first shipment per order
    - CROSS APPLY replaced with CTE-based aggregation (Fabric-compatible)
    - Proportional allocation of shipping cost and payment amount to line items
    - ISNULL() replaced with isnull() (Fabric-compatible)
    - FORMAT() replaced with arithmetic for DateKey
    - Column names preserved exactly from SQL Server
*/

{{ config(
    materialized='table',
    schema='gold',
    tags=['gold', 'fact']
) }}

with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

dim_customers as (
    select * from {{ ref('dim_customer') }}
),

dim_products as (
    select * from {{ ref('dim_product') }}
),

dim_stores as (
    select * from {{ ref('dim_store') }}
),

dim_employees as (
    select * from {{ ref('dim_employee') }}
),

dim_payment_methods as (
    select * from {{ ref('dim_payment_method') }}
),

-- First payment per order (ROW_NUMBER pattern from SQL Server SP)
first_payment as (
    select
        OrderID,
        PaymentMethod,
        Amount,
        row_number() over (partition by OrderID order by PaymentDate) as rn
    from {{ ref('stg_payments') }}
),

-- First shipment per order (ROW_NUMBER pattern from SQL Server SP)
first_shipment as (
    select
        OrderID,
        ShippingCost,
        row_number() over (partition by OrderID order by ShipDate) as rn
    from {{ ref('stg_shipments') }}
),

-- Order-level line total (replaces CROSS APPLY from SQL Server SP)
order_totals as (
    select
        OrderID,
        sum(LineTotal) as OrderLineTotal
    from {{ ref('stg_order_items') }}
    group by OrderID
),

fact_sales as (
    select
        o.OrderID,
        oi.OrderItemID,

        -- DateKey: YYYYMMDD integer (replaces CONVERT(INT, FORMAT(o.OrderDate, 'yyyyMMdd')))
        cast(
            year(o.OrderDate) * 10000
            + month(o.OrderDate) * 100
            + day(o.OrderDate)
            as int
        )                                                           as OrderDateKey,

        dc.CustomerID                                               as CustomerKey,
        dp.ProductID                                                as ProductKey,
        ds.StoreID                                                  as StoreKey,
        de.EmployeeID                                               as EmployeeKey,
        dpm.PaymentMethod                                           as PaymentMethodKey,

        o.OrderChannel,
        o.OrderStatus,

        oi.Quantity,
        oi.UnitPrice,
        p.CostPrice,
        oi.Discount                                                 as DiscountPercent,
        oi.LineTotal,
        oi.Quantity * p.CostPrice                                   as LineCost,
        oi.LineTotal - (oi.Quantity * p.CostPrice)                  as LineProfit,

        -- Proportional shipping cost allocation
        case
            when ot.OrderLineTotal > 0
            then round(isnull(sh.ShippingCost, 0) * (oi.LineTotal / ot.OrderLineTotal), 2)
            else 0
        end                                                         as ShippingCost,

        -- Proportional payment amount allocation
        case
            when ot.OrderLineTotal > 0
            then round(isnull(pay.Amount, 0) * (oi.LineTotal / ot.OrderLineTotal), 2)
            else 0
        end                                                         as PaymentAmount

    from orders o
    inner join order_items oi                on o.OrderID = oi.OrderID
    inner join products p                    on oi.ProductID = p.ProductID
    inner join dim_customers dc              on o.CustomerID = dc.CustomerID
    inner join dim_products dp               on oi.ProductID = dp.ProductID
    inner join dim_stores ds                 on o.StoreID = ds.StoreID
    inner join dim_employees de              on o.EmployeeID = de.EmployeeID
    left join first_payment pay              on o.OrderID = pay.OrderID and pay.rn = 1
    left join dim_payment_methods dpm        on pay.PaymentMethod = dpm.PaymentMethod
    left join first_shipment sh              on o.OrderID = sh.OrderID and sh.rn = 1
    left join order_totals ot               on o.OrderID = ot.OrderID
)

select
    OrderID,
    OrderItemID,
    OrderDateKey,
    CustomerKey,
    ProductKey,
    StoreKey,
    EmployeeKey,
    PaymentMethodKey,
    OrderChannel,
    OrderStatus,
    Quantity,
    UnitPrice,
    CostPrice,
    DiscountPercent,
    LineTotal,
    LineCost,
    LineProfit,
    ShippingCost,
    PaymentAmount
from fact_sales
