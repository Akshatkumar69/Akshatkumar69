{{ config(materialized='table') }}

with date_spine as (

    select explode(
        sequence(
            to_date('2020-01-01'),
            to_date('2035-12-31'),
            interval 1 day
        )
    ) as date_day

)

select *
from date_spine