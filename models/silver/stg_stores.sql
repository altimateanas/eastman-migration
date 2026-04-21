/*
  Staging: Stores
  Source: RAW.Stores (seed_raw_stores)
  Purpose: 1:1 staging of store location data with type casting
  Grain: One row per store
*/

with source as (
    select * from {{ source('raw', 'seed_raw_stores') }}
),

staged as (
    select
        cast(StoreID as int)            as StoreID,
        cast(StoreName as varchar)      as StoreName,
        cast(StoreType as varchar)      as StoreType,
        cast(Address as varchar)        as Address,
        cast(City as varchar)           as City,
        cast(State as varchar)          as State,
        cast(Country as varchar)        as Country,
        cast(PostalCode as varchar)     as PostalCode,
        cast(Phone as varchar)          as Phone,
        cast(ManagerName as varchar)    as ManagerName,
        cast(OpenDate as date)          as OpenDate,
        cast(IsActive as int)           as IsActive
    from source
)

select * from staged
