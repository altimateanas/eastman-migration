/*
  Model: dim_date
  Layer: Gold — Dimension
  Purpose: Date dimension covering 2022-01-01 through 2026-12-31, supporting
           both calendar and fiscal year (July–June) attributes.
  Grain: One row per calendar date.
  Source: Generated (no source table — cross-join number generator)
  Mirrors: TRANSFORMED.DimDate (usp_LoadDimDate)

  Note: dbt_utils.date_spine is avoided here because its generated rawdata CTE
  contains a bare ORDER BY clause which Fabric SQL DW (T-SQL) rejects inside
  CTEs without TOP/OFFSET. A manual cross-join date generator is used instead.
*/

WITH

-- Generate 0-1 bit rows
bits AS (
    SELECT 0 AS n UNION ALL SELECT 1
),

-- 2^11 = 2048 numbers, enough for 5+ years of days
nums AS (
    SELECT
        b0.n
        + b1.n * 2
        + b2.n * 4
        + b3.n * 8
        + b4.n * 16
        + b5.n * 32
        + b6.n * 64
        + b7.n * 128
        + b8.n * 256
        + b9.n * 512
        + b10.n * 1024
        AS n
    FROM       bits b0
    CROSS JOIN bits b1
    CROSS JOIN bits b2
    CROSS JOIN bits b3
    CROSS JOIN bits b4
    CROSS JOIN bits b5
    CROSS JOIN bits b6
    CROSS JOIN bits b7
    CROSS JOIN bits b8
    CROSS JOIN bits b9
    CROSS JOIN bits b10
),

date_spine AS (

    SELECT
        CAST(DATEADD(day, n, CAST('2022-01-01' AS DATE)) AS DATE) AS date_day
    FROM nums
    WHERE n < DATEDIFF(day, CAST('2022-01-01' AS DATE), CAST('2027-01-01' AS DATE))

),

enriched AS (

    SELECT
        CAST(FORMAT(date_day, 'yyyyMMdd') AS INT)                    AS date_key,
        date_day                                                      AS full_date,
        DATEPART(weekday, date_day)                                   AS day_of_week,
        CAST(DATENAME(weekday, date_day) AS VARCHAR(30))             AS day_name,
        DAY(date_day)                                                 AS day_of_month,
        DATEPART(dayofyear, date_day)                                 AS day_of_year,
        DATEPART(week, date_day)                                      AS week_of_year,
        MONTH(date_day)                                               AS month_number,
        CAST(DATENAME(month, date_day) AS VARCHAR(30))                AS month_name,
        DATEPART(quarter, date_day)                                   AS quarter,
        'Q' + CAST(DATEPART(quarter, date_day) AS VARCHAR(1))        AS quarter_name,
        YEAR(date_day)                                                AS year,
        CASE
            WHEN DATEPART(weekday, date_day) IN (1, 7) THEN 1
            ELSE 0
        END                                                           AS is_weekend,
        -- Fiscal year starts July 1
        CASE
            WHEN MONTH(date_day) >= 7
                THEN MONTH(date_day) - 6
            ELSE MONTH(date_day) + 6
        END                                                           AS fiscal_month,
        CASE
            WHEN MONTH(date_day) >= 7
                THEN (MONTH(date_day) - 7) / 3 + 1
            ELSE (MONTH(date_day) + 5) / 3
        END                                                           AS fiscal_quarter,
        CASE
            WHEN MONTH(date_day) >= 7
                THEN YEAR(date_day) + 1
            ELSE YEAR(date_day)
        END                                                           AS fiscal_year
    FROM date_spine

)

SELECT * FROM enriched
