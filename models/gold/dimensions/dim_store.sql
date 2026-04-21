/*
  Dimension: Store
  Migrated from: TRANSFORMED.usp_LoadDimStore
  Purpose: Store dimension - direct passthrough from RAW.Stores
  Grain: One row per store
  Notes:
    - Simplest dimension: no joins, no derived columns
    - Column names preserved exactly from SQL Server
*/

{{ config(
    materialized='table',
    schema='gold',
    tags=['gold', 'dimension']
) }}

with stores as (
    select * from {{ ref('stg_stores') }}
),

transformed as (
    select
        StoreID,
        StoreName,
        StoreType,
        City,
        State,
        Country,
        PostalCode,
        ManagerName,
        OpenDate,
        IsActive
    from stores
)

select
    StoreID,
    StoreName,
    StoreType,
    City,
    State,
    Country,
    PostalCode,
    ManagerName,
    OpenDate,
    IsActive
from transformed
