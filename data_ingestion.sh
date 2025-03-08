#!/bin/bash

DATA_URL="https://www.nyc.gov/assets/tlc/downloads/csv/data_reports_monthly.csv"
LOCAL_FILE="taxi_data_$(date +'%Y-%m').csv"
HDFS_DIR="/user/hive/warehouse/taxi_data/"

echo "🚀 Starting NYC Taxi Data Pipeline - $(date)"

echo "📥 Downloading $DATA_URL..."
wget -O $LOCAL_FILE $DATA_URL

echo "🛠 Cleaning data - Removing header row..."
tail -n +2 $LOCAL_FILE > cleaned_$LOCAL_FILE

echo "📤 Uploading to HDFS..."
hdfs dfs -put -f cleaned_$LOCAL_FILE $HDFS_DIR

echo "✅ Data Pipeline Completed Successfully!"

