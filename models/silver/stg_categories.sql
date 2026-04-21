/*
  Staging: Categories
  Source: RAW.Categories (seed_raw_categories)
  Purpose: 1:1 staging of category reference data with type casting
  Grain: One row per category
*/

with source as (
    select * from {{ source('raw', 'seed_raw_categories') }}
),

staged as (
    select
        cast(CategoryID as int)         as CategoryID,
        cast(CategoryName as varchar)   as CategoryName,
        cast(Description as varchar)    as Description,
        cast(IsActive as int)           as IsActive
    from source
)

select * from staged
