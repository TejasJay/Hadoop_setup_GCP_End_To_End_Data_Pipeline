#!/bin/bash

LOG_FILE="~/logs/hive_queries.log"
EMAIL="tejastj33333@gmail.com"

# Get the current year and month
CURRENT_YEAR=$(date +'%Y')
CURRENT_MONTH=$(date +'%m')

# Define the CSV filename dynamically
CSV_FILE="/user/hive/warehouse/nyc_taxi/yellow_tripdata_${CURRENT_YEAR}-${CURRENT_MONTH}.csv"

# Generate a dynamic Hive query
HIVE_QUERY_FILE="~/hive_queries_dynamic.sql"

echo "🚀 Generating Hive Query for $CURRENT_YEAR-$CURRENT_MONTH" | tee -a $LOG_FILE

cat <<EOF > $HIVE_QUERY_FILE
USE taxi;

-- Step 1: Create table if it does not exist
CREATE TABLE IF NOT EXISTS taxi_data (
    Month_Year STRING,
    LicenseClass STRING,
    TripsPerDay INT,
    FareboxPerDay INT,
    UniqueDrivers INT,
    UniqueVehicles INT,
    VehiclesPerDay INT,
    AvgDaysVehiclesonRoad FLOAT,
    AvgHoursPerDayPerVehicle FLOAT,
    AvgDaysDriversonRoad FLOAT,
    AvgHoursPerDayPerDriver FLOAT,
    AvgMinutesPerTrip FLOAT,
    PercentofTripsPaidwithCreditCard STRING,
    TripsPerDayShared INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

CREATE TABLE IF NOT EXISTS taxi_data_staging (
    Month_Year STRING,
    LicenseClass STRING,
    TripsPerDay INT,
    FareboxPerDay INT,
    UniqueDrivers INT,
    UniqueVehicles INT,
    VehiclesPerDay INT,
    AvgDaysVehiclesonRoad FLOAT,
    AvgHoursPerDayPerVehicle FLOAT,
    AvgDaysDriversonRoad FLOAT,
    AvgHoursPerDayPerDriver FLOAT,
    AvgMinutesPerTrip FLOAT,
    PercentofTripsPaidwithCreditCard STRING,
    TripsPerDayShared INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA INPATH '${CSV_FILE}'
INTO TABLE taxi_data_staging;

INSERT INTO TABLE taxi_data
SELECT * FROM taxi_data_staging
WHERE NOT EXISTS (
    SELECT 1 FROM taxi_data
    WHERE taxi_data.Month_Year = taxi_data_staging.Month_Year
);

DROP TABLE taxi_data_staging;
EOF

echo "🚀 Running Hive Analysis..." | tee -a $LOG_FILE
if hive -f $HIVE_QUERY_FILE >> $LOG_FILE 2>&1; then
    echo "✅ Hive Queries Executed Successfully!" | tee -a $LOG_FILE
else
    echo "❌ Hive Queries Failed!" | tee -a $LOG_FILE
    echo -e "Subject: 🚨 Hive Query Execution Failed!\n\nCheck logs: $LOG_FILE" | sendmail -v $EMAIL
    exit 1
fi

echo "✅ Hive Analysis Completed Successfully!" | tee -a $LOG_FILE

