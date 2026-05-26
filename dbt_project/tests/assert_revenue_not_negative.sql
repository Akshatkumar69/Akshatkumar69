-- tests/assert_revenue_not_negative.sql
select order_id, revenue
from {{ ref('fct_orders') }}
where revenue < 0
