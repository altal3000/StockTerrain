with source as (
    select * from {{ source('raw_stock_data', 'raw') }}
),

renamed as (
    select
        cast(date as date) as observation_date,
        "btc-usd" as btc_usd,
        "eth-usd" as eth_usd,
        "gc=f" as gold,
        "hg=f" as copper,
        "si=f" as silver,
        "sol-usd" as solana,
        "^ftse" as ftse_100,
        "^gspc" as sp_500,
        "^ndx" as nasdaq_100
    from source
)

select * from renamed