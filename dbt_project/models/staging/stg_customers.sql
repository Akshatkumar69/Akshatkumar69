-- models/staging/stg_customers.sql
-- Staging layer: light cleaning of raw customer data
-- Source: raw customers table in Databricks

with source as (
    select * from {{ source('raw', 'customers') }}
),

renamed as (
    select
        -- IDs
        cast(id as bigint)              as customer_id,

        -- Attributes
        coalesce(name, 'Unknown')       as customer_name,
        lower(trim(email))              as email,
        lower(trim(country))            as country,
        lower(trim(city))               as city,
        lower(trim(segment))            as customer_segment,   -- e.g. 'consumer', 'corporate', 'home office'

        -- Dates
        cast(created_at as timestamp)   as created_at,
        cast(updated_at as timestamp)   as updated_at

    from source
    where id is not null
)

select * from renamed
