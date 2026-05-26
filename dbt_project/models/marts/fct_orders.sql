-- models/marts/fct_orders.sql
-- Fact table: one row per order
-- This is the PRIMARY table used by MetricFlow for all order/revenue metrics

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

        -- Foreign key (entity join in MetricFlow)
        o.customer_id,

        -- Measures (used as measures in MetricFlow)
        o.amount                                        as revenue,
        o.discount                                      as discount_amount,
        o.quantity,
        o.amount - coalesce(o.discount, 0)              as net_revenue,

        -- Dimensions (on the fact table itself)
        o.order_status,
        o.payment_method,

        -- Derived dimensions
        case
            when o.order_status = 'completed'  then true
            else false
        end as is_completed,

        case
            when o.order_status = 'returned'   then true
            else false
        end as is_returned,

        -- Customer dimensions (denormalized for convenience)
        c.customer_segment,
        c.country,
        c.city,

        -- Time dimensions (MetricFlow needs a primary time dimension)
        o.ordered_at,
        date(o.ordered_at)                              as order_date,
        date_format(o.ordered_at, 'yyyy-MM')            as order_month,
        year(o.ordered_at)                              as order_year,
        quarter(o.ordered_at)                           as order_quarter,
        o.shipped_at,
        o.delivered_at

    from orders o
    left join customers c
        on o.customer_id = c.customer_id
)

select * from final
