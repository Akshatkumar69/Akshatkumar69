-- tests/assert_revenue_not_negative.sql
-- Custom test: revenue should never be negative

select
    order_id,
    revenue
from {{ ref('fct_orders') }}
where revenue < 0
