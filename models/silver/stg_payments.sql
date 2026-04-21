/*
  Staging: Payments
  Source: RAW.Payments (seed_raw_payments)
  Purpose: 1:1 staging of payment transaction data with type casting
  Grain: One row per payment
*/

with source as (
    select * from {{ source('raw', 'seed_raw_payments') }}
),

staged as (
    select
        cast(PaymentID as int)              as PaymentID,
        cast(OrderID as int)                as OrderID,
        cast(PaymentDate as date)           as PaymentDate,
        cast(PaymentMethod as varchar)      as PaymentMethod,
        cast(Amount as decimal(18,2))       as Amount,
        cast(Currency as varchar)           as Currency,
        cast(PaymentStatus as varchar)      as PaymentStatus,
        cast(TransactionRef as varchar)     as TransactionRef
    from source
)

select * from staged
