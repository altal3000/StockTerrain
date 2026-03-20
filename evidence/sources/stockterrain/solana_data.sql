select
    cast(f.observation_date as date) as observation_date,
    f.ticker,
    f.price,
    f.daily_change,
    f.mom,
    f.yoy,
    f.vol_30d,
    f.mavg_50,
    f.mavg_200,
    d.day_type,
    case when f.is_latest = true then 1 else 0 end as is_latest,
    case when f.is_previous = true then 1 else 0 end as is_previous
from analytics.fct_market_trends f
join analytics.dim_date d on f.observation_date = d.observation_date
where f.ticker = 'Solana'
