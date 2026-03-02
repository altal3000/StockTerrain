import yfinance as yf
import boto3
import pandas as pd
from datetime import datetime, timedelta

# Your indices map
INDICES = {
    '^GSPC': 'S&P_500', '^NDX': 'Nasdaq_100', '^FTSE': 'FTSE_100',
    'BTC-USD': 'Bitcoin', 'ETH-USD': 'Ethereum', 'SOL-USD': 'Solana',
    'GC=F': 'Gold', 'SI=F': 'Silver', 'HG=F': 'Copper'
}

def sync_data():
    # 1. Fetch recent history (5d ensures we have context for the reindex)
    data = yf.download(list(INDICES.keys()), period="5d", interval="1d")
    df = data['Close']
    
    # 2. Target "Yesterday" (The full day that just finished)
    yesterday_date = (datetime.now() - timedelta(days=1)).date()
    yesterday_ts = pd.Timestamp(yesterday_date)
    
    # 3. FORCE the row to exist for yesterday
    # If yesterday was a weekend, reindex creates the row with NaN for stocks
    # If it was a crypto day, it preserves the crypto numbers
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

if __name__ == "__main__":
    sync_data()