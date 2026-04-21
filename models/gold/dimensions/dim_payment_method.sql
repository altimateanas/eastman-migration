/*
  Dimension: Payment Method
  Migrated from: TRANSFORMED.usp_LoadDimPaymentMethod
  Purpose: Reference dimension of distinct payment methods with category classification
  Grain: One row per unique payment method
  Notes:
    - SELECT DISTINCT from payments to extract unique methods
    - CASE statement for PaymentCategory grouping
    - NULL payment methods filtered out
    - Column names preserved exactly from SQL Server
*/

{{ config(
    materialized='table',
    schema='gold',
    tags=['gold', 'dimension']
) }}

with payments as (
    select * from {{ ref('stg_payments') }}
),

distinct_methods as (
    select distinct
        PaymentMethod,
        case
            when PaymentMethod in ('CreditCard', 'DebitCard') then 'Card'
            when PaymentMethod = 'Cash'                       then 'Physical'
            when PaymentMethod = 'DigitalWallet'              then 'Digital'
            when PaymentMethod = 'BankTransfer'               then 'Transfer'
            else 'Other'
        end                                                   as PaymentCategory
    from payments
    where PaymentMethod is not null
)

select
    PaymentMethod,
    PaymentCategory
from distinct_methods
