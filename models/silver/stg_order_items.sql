/*
  Staging: Order Items
  Source: RAW.OrderItems (seed_raw_order_items)
  Purpose: 1:1 staging of order line item data with type casting
  Grain: One row per order line item
*/

with source as (
    select * from {{ source('raw', 'seed_raw_order_items') }}
),

staged as (
    select
        cast(OrderItemID as int)            as OrderItemID,
        cast(OrderID as int)                as OrderID,
        cast(ProductID as int)              as ProductID,
        cast(Quantity as int)               as Quantity,
        cast(UnitPrice as decimal(18,2))    as UnitPrice,
        cast(Discount as decimal(18,4))     as Discount,
        cast(LineTotal as decimal(18,2))    as LineTotal
    from source
)

select * from staged
