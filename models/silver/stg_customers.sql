/*
  Model: stg_customers
  Layer: Silver
  Purpose: Cleansed and standardised customer data from raw.seed_raw_customers.
  Grain: One row per customer.
  Source: raw.seed_raw_customers
*/

WITH source AS (

    SELECT
        CustomerID,
        FirstName,
        LastName,
        Email,
        Phone,
        DateOfBirth,
        Gender,
        Address,
        City,
        State,
        Country,
        PostalCode,
        CustomerSegment,
        RegistrationDate,
        IsActive
    FROM {{ source('raw', 'seed_raw_customers') }}

),

cleaned AS (

    SELECT
        CustomerID                              AS customer_id,
        LTRIM(RTRIM(FirstName))                 AS first_name,
        LTRIM(RTRIM(LastName))                  AS last_name,
        LOWER(LTRIM(RTRIM(Email)))              AS email,
        LTRIM(RTRIM(Phone))                     AS phone,
        CAST(DateOfBirth AS DATE)               AS date_of_birth,
        LTRIM(RTRIM(Gender))                    AS gender,
        LTRIM(RTRIM(Address))                   AS address,
        LTRIM(RTRIM(City))                      AS city,
        LTRIM(RTRIM(State))                     AS state,
        LTRIM(RTRIM(Country))                   AS country,
        CAST(PostalCode AS VARCHAR(20))         AS postal_code,
        LTRIM(RTRIM(CustomerSegment))           AS customer_segment,
        CAST(RegistrationDate AS DATE)          AS registration_date,
        CAST(IsActive AS INT)                   AS is_active
    FROM source

)

SELECT * FROM cleaned
