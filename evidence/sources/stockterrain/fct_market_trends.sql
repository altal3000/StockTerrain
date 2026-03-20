select 
    observation_date,
    ticker,
    price,
    daily_change,
    mom,
    yoy,
    vol_30d,
    mavg_50,
    mavg_200,
    case when is_latest = true then 1 else 0 end as is_latest,
    case when is_previous = true then 1 else 0 end as is_previous
from analytics.fct_market_trends