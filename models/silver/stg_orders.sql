/*
  Staging: Orders
  Source: RAW.Orders (seed_raw_orders)
  Purpose: 1:1 staging of order header data with type casting
  Grain: One row per order
*/

with source as (
    select * from {{ source('raw', 'seed_raw_orders') }}
),

staged as (
    select
        cast(OrderID as int)            as OrderID,
        cast(CustomerID as int)         as CustomerID,
        cast(StoreID as int)            as StoreID,
        cast(EmployeeID as int)         as EmployeeID,
        cast(OrderDate as date)         as OrderDate,
        cast(RequiredDate as date)      as RequiredDate,
        cast(OrderStatus as varchar)    as OrderStatus,
        cast(OrderChannel as varchar)   as OrderChannel,
        cast(Notes as varchar)          as Notes
    from source
)

select * from staged
