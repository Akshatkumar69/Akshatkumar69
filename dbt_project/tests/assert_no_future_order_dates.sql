-- tests/assert_no_future_order_dates.sql
select order_id, order_date
from {{ ref('fct_orders') }}
where order_date > current_date()
