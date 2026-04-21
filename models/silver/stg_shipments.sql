/*
  Staging: Shipments
  Source: RAW.Shipments (seed_raw_shipments)
  Purpose: 1:1 staging of shipment tracking data with type casting
  Grain: One row per shipment
*/

with source as (
    select * from {{ source('raw', 'seed_raw_shipments') }}
),

staged as (
    select
        cast(ShipmentID as int)             as ShipmentID,
        cast(OrderID as int)                as OrderID,
        cast(ShipDate as date)              as ShipDate,
        cast(DeliveryDate as date)          as DeliveryDate,
        cast(Carrier as varchar)            as Carrier,
        cast(TrackingNumber as varchar)     as TrackingNumber,
        cast(ShipmentStatus as varchar)     as ShipmentStatus,
        cast(ShippingCost as decimal(18,2)) as ShippingCost,
        cast(Address as varchar)            as Address,
        cast(City as varchar)               as City,
        cast(State as varchar)              as State,
        cast(Country as varchar)            as Country,
        cast(PostalCode as varchar)         as PostalCode
    from source
)

select * from staged
