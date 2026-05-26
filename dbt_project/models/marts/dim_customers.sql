-- models/marts/dim_customers.sql
-- Dimension table: one row per customer
-- Columns available: customer_id, customer_name, city, signup_date

with customers as (
    select * from {{ ref('stg_customers') }}
),

final as (
    select
        -- Primary key (entity in MetricFlow)
        customer_id,

        -- Dimensions
        customer_name,
        city,

        -- Date dimensions
        signup_date,
        date_format(signup_date, 'yyyy-MM')         as signup_month,
        year(signup_date)                            as signup_year,

        -- Derived: is the customer new (signed up in last 365 days)?
        case
            when datediff(current_date(), signup_date) <= 365
            then true
            else false
        end                                          as is_new_customer

    from customers
)

select * from final
