/*
  Model: stg_payments
  Layer: Silver
  Purpose: Cleansed payment transaction data from raw.seed_raw_payments.
  Grain: One row per payment transaction. Rows with NULL PaymentMethod are excluded.
  Source: raw.seed_raw_payments
*/

WITH source AS (

    SELECT
        PaymentID,
        OrderID,
        PaymentDate,
        PaymentMethod,
        Amount,
        Currency,
        PaymentStatus,
        TransactionRef
    FROM {{ source('raw', 'seed_raw_payments') }}
    WHERE PaymentMethod IS NOT NULL

),

cleaned AS (

    SELECT
        PaymentID                               AS payment_id,
        OrderID                                 AS order_id,
        CAST(PaymentDate AS DATETIME2)          AS payment_date,
        LTRIM(RTRIM(PaymentMethod))             AS payment_method,
        CAST(Amount AS DECIMAL(18, 4))          AS amount,
        LTRIM(RTRIM(Currency))                  AS currency,
        LTRIM(RTRIM(PaymentStatus))             AS payment_status,
        LTRIM(RTRIM(TransactionRef))            AS transaction_ref
    FROM source

)

SELECT * FROM cleaned
