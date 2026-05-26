-- models/marts/gold_sales_summary.sql
-- Gold layer: pre-aggregated sales summary by customer and month
-- Good for dashboards and reporting

with fct_orders as (
    select * from {{ ref('fct_orders') }}
),

dim_customers as (
    select * from {{ ref('dim_customers') }}
),

monthly_sales as (
    select
        o.customer_id,
        c.customer_name,
        c.customer_segment,
        c.country,
        c.city,
        c.business_type,

        o.order_month,
        o.order_year,
        o.order_quarter,

        -- Aggregated measures
        count(distinct o.order_id)              as total_orders,
        count(distinct case
            when o.is_completed then o.order_id
        end)                                    as completed_orders,
        count(distinct case
            when o.is_returned then o.order_id
        end)                                    as returned_orders,

        sum(o.revenue)                          as gross_revenue,
        sum(o.net_revenue)                      as net_revenue,
        sum(o.discount_amount)                  as total_discounts,
        sum(o.quantity)                         as total_units,

        avg(o.revenue)                          as avg_order_value,
        min(o.revenue)                          as min_order_value,
        max(o.revenue)                          as max_order_value,

        -- First and last order dates
        min(o.order_date)                       as first_order_date,
        max(o.order_date)                       as last_order_date

    from fct_orders o
    left join dim_customers c
        on o.customer_id = c.customer_id
    group by
        o.customer_id,
        c.customer_name,
        c.customer_segment,
        c.country,
        c.city,
        c.business_type,
        o.order_month,
        o.order_year,
        o.order_quarter
)

select * from monthly_sales
