/*
  Model: stg_suppliers
  Layer: Silver
  Purpose: Cleansed supplier master data from raw.seed_raw_suppliers.
  Grain: One row per supplier.
  Source: raw.seed_raw_suppliers
*/

WITH source AS (

    SELECT
        SupplierID,
        SupplierName,
        ContactName,
        ContactEmail,
        Phone,
        Address,
        City,
        State,
        Country,
        PostalCode,
        IsActive
    FROM {{ source('raw', 'seed_raw_suppliers') }}

),

cleaned AS (

    SELECT
        SupplierID                              AS supplier_id,
        LTRIM(RTRIM(SupplierName))              AS supplier_name,
        LTRIM(RTRIM(ContactName))               AS contact_name,
        LOWER(LTRIM(RTRIM(ContactEmail)))       AS contact_email,
        LTRIM(RTRIM(Phone))                     AS phone,
        LTRIM(RTRIM(Address))                   AS address,
        LTRIM(RTRIM(City))                      AS city,
        LTRIM(RTRIM(State))                     AS state,
        LTRIM(RTRIM(Country))                   AS country,
        CAST(PostalCode AS VARCHAR(20))         AS postal_code,
        CAST(IsActive AS INT)                   AS is_active
    FROM source

)

SELECT * FROM cleaned
