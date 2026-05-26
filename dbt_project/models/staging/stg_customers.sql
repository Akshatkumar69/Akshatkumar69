-- models/staging/stg_customers.sql
-- Source: workspace.default.customers
-- Real columns: customer_id (int), customer_name (string), city (string), signup_date (date)

with source as (
    select * from {{ source('raw', 'customers') }}
),

cleaned as (
    select
        -- Primary key
        cast(customer_id as bigint)         as customer_id,

        -- Attributes
        coalesce(
            trim(customer_name), 'Unknown'
        )                                   as customer_name,
        coalesce(trim(city), 'Unknown')     as city,

        -- Date
        cast(signup_date as date)           as signup_date

    from source
    where customer_id is not null
)

select * from cleaned
