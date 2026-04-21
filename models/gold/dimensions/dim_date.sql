/*
  Dimension: Date
  Migrated from: TRANSFORMED.usp_LoadDimDate
  Purpose: Calendar and fiscal date dimension spanning 2022-01-01 to 2026-12-31
  Grain: One row per calendar day
  Fiscal Year: July 1 start (July = fiscal month 1, June = fiscal month 12)
  Notes:
    - SQL Server WHILE loop replaced with cross-join number generator (Fabric-compatible)
    - Fabric DW does not support recursive CTEs or OPTION (MAXRECURSION)
    - DATEPART(WEEKDAY) with DATEFIRST=7 maps Sunday=1, Saturday=7
    - FORMAT() replaced with Fabric-compatible date arithmetic for DateKey
*/

{{ config(
    materialized='table',
    schema='gold',
    tags=['gold', 'dimension']
) }}

with
-- Generate numbers 0-9 using VALUES
digits as (
    select v.n
    from (values (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) as v(n)
),

-- Cross-join to get 0-9999 (enough for 1,827 days from 2022-01-01 to 2026-12-31)
numbers as (
    select
        d1.n + d2.n * 10 + d3.n * 100 + d4.n * 1000 as num
    from digits d1
    cross join digits d2
    cross join digits d3
    cross join digits d4
),

date_spine as (
    select
        cast(dateadd(day, num, cast('2022-01-01' as date)) as date) as FullDate
    from numbers
    where dateadd(day, num, cast('2022-01-01' as date)) <= cast('2026-12-31' as date)
),

date_attributes as (
    select
        -- DateKey: integer YYYYMMDD (replaces CONVERT(INT, FORMAT(@Date, 'yyyyMMdd')))
        cast(
            year(FullDate) * 10000
            + month(FullDate) * 100
            + day(FullDate)
            as int
        )                                                       as DateKey,
        FullDate,
        datepart(dw, FullDate)                                  as DayOfWeek,
        cast(datename(weekday, FullDate) as varchar(20))        as DayName,
        day(FullDate)                                           as DayOfMonth,
        datepart(dayofyear, FullDate)                           as DayOfYear,
        datepart(week, FullDate)                                as WeekOfYear,
        month(FullDate)                                         as MonthNumber,
        cast(datename(month, FullDate) as varchar(20))          as MonthName,
        datepart(quarter, FullDate)                             as Quarter,
        cast(concat('Q', cast(datepart(quarter, FullDate) as varchar(2))) as varchar(3)) as QuarterName,
        year(FullDate)                                          as Year,

        -- IsWeekend: Sunday=1, Saturday=7 (SQL Server default DATEFIRST=7)
        case
            when datepart(dw, FullDate) in (1, 7) then 1
            else 0
        end                                                     as IsWeekend,

        -- Fiscal calendar (July 1 fiscal year start)
        case
            when month(FullDate) >= 7 then month(FullDate) - 6
            else month(FullDate) + 6
        end                                                     as FiscalMonth,

        case
            when month(FullDate) >= 7 then (month(FullDate) - 7) / 3 + 1
            else (month(FullDate) + 5) / 3
        end                                                     as FiscalQuarter,

        case
            when month(FullDate) >= 7 then year(FullDate) + 1
            else year(FullDate)
        end                                                     as FiscalYear

    from date_spine
)

select
    DateKey,
    FullDate,
    DayOfWeek,
    DayName,
    DayOfMonth,
    DayOfYear,
    WeekOfYear,
    MonthNumber,
    MonthName,
    Quarter,
    QuarterName,
    Year,
    IsWeekend,
    FiscalMonth,
    FiscalQuarter,
    FiscalYear
from date_attributes
