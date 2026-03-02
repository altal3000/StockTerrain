with base as (
    select * from {{ ref('stg_stock_prices') }}
),

-- Step 1: Unpivot columns into rows
unpivoted as (
    select observation_date, 'BTC' as ticker, btc_usd as price from base union all
    select observation_date, 'ETH', eth_usd from base union all
    select observation_date, 'Gold', gold from base union all
    select observation_date, 'Copper', copper from base union all
    select observation_date, 'Silver', silver from base union all
    select observation_date, 'Solana', solana from base union all
    select observation_date, 'FTSE 100', ftse_100 from base union all
    select observation_date, 'S&P 500', sp_500 from base union all
    select observation_date, 'Nasdaq 100', nasdaq_100 from base
),

-- Step 2: Single calculation logic
final_metrics as (
    select
        observation_date,
        ticker,
        price,
        (price - lag(price, 1) over (partition by ticker order by observation_date)) / nullif(lag(price, 1) over (partition by ticker order by observation_date), 0) as daily_change,
        (price - lag(price, 30) over (partition by ticker order by observation_date)) / nullif(lag(price, 30) over (partition by ticker order by observation_date), 0) as mom,
        (price - lag(price, 365) over (partition by ticker order by observation_date)) / nullif(lag(price, 365) over (partition by ticker order by observation_date), 0) as yoy,
        stddev_samp(price) over (partition by ticker order by observation_date rows between 29 preceding and current row) as vol_30d,
        avg(price) over (partition by ticker order by observation_date rows between 49 preceding and current row) as mavg_50,
        avg(price) over (partition by ticker order by observation_date rows between 199 preceding and current row) as mavg_200
    from unpivoted
)

select * from final_metrics