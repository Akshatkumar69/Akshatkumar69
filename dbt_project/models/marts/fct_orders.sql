-- models/marts/fct_orders.sql
-- Fact table: one row per order
-- Real columns: order_id, customer_id, order_date, amount, status
-- This is the PRIMARY table MetricFlow uses for all revenue/order metrics

with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

final as (
    select
        -- Primary key (entity in MetricFlow)
        o.order_id,

        -- Foreign key (joins to dim_customers in MetricFlow)
        o.customer_id,

        -- Measures (raw numbers MetricFlow will aggregate)
        o.amount                                            as revenue,

        -- Dimensions on the fact itself
        o.order_status,

        -- Derived flag dimensions
        case when o.order_status = 'completed' then true
             else false end                                 as is_completed,

        case when o.order_status = 'returned'  then true
             else false end                                 as is_returned,

        -- Denormalized customer dimensions (for convenience)
        c.customer_name,
        c.city,

        -- Time dimensions — MetricFlow REQUIRES a timestamp/date column
        -- order_date is DATE type, cast to timestamp for MetricFlow compatibility
        cast(o.order_date as timestamp)                     as ordered_at,
        o.order_date,
        date_format(o.order_date, 'yyyy-MM')                as order_month,
        year(o.order_date)                                  as order_year,
        quarter(o.order_date)                               as order_quarter

    from orders o
    left join customers c
        on o.customer_id = c.customer_id
)

select * from final
