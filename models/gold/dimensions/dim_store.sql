/*
  Model: dim_store
  Layer: Gold — Dimension
  Purpose: Store dimension for analytical reporting.
  Grain: One row per store.
  Source: silver.stg_stores
  Mirrors: TRANSFORMED.DimStore (usp_LoadDimStore)
*/

WITH stores AS (

    SELECT
        store_id,
        store_name,
        store_type,
        city,
        state,
        country,
        postal_code,
        manager_name,
        open_date,
        is_active
    FROM {{ ref('stg_stores') }}

),

enriched AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['store_id']) }}         AS store_key,
        store_id,
        store_name,
        store_type,
        city,
        state,
        country,
        postal_code,
        manager_name,
        open_date,
        is_active,
        CAST(GETDATE() AS DATETIME2(6))                              AS dw_created_at,
        CAST(GETDATE() AS DATETIME2(6))                              AS dw_updated_at
    FROM stores

)

SELECT * FROM enriched
