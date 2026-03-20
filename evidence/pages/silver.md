---
title: Silver
sidebar: never
hide_toc: true
hide_breadcrumbs: true
---

```sql silver_latest
select
    observation_date,
    day_type,
    price,
    daily_change,
    mom,
    yoy,
    vol_30d,
    mavg_50,
    mavg_200
from stockterrain.silver_data
where is_latest = 1
```

```sql silver_previous
select
    observation_date,
    price
from stockterrain.silver_data
where is_previous = 1
```

```sql silver_dod
select
    observation_date,
    daily_change
from stockterrain.silver_data
order by observation_date desc
limit 30
```

```sql silver_year
select
    observation_date,
    price,
    mavg_50,
    mavg_200
from stockterrain.silver_data
order by observation_date desc
limit 365
```

<a href="/" style="font-size: 0.9rem; color: #6b7280; text-decoration: none;">← Back</a>

## Silver

<DataTable data={silver_latest}>
    <Column id=observation_date title="Last Date" fmt="dd/mm/yyyy"/>
    <Column id=day_type title="Day Type"/>
    <Column id=price title="Close Price ($)" fmt=num2/>
    <Column id=daily_change title="Day-over-Day" fmt=pct2/>
    <Column id=mom title="Month-over-Month" fmt=pct2/>
    <Column id=yoy title="Year-over-Year" fmt=pct2/>
    <Column id=vol_30d title="30d Volatility" fmt=pct2/>
    <Column id=mavg_50 title="MA 50 ($)" fmt=num2/>
    <Column id=mavg_200 title="MA 200 ($)" fmt=num2/>
</DataTable>

<div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 24px; align-items: stretch;">

<div style="display: flex; flex-direction: column; gap: 16px;">

{#if silver_latest.length > 0}
<div style="border: 1px solid #e5e7eb; border-radius: 8px; padding: 28px; min-height: 220px;">
  <div style="font-size: 0.9rem; color: #6b7280;">Last Date Close</div>
  <div style="font-size: 0.85rem; color: #6b7280; margin-top: 8px;">{new Date(silver_latest[0]?.observation_date).toLocaleDateString('en-GB')}</div>
  <div style="font-size: 3.2rem; font-weight: 700; margin-top: 12px; line-height: 1;">${silver_latest[0]?.price?.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2})}</div>
  <div style="font-size: 1rem; color: {silver_latest[0]?.daily_change >= 0 ? '#16a34a' : '#dc2626'}; margin-top: 12px;">
    {silver_latest[0]?.daily_change >= 0 ? '▲' : '▼'} {((silver_latest[0]?.daily_change ?? 0) * 100).toFixed(2)}% DoD
  </div>
</div>
{/if}

<div style="border: 1px solid #e5e7eb; border-radius: 8px; padding: 16px 24px 8px 24px;">
  <div style="font-size: 0.9rem; color: #6b7280; margin-bottom: 8px;">Previous Date Close</div>
  <DataTable data={silver_previous}>
    <Column id=observation_date title="Date" fmt="dd/mm/yyyy"/>
    <Column id=price title="Price ($)" fmt=num2/>
  </DataTable>
</div>

</div>

<div style="border: 1px solid #e5e7eb; border-radius: 8px; padding: 28px;">
  <div style="font-size: 0.9rem; color: #6b7280; margin-bottom: 8px;">DoD across Last Month</div>
  <BarChart data={silver_dod} x=observation_date y=daily_change yFmt=pct2 xFmt="dd/mm/yyyy" xAxisLabels=false yGridlines=false chartAreaHeight=220/>
</div>

<div style="border: 1px solid #e5e7eb; border-radius: 8px; padding: 28px;">
  <div style="font-size: 0.9rem; color: #6b7280; margin-bottom: 8px;">Close Price and Moving Averages — Last Year</div>
  <LineChart data={silver_year} x=observation_date y={['price', 'mavg_50', 'mavg_200']} xFmt="dd/mm/yyyy" yGridlines=false yScale=true chartAreaHeight=220/>
</div>

</div>
