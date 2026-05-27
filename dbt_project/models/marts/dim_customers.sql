-- models/marts/dim_customers.sql
-- Dimension table: one row per customer
-- Columns available: customer_id, customer_name, city, signup_date

with customers as (
    select * from {{ ref('stg_customers') }}
),
select * from customers