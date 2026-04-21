/*
  Staging: Customers
  Source: RAW.Customers (seed_raw_customers)
  Purpose: 1:1 staging of customer master data with type casting
  Grain: One row per customer
*/

with source as (
    select * from {{ source('raw', 'seed_raw_customers') }}
),

staged as (
    select
        cast(CustomerID as int)             as CustomerID,
        cast(FirstName as varchar)          as FirstName,
        cast(LastName as varchar)           as LastName,
        cast(Email as varchar)              as Email,
        cast(Phone as varchar)              as Phone,
        cast(DateOfBirth as date)           as DateOfBirth,
        cast(Gender as varchar)             as Gender,
        cast(Address as varchar)            as Address,
        cast(City as varchar)               as City,
        cast(State as varchar)              as State,
        cast(Country as varchar)            as Country,
        cast(PostalCode as varchar)         as PostalCode,
        cast(CustomerSegment as varchar)    as CustomerSegment,
        cast(RegistrationDate as date)      as RegistrationDate,
        cast(IsActive as int)               as IsActive
    from source
)

select * from staged
