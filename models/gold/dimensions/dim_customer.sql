/*
  Dimension: Customer
  Migrated from: TRANSFORMED.usp_LoadDimCustomer
  Purpose: Customer dimension with derived FullName and AgeGroup classification
  Grain: One row per customer
  Notes:
    - GETDATE() replaced with getdate() (Fabric-compatible)
    - DATEDIFF(YEAR, ...) used for age bucketing (same semantics)
    - CONCAT() is Fabric-compatible
    - Column names preserved exactly from SQL Server
*/

{{ config(
    materialized='table',
    schema='gold',
    tags=['gold', 'dimension']
) }}

with customers as (
    select * from {{ ref('stg_customers') }}
),

transformed as (
    select
        CustomerID,
        concat(FirstName, ' ', LastName)    as FullName,
        Email,
        Phone,
        DateOfBirth,
        Gender,
        City,
        State,
        Country,
        PostalCode,
        CustomerSegment,
        case
            when datediff(year, DateOfBirth, getdate()) < 25 then '18-24'
            when datediff(year, DateOfBirth, getdate()) < 35 then '25-34'
            when datediff(year, DateOfBirth, getdate()) < 45 then '35-44'
            when datediff(year, DateOfBirth, getdate()) < 55 then '45-54'
            else '55+'
        end                                 as AgeGroup,
        RegistrationDate,
        IsActive
    from customers
)

select
    CustomerID,
    FullName,
    Email,
    Phone,
    DateOfBirth,
    Gender,
    City,
    State,
    Country,
    PostalCode,
    CustomerSegment,
    AgeGroup,
    RegistrationDate,
    IsActive
from transformed
