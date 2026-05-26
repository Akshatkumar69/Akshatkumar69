-- analyses/revenue_sanity_check.sql
-- Quick sanity check analysis — run with: dbt compile then paste SQL into Databricks

select
    order_month,
    order_year,
    customer_segment,
    country,
    count(distinct order_id)        as total_orders,
    count(distinct customer_id)     as unique_customers,
    sum(revenue)                    as gross_revenue,
    sum(net_revenue)                as net_revenue,
    sum(discount_amount)            as total_discounts,
    avg(revenue)                    as avg_order_value,
    sum(case when is_completed then 1 else 0 end)   as completed_orders,
    sum(case when is_returned  then 1 else 0 end)   as returned_orders
from {{ ref('fct_orders') }}
group by
    order_month,
    order_year,
    customer_segment,
    country
order by
    order_year desc,
    order_month desc,
    gross_revenue desc
