-- analyses/revenue_sanity_check.sql
-- Run: dbt compile --select revenue_sanity_check
-- Then paste the compiled SQL into Databricks to verify numbers

select
    order_month,
    order_year,
    city,
    count(distinct order_id)        as total_orders,
    count(distinct customer_id)     as unique_customers,
    sum(revenue)                    as total_revenue,
    avg(revenue)                    as avg_order_value,
    sum(case when is_completed then 1 else 0 end)   as completed,
    sum(case when is_returned  then 1 else 0 end)   as returned
from {{ ref('fct_orders') }}
group by
    order_month,
    order_year,
    city
order by
    order_year  desc,
    order_month desc,
    total_revenue desc
