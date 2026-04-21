/*
  Staging: Employees
  Source: RAW.Employees (seed_raw_employees)
  Purpose: 1:1 staging of employee master data with type casting
  Grain: One row per employee
*/

with source as (
    select * from {{ source('raw', 'seed_raw_employees') }}
),

staged as (
    select
        cast(EmployeeID as int)         as EmployeeID,
        cast(FirstName as varchar)      as FirstName,
        cast(LastName as varchar)       as LastName,
        cast(Email as varchar)          as Email,
        cast(Phone as varchar)          as Phone,
        cast(HireDate as date)          as HireDate,
        cast(JobTitle as varchar)       as JobTitle,
        cast(Department as varchar)     as Department,
        cast(StoreID as int)            as StoreID,
        cast(ManagerID as int)          as ManagerID,
        cast(Salary as decimal(18,2))   as Salary,
        cast(IsActive as int)           as IsActive
    from source
)

select * from staged
