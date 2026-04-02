/*
  Model: dim_payment_method
  Layer: Gold — Dimension
  Purpose: Distinct payment methods with a payment category grouping.
  Grain: One row per unique payment method.
  Source: silver.stg_payments
  Mirrors: TRANSFORMED.DimPaymentMethod (usp_LoadDimPaymentMethod)
*/

WITH payments AS (

    SELECT DISTINCT
        payment_method
    FROM {{ ref('stg_payments') }}
    WHERE payment_method IS NOT NULL

),

enriched AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['payment_method']) }}   AS payment_method_key,
        payment_method,
        CASE
            WHEN payment_method IN ('CreditCard', 'DebitCard')  THEN 'Card'
            WHEN payment_method = 'Cash'                        THEN 'Physical'
            WHEN payment_method = 'DigitalWallet'               THEN 'Digital'
            WHEN payment_method = 'BankTransfer'                THEN 'Transfer'
            ELSE 'Other'
        END                                                          AS payment_category,
        CAST(GETDATE() AS DATETIME2(6))                              AS dw_created_at,
        CAST(GETDATE() AS DATETIME2(6))                              AS dw_updated_at
    FROM payments

)

SELECT * FROM enriched
