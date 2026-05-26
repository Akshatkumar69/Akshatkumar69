-- models/staging/stg_orders.sql
-- Staging layer: light cleaning of raw orders data
-- Source: raw orders table in Databricks

with source as (
    select * from {{ source('raw', 'orders') }}
),

renamed as (
    select
        -- IDs
        cast(id as bigint)              as order_id,
        cast(customer_id as bigint)     as customer_id,

        -- Attributes
        lower(trim(status))             as order_status,       -- e.g. 'completed', 'returned', 'pending'
        lower(trim(payment_method))     as payment_method,     -- e.g. 'credit_card', 'bank_transfer'

        -- Amounts
        cast(amount as double)          as amount,
        cast(discount as double)        as discount,
        cast(quantity as int)           as quantity,

        -- Dates
        cast(ordered_at as timestamp)   as ordered_at,
        cast(shipped_at as timestamp)   as shipped_at,
        cast(delivered_at as timestamp) as delivered_at

    from source
    where id is not null
      and customer_id is not null
      and amount >= 0
)

select * from renamed
