with source as (
    -- Use the tickers identified in your staging file
    select distinct ticker from {{ ref('fct_market_trends') }}
),

categorized as (
    select
        ticker,
        case 
            when ticker in ('BTC', 'ETH', 'Solana') then 'Crypto'
            when ticker in ('Gold', 'Silver', 'Copper') then 'Commodity'
            when ticker in ('S&P 500', 'Nasdaq 100', 'FTSE 100') then 'Equity Index'
            else 'Other'
        end as asset_class
    from source
)

select * from categorized