-- models/marts/dim_customers.sql
-- Dimension table: one row per customer
-- Used by MetricFlow as a dimension source

with customers as (
    select * from {{ ref('stg_customers') }}
),

final as (
    select
        -- Primary key (used as entity in MetricFlow)
        customer_id,

        -- Descriptive attributes (dimensions in MetricFlow)
        customer_name,
        email,
        country,
        city,
        customer_segment,

        -- Derived dimensions
        case
            when customer_segment = 'corporate'    then 'B2B'
            when customer_segment = 'consumer'     then 'B2C'
            when customer_segment = 'home office'  then 'B2C'
            else 'Unknown'
        end as business_type,

        -- Dates
        created_at,
        updated_at,

        -- Is the customer active (created in last 365 days)?
        case
            when datediff(current_date(), date(created_at)) <= 365
            then true
            else false
        end as is_new_customer

    from customers
)

select * from final
