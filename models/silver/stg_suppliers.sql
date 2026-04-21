/*
  Staging: Suppliers
  Source: RAW.Suppliers (seed_raw_suppliers)
  Purpose: 1:1 staging of supplier/vendor data with type casting
  Grain: One row per supplier
*/

with source as (
    select * from {{ source('raw', 'seed_raw_suppliers') }}
),

staged as (
    select
        cast(SupplierID as int)         as SupplierID,
        cast(SupplierName as varchar)   as SupplierName,
        cast(ContactName as varchar)    as ContactName,
        cast(ContactEmail as varchar)   as ContactEmail,
        cast(Phone as varchar)          as Phone,
        cast(Address as varchar)        as Address,
        cast(City as varchar)           as City,
        cast(State as varchar)          as State,
        cast(Country as varchar)        as Country,
        cast(PostalCode as varchar)     as PostalCode,
        cast(IsActive as int)           as IsActive
    from source
)

select * from staged
