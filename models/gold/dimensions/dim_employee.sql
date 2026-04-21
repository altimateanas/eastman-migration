/*
  Dimension: Employee
  Migrated from: TRANSFORMED.usp_LoadDimEmployee
  Purpose: Employee dimension denormalized with store name, plus derived FullName and YearsOfService
  Grain: One row per employee (only those with valid store assignment)
  Notes:
    - INNER JOIN to Stores replicated exactly (employees without matching store excluded)
    - GETDATE() replaced with getdate() (Fabric-compatible)
    - DATEDIFF(YEAR, HireDate, GETDATE()) for YearsOfService
    - Column names preserved exactly from SQL Server
*/

{{ config(
    materialized='table',
    schema='gold',
    tags=['gold', 'dimension']
) }}

with employees as (
    select * from {{ ref('stg_employees') }}
),

stores as (
    select * from {{ ref('stg_stores') }}
),

transformed as (
    select
        e.EmployeeID,
        concat(e.FirstName, ' ', e.LastName)                as FullName,
        e.Email,
        e.JobTitle,
        e.Department,
        s.StoreName,
        e.HireDate,
        datediff(year, e.HireDate, getdate())               as YearsOfService,
        e.IsActive
    from employees e
    inner join stores s on e.StoreID = s.StoreID
)

select
    EmployeeID,
    FullName,
    Email,
    JobTitle,
    Department,
    StoreName,
    HireDate,
    YearsOfService,
    IsActive
from transformed
