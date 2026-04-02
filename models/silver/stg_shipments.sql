/*
  Model: stg_shipments
  Layer: Silver
  Purpose: Cleansed shipment data from raw.seed_raw_shipments.
  Grain: One row per shipment.
  Source: raw.seed_raw_shipments
*/

WITH source AS (

    SELECT
        ShipmentID,
        OrderID,
        ShipDate,
        DeliveryDate,
        Carrier,
        TrackingNumber,
        ShipmentStatus,
        ShippingCost,
        Address,
        City,
        State,
        Country,
        PostalCode
    FROM {{ source('raw', 'seed_raw_shipments') }}

),

cleaned AS (

    SELECT
        ShipmentID                              AS shipment_id,
        OrderID                                 AS order_id,
        CAST(ShipDate AS DATETIME2)             AS ship_date,
        CAST(DeliveryDate AS DATETIME2)         AS delivery_date,
        LTRIM(RTRIM(Carrier))                   AS carrier,
        LTRIM(RTRIM(TrackingNumber))            AS tracking_number,
        LTRIM(RTRIM(ShipmentStatus))            AS shipment_status,
        CAST(ShippingCost AS DECIMAL(18, 4))    AS shipping_cost,
        LTRIM(RTRIM(Address))                   AS address,
        LTRIM(RTRIM(City))                      AS city,
        LTRIM(RTRIM(State))                     AS state,
        LTRIM(RTRIM(Country))                   AS country,
        CAST(PostalCode AS VARCHAR(20))         AS postal_code
    FROM source

)

SELECT * FROM cleaned
