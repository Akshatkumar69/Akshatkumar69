-- tests/assert_no_future_order_dates.sql
-- Custom test: no orders should have a future ordered_at date

select
    order_id,
    ordered_at
from {{ ref('fct_orders') }}
where ordered_at > current_timestamp()
