-- models/staging/stg_orders.sql
-- Source: workspace.default.orders
-- Real columns: order_id (int), customer_id (int), order_date (date), amount (double), status (string)

with source as (
    select * from {{ source('raw', 'orders') }}
),

cleaned as (
    select
        -- Primary key
        cast(order_id as bigint)            as order_id,

        -- Foreign key
        cast(customer_id as bigint)         as customer_id,

        -- Date (this will be the MetricFlow time dimension)
        cast(order_date as date)            as order_date,

        -- Amount
        cast(amount as double)              as amount,

        -- Status — renamed from 'status' to 'order_status' (avoids SQL reserved word)
        lower(trim(status))                 as order_status

    from source
    where order_id is not null
      and customer_id is not null
      and amount >= 0
)

select * from cleaned
