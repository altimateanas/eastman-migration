/*
  Model: stg_stores
  Layer: Silver
  Purpose: Cleansed store master data from raw.seed_raw_stores.
  Grain: One row per store.
  Source: raw.seed_raw_stores
*/

WITH source AS (

    SELECT
        StoreID,
        StoreName,
        StoreType,
        Address,
        City,
        State,
        Country,
        PostalCode,
        Phone,
        ManagerName,
        OpenDate,
        IsActive
    FROM {{ source('raw', 'seed_raw_stores') }}

),

cleaned AS (

    SELECT
        StoreID                                 AS store_id,
        LTRIM(RTRIM(StoreName))                 AS store_name,
        LTRIM(RTRIM(StoreType))                 AS store_type,
        LTRIM(RTRIM(Address))                   AS address,
        LTRIM(RTRIM(City))                      AS city,
        LTRIM(RTRIM(State))                     AS state,
        LTRIM(RTRIM(Country))                   AS country,
        CAST(PostalCode AS VARCHAR(20))         AS postal_code,
        LTRIM(RTRIM(Phone))                     AS phone,
        LTRIM(RTRIM(ManagerName))               AS manager_name,
        CAST(OpenDate AS DATE)                  AS open_date,
        CAST(IsActive AS INT)                   AS is_active
    FROM source

)

SELECT * FROM cleaned
