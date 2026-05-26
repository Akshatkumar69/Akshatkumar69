-- models/marts/gold_sales_summary.sql
-- Gold layer: monthly sales summary per customer
-- Built on top of fct_orders + dim_customers

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
        c.city,
        c.is_new_customer,

        o.order_month,
        o.order_year,
        o.order_quarter,

        -- Order counts
        count(distinct o.order_id)                              as total_orders,
        count(distinct case
            when o.is_completed then o.order_id
        end)                                                    as completed_orders,
        count(distinct case
            when o.is_returned  then o.order_id
        end)                                                    as returned_orders,

        -- Revenue metrics
        sum(o.revenue)                                          as total_revenue,
        avg(o.revenue)                                          as avg_order_value,
        min(o.revenue)                                          as min_order_value,
        max(o.revenue)                                          as max_order_value,

        -- Date range
        min(o.order_date)                                       as first_order_date,
        max(o.order_date)                                       as last_order_date

    from fct_orders o
    left join dim_customers c
        on o.customer_id = c.customer_id
    group by
        o.customer_id,
        c.customer_name,
        c.city,
        c.is_new_customer,
        o.order_month,
        o.order_year,
        o.order_quarter
)

select * from monthly_sales
