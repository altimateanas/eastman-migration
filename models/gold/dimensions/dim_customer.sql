/*
  Model: dim_customer
  Layer: Gold — Dimension
  Purpose: Customer dimension table for analytical reporting.
  Grain: One row per customer.
  Source: silver.stg_customers
  Mirrors: TRANSFORMED.DimCustomer (usp_LoadDimCustomer)
*/

WITH stg AS (

    SELECT
        customer_id,
        first_name,
        last_name,
        email,
        phone,
        date_of_birth,
        gender,
        city,
        state,
        country,
        postal_code,
        customer_segment,
        registration_date,
        is_active
    FROM {{ ref('stg_customers') }}

),

enriched AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }}   AS customer_key,
        customer_id,
        CONCAT(first_name, ' ', last_name)                        AS full_name,
        email,
        phone,
        date_of_birth,
        gender,
        city,
        state,
        country,
        postal_code,
        customer_segment,
        CASE
            WHEN DATEDIFF(year, date_of_birth, GETDATE()) < 25
                THEN '18-24'
            WHEN DATEDIFF(year, date_of_birth, GETDATE()) < 35
                THEN '25-34'
            WHEN DATEDIFF(year, date_of_birth, GETDATE()) < 45
                THEN '35-44'
            WHEN DATEDIFF(year, date_of_birth, GETDATE()) < 55
                THEN '45-54'
            ELSE '55+'
        END                                                        AS age_group,
        registration_date,
        is_active,
        CAST(GETDATE() AS DATETIME2(6))                            AS dw_created_at,
        CAST(GETDATE() AS DATETIME2(6))                            AS dw_updated_at
    FROM stg

)

SELECT * FROM enriched
