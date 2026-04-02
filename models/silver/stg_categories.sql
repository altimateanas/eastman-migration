/*
  Model: stg_categories
  Layer: Silver
  Purpose: Cleansed product category lookup from raw.seed_raw_categories.
  Grain: One row per category.
  Source: raw.seed_raw_categories
*/

WITH source AS (

    SELECT
        CategoryID,
        CategoryName,
        Description,
        IsActive
    FROM {{ source('raw', 'seed_raw_categories') }}

),

cleaned AS (

    SELECT
        CategoryID                              AS category_id,
        LTRIM(RTRIM(CategoryName))              AS category_name,
        LTRIM(RTRIM(Description))              AS description,
        CAST(IsActive AS INT)                   AS is_active
    FROM source

)

SELECT * FROM cleaned
