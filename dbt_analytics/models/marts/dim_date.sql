with date_series as (
    select 
        date_add('day', seq - 1, date '2024-01-01') as observation_date
    from (
        select row_number() over () as seq 
        from {{ ref('fct_market_trends') }}
    )
    where seq <= 800
)

select
    observation_date,
    year(observation_date) as year,
    month(observation_date) as month_num,
    format_datetime(observation_date, 'MMMM') as month_name,
    'Q' || cast(quarter(observation_date) as varchar) as quarter,
    case when day_of_week(observation_date) in (6, 7) then 'Weekend' else 'Weekday' end as day_type
from date_series