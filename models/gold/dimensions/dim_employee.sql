/*
  Model: dim_employee
  Layer: Gold — Dimension
  Purpose: Employee dimension enriched with store name and years of service.
  Grain: One row per employee.
  Source: silver.stg_employees, silver.stg_stores
  Mirrors: TRANSFORMED.DimEmployee (usp_LoadDimEmployee)
*/

WITH employees AS (

    SELECT
        employee_id,
        first_name,
        last_name,
        email,
        job_title,
        department,
        store_id,
        hire_date,
        is_active
    FROM {{ ref('stg_employees') }}

),

stores AS (

    SELECT
        store_id,
        store_name
    FROM {{ ref('stg_stores') }}

),

enriched AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['e.employee_id']) }}    AS employee_key,
        e.employee_id,
        CONCAT(e.first_name, ' ', e.last_name)                      AS full_name,
        e.email,
        e.job_title,
        e.department,
        s.store_name,
        e.hire_date,
        DATEDIFF(year, e.hire_date, GETDATE())                       AS years_of_service,
        e.is_active,
        CAST(GETDATE() AS DATETIME2(6))                              AS dw_created_at,
        CAST(GETDATE() AS DATETIME2(6))                              AS dw_updated_at
    FROM employees e
    INNER JOIN stores s ON e.store_id = s.store_id

)

SELECT * FROM enriched
