/*
  Model: stg_employees
  Layer: Silver
  Purpose: Cleansed employee master data from raw.seed_raw_employees.
  Grain: One row per employee.
  Source: raw.seed_raw_employees
*/

WITH source AS (

    SELECT
        EmployeeID,
        FirstName,
        LastName,
        Email,
        Phone,
        HireDate,
        JobTitle,
        Department,
        StoreID,
        ManagerID,
        Salary,
        IsActive
    FROM {{ source('raw', 'seed_raw_employees') }}

),

cleaned AS (

    SELECT
        EmployeeID                              AS employee_id,
        LTRIM(RTRIM(FirstName))                 AS first_name,
        LTRIM(RTRIM(LastName))                  AS last_name,
        LOWER(LTRIM(RTRIM(Email)))              AS email,
        LTRIM(RTRIM(Phone))                     AS phone,
        CAST(HireDate AS DATE)                  AS hire_date,
        LTRIM(RTRIM(JobTitle))                  AS job_title,
        LTRIM(RTRIM(Department))                AS department,
        StoreID                                 AS store_id,
        ManagerID                               AS manager_id,
        CAST(Salary AS DECIMAL(18, 2))          AS salary,
        CAST(IsActive AS INT)                   AS is_active
    FROM source

)

SELECT * FROM cleaned
