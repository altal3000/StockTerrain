---
title: StockTerrain
sidebar: never
hide_toc: true
hide_breadcrumbs: true
---
```sql latest
select 
    ticker,
    observation_date,
    price,
    daily_change
from stockterrain.fct_market_trends
where is_latest = 1
order by ticker
```
```sql sparkline_data
select 
    ticker,
    observation_date,
    price
from stockterrain.fct_market_trends
where observation_date >= (
    select max(observation_date) - interval '10 days'
    from stockterrain.fct_market_trends
)
order by ticker, observation_date
```

<Tabs>

<Tab label="Crypto">

<Grid cols=3>

{#each latest.filter(d => d.ticker === 'BTC') as row}
<div style="border: 1px solid #e5e7eb; border-radius: 8px; padding: 20px; display: flex; flex-direction: column;">
  <div style="font-size: 0.9rem; color: #6b7280;">{new Date(row.observation_date).toLocaleDateString('en-GB')}</div>
  <div style="font-size: 1.4rem; font-weight: 600; margin-top: 6px;">BTC</div>
  <div style="font-size: 3rem; font-weight: 700; margin-top: 6px; line-height: 1;">${row.price.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2})}</div>
  <div style="font-size: 1.1rem; color: {row.daily_change >= 0 ? '#16a34a' : '#dc2626'}; margin-top: 8px;">
    {row.daily_change >= 0 ? '▲' : '▼'} {(row.daily_change * 100).toFixed(2)}% DoD
  </div>
  <div style="margin-top: 16px;">
    <AreaChart data={sparkline_data.filter(d => d.ticker === 'BTC')} x=observation_date y=price lineColor=#3b82f6 fillColor=#bfdbfe xAxisLabels=false yAxisLabels=false gridlines=false yGridlines=false height=50 xFmt="dd/mm/yyyy" yScale=true/>
  </div>
  <div style="margin-top: 12px; text-align: center;">
    <a href="/btc" style="display: inline-block; font-size: 0.85rem; color: #6b7280; text-decoration: none; border: 1px solid #6b7280; border-radius: 4px; padding: 4px 12px;">BTC Details →</a>
  </div>
</div>
{/each}

{#each latest.filter(d => d.ticker === 'ETH') as row}
<div style="border: 1px solid #e5e7eb; border-radius: 8px; padding: 20px; display: flex; flex-direction: column;">
  <div style="font-size: 0.9rem; color: #6b7280;">{new Date(row.observation_date).toLocaleDateString('en-GB')}</div>
  <div style="font-size: 1.4rem; font-weight: 600; margin-top: 6px;">ETH</div>
  <div style="font-size: 3rem; font-weight: 700; margin-top: 6px; line-height: 1;">${row.price.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2})}</div>
  <div style="font-size: 1.1rem; color: {row.daily_change >= 0 ? '#16a34a' : '#dc2626'}; margin-top: 8px;">
    {row.daily_change >= 0 ? '▲' : '▼'} {(row.daily_change * 100).toFixed(2)}% DoD
  </div>
  <div style="margin-top: 16px;">
    <AreaChart data={sparkline_data.filter(d => d.ticker === 'ETH')} x=observation_date y=price lineColor=#3b82f6 fillColor=#bfdbfe xAxisLabels=false yAxisLabels=false gridlines=false yGridlines=false height=50 xFmt="dd/mm/yyyy" yScale=true/>
  </div>
  <div style="margin-top: 12px; text-align: center;">
    <a href="/eth" style="display: inline-block; font-size: 0.85rem; color: #6b7280; text-decoration: none; border: 1px solid #6b7280; border-radius: 4px; padding: 4px 12px;">ETH Details →</a>
  </div>
</div>
{/each}

{#each latest.filter(d => d.ticker === 'Solana') as row}
<div style="border: 1px solid #e5e7eb; border-radius: 8px; padding: 20px; display: flex; flex-direction: column;">
  <div style="font-size: 0.9rem; color: #6b7280;">{new Date(row.observation_date).toLocaleDateString('en-GB')}</div>
  <div style="font-size: 1.4rem; font-weight: 600; margin-top: 6px;">Solana</div>
  <div style="font-size: 3rem; font-weight: 700; margin-top: 6px; line-height: 1;">${row.price.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2})}</div>
  <div style="font-size: 1.1rem; color: {row.daily_change >= 0 ? '#16a34a' : '#dc2626'}; margin-top: 8px;">
    {row.daily_change >= 0 ? '▲' : '▼'} {(row.daily_change * 100).toFixed(2)}% DoD
  </div>
  <div style="margin-top: 16px;">
    <AreaChart data={sparkline_data.filter(d => d.ticker === 'Solana')} x=observation_date y=price lineColor=#3b82f6 fillColor=#bfdbfe xAxisLabels=false yAxisLabels=false gridlines=false yGridlines=false height=50 xFmt="dd/mm/yyyy" yScale=true/>
  </div>
  <div style="margin-top: 12px; text-align: center;">
    <a href="/solana" style="display: inline-block; font-size: 0.85rem; color: #6b7280; text-decoration: none; border: 1px solid #6b7280; border-radius: 4px; padding: 4px 12px;">Solana Details →</a>
  </div>
</div>
{/each}

</Grid>

</Tab>

<Tab label="Stocks">

<Grid cols=3>

{#each latest.filter(d => d.ticker === 'S&P 500') as row}
<div style="border: 1px solid #e5e7eb; border-radius: 8px; padding: 20px; display: flex; flex-direction: column;">
  <div style="font-size: 0.9rem; color: #6b7280;">{new Date(row.observation_date).toLocaleDateString('en-GB')}</div>
  <div style="font-size: 1.4rem; font-weight: 600; margin-top: 6px;">S&P 500</div>
  <div style="font-size: 3rem; font-weight: 700; margin-top: 6px; line-height: 1;">${row.price.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2})}</div>
  <div style="font-size: 1.1rem; color: {row.daily_change >= 0 ? '#16a34a' : '#dc2626'}; margin-top: 8px;">
    {row.daily_change >= 0 ? '▲' : '▼'} {(row.daily_change * 100).toFixed(2)}% DoD
  </div>
  <div style="margin-top: 16px;">
    <AreaChart data={sparkline_data.filter(d => d.ticker === 'S&P 500')} x=observation_date y=price lineColor=#3b82f6 fillColor=#bfdbfe xAxisLabels=false yAxisLabels=false gridlines=false yGridlines=false height=50 xFmt="dd/mm/yyyy" yScale=true/>
  </div>
  <div style="margin-top: 12px; text-align: center;">
    <a href="/sp500" style="display: inline-block; font-size: 0.85rem; color: #6b7280; text-decoration: none; border: 1px solid #6b7280; border-radius: 4px; padding: 4px 12px;">S&P 500 Details →</a>
  </div>
</div>
{/each}

{#each latest.filter(d => d.ticker === 'Nasdaq 100') as row}
<div style="border: 1px solid #e5e7eb; border-radius: 8px; padding: 20px; display: flex; flex-direction: column;">
  <div style="font-size: 0.9rem; color: #6b7280;">{new Date(row.observation_date).toLocaleDateString('en-GB')}</div>
  <div style="font-size: 1.4rem; font-weight: 600; margin-top: 6px;">Nasdaq 100</div>
  <div style="font-size: 3rem; font-weight: 700; margin-top: 6px; line-height: 1;">${row.price.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2})}</div>
  <div style="font-size: 1.1rem; color: {row.daily_change >= 0 ? '#16a34a' : '#dc2626'}; margin-top: 8px;">
    {row.daily_change >= 0 ? '▲' : '▼'} {(row.daily_change * 100).toFixed(2)}% DoD
  </div>
  <div style="margin-top: 16px;">
    <AreaChart data={sparkline_data.filter(d => d.ticker === 'Nasdaq 100')} x=observation_date y=price lineColor=#3b82f6 fillColor=#bfdbfe xAxisLabels=false yAxisLabels=false gridlines=false yGridlines=false height=50 xFmt="dd/mm/yyyy" yScale=true/>
  </div>
  <div style="margin-top: 12px; text-align: center;">
    <a href="/nasdaq" style="display: inline-block; font-size: 0.85rem; color: #6b7280; text-decoration: none; border: 1px solid #6b7280; border-radius: 4px; padding: 4px 12px;">Nasdaq 100 Details →</a>
  </div>
</div>
{/each}

{#each latest.filter(d => d.ticker === 'FTSE 100') as row}
<div style="border: 1px solid #e5e7eb; border-radius: 8px; padding: 20px; display: flex; flex-direction: column;">
  <div style="font-size: 0.9rem; color: #6b7280;">{new Date(row.observation_date).toLocaleDateString('en-GB')}</div>
  <div style="font-size: 1.4rem; font-weight: 600; margin-top: 6px;">FTSE 100</div>
  <div style="font-size: 3rem; font-weight: 700; margin-top: 6px; line-height: 1;">${row.price.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2})}</div>
  <div style="font-size: 1.1rem; color: {row.daily_change >= 0 ? '#16a34a' : '#dc2626'}; margin-top: 8px;">
    {row.daily_change >= 0 ? '▲' : '▼'} {(row.daily_change * 100).toFixed(2)}% DoD
  </div>
  <div style="margin-top: 16px;">
    <AreaChart data={sparkline_data.filter(d => d.ticker === 'FTSE 100')} x=observation_date y=price lineColor=#3b82f6 fillColor=#bfdbfe xAxisLabels=false yAxisLabels=false gridlines=false yGridlines=false height=50 xFmt="dd/mm/yyyy" yScale=true/>
  </div>
  <div style="margin-top: 12px; text-align: center;">
    <a href="/ftse" style="display: inline-block; font-size: 0.85rem; color: #6b7280; text-decoration: none; border: 1px solid #6b7280; border-radius: 4px; padding: 4px 12px;">FTSE 100 Details →</a>
  </div>
</div>
{/each}

</Grid>

</Tab>

<Tab label="Metals">

<Grid cols=3>

{#each latest.filter(d => d.ticker === 'Gold') as row}
<div style="border: 1px solid #e5e7eb; border-radius: 8px; padding: 20px; display: flex; flex-direction: column;">
  <div style="font-size: 0.9rem; color: #6b7280;">{new Date(row.observation_date).toLocaleDateString('en-GB')}</div>
  <div style="font-size: 1.4rem; font-weight: 600; margin-top: 6px;">Gold</div>
  <div style="font-size: 3rem; font-weight: 700; margin-top: 6px; line-height: 1;">${row.price.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2})}</div>
  <div style="font-size: 1.1rem; color: {row.daily_change >= 0 ? '#16a34a' : '#dc2626'}; margin-top: 8px;">
    {row.daily_change >= 0 ? '▲' : '▼'} {(row.daily_change * 100).toFixed(2)}% DoD
  </div>
  <div style="margin-top: 16px;">
    <AreaChart data={sparkline_data.filter(d => d.ticker === 'Gold')} x=observation_date y=price lineColor=#3b82f6 fillColor=#bfdbfe xAxisLabels=false yAxisLabels=false gridlines=false yGridlines=false height=50 xFmt="dd/mm/yyyy" yScale=true/>
  </div>
  <div style="margin-top: 12px; text-align: center;">
    <a href="/gold" style="display: inline-block; font-size: 0.85rem; color: #6b7280; text-decoration: none; border: 1px solid #6b7280; border-radius: 4px; padding: 4px 12px;">Gold Details →</a>
  </div>
</div>
{/each}

{#each latest.filter(d => d.ticker === 'Silver') as row}
<div style="border: 1px solid #e5e7eb; border-radius: 8px; padding: 20px; display: flex; flex-direction: column;">
  <div style="font-size: 0.9rem; color: #6b7280;">{new Date(row.observation_date).toLocaleDateString('en-GB')}</div>
  <div style="font-size: 1.4rem; font-weight: 600; margin-top: 6px;">Silver</div>
  <div style="font-size: 3rem; font-weight: 700; margin-top: 6px; line-height: 1;">${row.price.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2})}</div>
  <div style="font-size: 1.1rem; color: {row.daily_change >= 0 ? '#16a34a' : '#dc2626'}; margin-top: 8px;">
    {row.daily_change >= 0 ? '▲' : '▼'} {(row.daily_change * 100).toFixed(2)}% DoD
  </div>
  <div style="margin-top: 16px;">
    <AreaChart data={sparkline_data.filter(d => d.ticker === 'Silver')} x=observation_date y=price lineColor=#3b82f6 fillColor=#bfdbfe xAxisLabels=false yAxisLabels=false gridlines=false yGridlines=false height=50 xFmt="dd/mm/yyyy" yScale=true/>
  </div>
  <div style="margin-top: 12px; text-align: center;">
    <a href="/silver" style="display: inline-block; font-size: 0.85rem; color: #6b7280; text-decoration: none; border: 1px solid #6b7280; border-radius: 4px; padding: 4px 12px;">Silver Details →</a>
  </div>
</div>
{/each}

{#each latest.filter(d => d.ticker === 'Copper') as row}
<div style="border: 1px solid #e5e7eb; border-radius: 8px; padding: 20px; display: flex; flex-direction: column;">
  <div style="font-size: 0.9rem; color: #6b7280;">{new Date(row.observation_date).toLocaleDateString('en-GB')}</div>
  <div style="font-size: 1.4rem; font-weight: 600; margin-top: 6px;">Copper</div>
  <div style="font-size: 3rem; font-weight: 700; margin-top: 6px; line-height: 1;">${row.price.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2})}</div>
  <div style="font-size: 1.1rem; color: {row.daily_change >= 0 ? '#16a34a' : '#dc2626'}; margin-top: 8px;">
    {row.daily_change >= 0 ? '▲' : '▼'} {(row.daily_change * 100).toFixed(2)}% DoD
  </div>
  <div style="margin-top: 16px;">
    <AreaChart data={sparkline_data.filter(d => d.ticker === 'Copper')} x=observation_date y=price lineColor=#3b82f6 fillColor=#bfdbfe xAxisLabels=false yAxisLabels=false gridlines=false yGridlines=false height=50 xFmt="dd/mm/yyyy" yScale=true/>
  </div>
  <div style="margin-top: 12px; text-align: center;">
    <a href="/copper" style="display: inline-block; font-size: 0.85rem; color: #6b7280; text-decoration: none; border: 1px solid #6b7280; border-radius: 4px; padding: 4px 12px;">Copper Details →</a>
  </div>
</div>
{/each}

</Grid>

</Tab>

</Tabs>