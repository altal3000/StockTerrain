import yfinance as yf
import boto3
import pandas as pd
from datetime import datetime, timedelta

# Indices map
INDICES = {
    '^GSPC': 'S&P_500', '^NDX': 'Nasdaq_100', '^FTSE': 'FTSE_100',
    'BTC-USD': 'Bitcoin', 'ETH-USD': 'Ethereum', 'SOL-USD': 'Solana',
    'GC=F': 'Gold', 'SI=F': 'Silver', 'HG=F': 'Copper'
}

def sync_data():
    # 1. Fetch recent history (5d)
    data = yf.download(list(INDICES.keys()), period="5d", interval="1d")
    df = data['Close']

    # 2. Target the last full day
    yesterday_date = (datetime.now() - timedelta(days=1)).date()
    yesterday_ts = pd.Timestamp(yesterday_date)
    print(df.index)
    print(yesterday_ts)
    
    # 3. Force the row to exist for yesterday
    df_yesterday = df.reindex([yesterday_ts])

    # 4. Prepare file metadata
    date_str = yesterday_date.strftime('%Y-%m-%d')
    filename = f"market_data_{date_str}.csv"
    local_path = f"/tmp/{filename}"
    
    # 5. Save to local Lambda storage
    df_yesterday.to_csv(local_path, index_label="Date")

    # 6. Upload to S3
    s3 = boto3.client('s3')
    bucket_name = "stockterrain-datalake-2101b815" 
    s3.upload_file(local_path, bucket_name, f"raw/daily/{filename}")
    
    print(f"Sync complete: {filename} uploaded to S3.")

def lambda_handler(event, context):
    try:
        sync_data()
        return {"statusCode": 200, "body": "Success"}
    except Exception as e:
        print(f"Error: {str(e)}")
        return {"statusCode": 500, "body": str(e)}

def backfill_date(target_date_str):
    data = yf.download(list(INDICES.keys()), period="7d", interval="1d")
    df = data['Close']
    df.index = pd.to_datetime(df.index).normalize()
    
    target_ts = pd.Timestamp(target_date_str)
    
    if target_ts in df.index:
        df_target = df.loc[[target_ts]]
        filename = f"market_data_{target_date_str}.csv"
        local_path = f"/tmp/{filename}"
        df_target.to_csv(local_path, index_label="Date")
        
        s3 = boto3.client('s3')
        s3.upload_file(local_path, "stockterrain-datalake-2101b815", f"raw/daily/{filename}")
        print(f"Backfill complete: {filename}")
    else:
        print(f"No data found for {target_date_str}")

if __name__ == "__main__":
    backfill_date("2026-03-16")