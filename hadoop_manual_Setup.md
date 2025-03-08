# **📌 Part 3: Running Hive Queries & Data Ingestion**
Now that Hive is set up, we will:  
✔ **Create databases and tables in Hive**  
✔ **Load data from HDFS into Hive**  
✔ **Run SQL-like queries to analyze data**  

---

## **🛠 Step 12: Start Hive & Create a Database**
### **1️⃣ Start Hive CLI**
```sh
hive
```
✔ **Opens the Hive interactive command-line interface.**

### **2️⃣ Create a New Database**
```sql
CREATE DATABASE taxi;
```
✔ **Creates a database to store taxi report data.**

### **3️⃣ Switch to the New Database**
```sql
USE taxi;
```
✔ **Ensures all tables are created under this database.**

---

## **🛠 Step 13: Create Hive Table for Taxi Report Data**
Since our dataset is in **CSV format**, we need a **Hive table** to store structured data.

### **1️⃣ Create a Table**
```sql
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
```
✔ **Defines a structured table for Taxi Report Data.**  

---

## **🛠 Step 14: Upload CSV Data to HDFS**
Before loading data into Hive, we must first **move it into HDFS**.

### **1️⃣ Create a Directory in HDFS**
```sh
hdfs dfs -mkdir -p /user/hive/warehouse/taxi_data/
```
✔ **Creates an HDFS location for storing taxi data.**

### **2️⃣ Upload the Taxi Report CSV File**
```sh
hdfs dfs -put -f taxi_data_2025-03.csv /user/hive/warehouse/taxi_data/
```
✔ **Transfers the CSV file to HDFS.**

---

## **🛠 Step 15: Load Data into Hive**
### **1️⃣ Load Taxi Report Data from HDFS into Hive**
```sql
LOAD DATA INPATH '/user/hive/warehouse/taxi_data/taxi_data_2025-03.csv'
INTO TABLE taxi_data;
```
✔ **Imports data from HDFS into Hive for querying.**

### **2️⃣ Verify Data in Hive**
```sql
SELECT * FROM taxi_data LIMIT 10;
```
✅ **Expected Output:**
```
2025-03  YellowCab  234567  5678900  15000  10000  9800  25.6  8.5  22.5  9.4  14.2  60%  45000
...
```

---

## **🛠 Step 16: Run Analytics Queries in Hive**
Hive allows us to run **SQL-like queries** for **big data analysis**.

### **1️⃣ Total Trips**
```sql
SELECT SUM(TripsPerDay) AS total_trips FROM taxi_data;
```
✔ **Returns the total number of taxi trips.**

### **2️⃣ Average Farebox Per Day**
```sql
SELECT AVG(FareboxPerDay) AS avg_farebox FROM taxi_data;
```
✔ **Calculates the average fare collected per day.**

### **3️⃣ Unique Drivers Count**
```sql
SELECT SUM(UniqueDrivers) AS total_unique_drivers FROM taxi_data;
```
✔ **Finds the number of unique drivers in the dataset.**

### **4️⃣ Unique Vehicles Count**
```sql
SELECT SUM(UniqueVehicles) AS total_unique_vehicles FROM taxi_data;
```
✔ **Finds the number of unique vehicles in the dataset.**

### **5️⃣ Average Hours Per Day Per Vehicle**
```sql
SELECT AVG(AvgHoursPerDayPerVehicle) AS avg_hours_vehicle FROM taxi_data;
```
✔ **Calculates the average daily usage of a vehicle.**

### **6️⃣ Average Hours Per Day Per Driver**
```sql
SELECT AVG(AvgHoursPerDayPerDriver) AS avg_hours_driver FROM taxi_data;
```
✔ **Calculates the average daily working hours of a driver.**

---

## **📌 Part 4: Automating Data Pipeline**
Now that we have manually processed **CSV → HDFS → Hive**, we will fully **automate the entire workflow**.

---

## **🛠 Step 17: Automating Data Ingestion**
We will create a **shell script** that:  
✔ **Downloads new taxi reports automatically**  
✔ **Cleans the dataset**  
✔ **Uploads CSV to HDFS**  

### **1️⃣ Create the Script (`data_ingestion.sh`)**
```sh
nano data_ingestion.sh
```

### **2️⃣ Add the Following Script**
```sh
#!/bin/bash

DATA_URL="https://www.nyc.gov/assets/tlc/downloads/csv/data_reports_monthly.csv"
LOCAL_FILE="taxi_data_$(date +'%Y-%m').csv"
HDFS_DIR="/user/hive/warehouse/taxi_data/"

echo "🚀 Starting NYC Taxi Data Pipeline - $(date)"

# Step 1: Download the latest Taxi Data
echo "📥 Downloading $DATA_URL..."
wget -O "$LOCAL_FILE" "$DATA_URL"

# Step 2: Remove header row
echo "🛠 Cleaning data - Removing header row..."
tail -n +2 "$LOCAL_FILE" > "cleaned_$LOCAL_FILE"

# Step 3: Upload to HDFS
echo "📤 Uploading to HDFS..."
hdfs dfs -put -f "cleaned_$LOCAL_FILE" "$HDFS_DIR"

echo "✅ Data Pipeline Completed Successfully!"
```

### **3️⃣ Make the Script Executable**
```sh
chmod +x data_ingestion.sh
```

---

## **🛠 Step 18: Automating Hive Queries**
We will now **automate table creation and incremental data load**.

### **1️⃣ Create the Script (`run_hive_analysis.sh`)**
```sh
nano run_hive_analysis.sh
```

### **2️⃣ Add the Following Script**
```sh
#!/bin/bash

LOG_FILE="~/logs/hive_queries.log"
EMAIL="tejastj33333@gmail.com"

CURRENT_YEAR=$(date +'%Y')
CURRENT_MONTH=$(date +'%m')
CSV_FILE="/user/hive/warehouse/taxi_data/taxi_data_${CURRENT_YEAR}-${CURRENT_MONTH}.csv"
HIVE_QUERY_FILE="~/hive_queries_dynamic.sql"

echo "🚀 Generating Hive Query for $CURRENT_YEAR-$CURRENT_MONTH" | tee -a $LOG_FILE

cat <<EOF > $HIVE_QUERY_FILE
USE taxi;

CREATE TABLE IF NOT EXISTS taxi_data_staging LIKE taxi_data;

LOAD DATA INPATH '${CSV_FILE}' INTO TABLE taxi_data_staging;

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
```

### **3️⃣ Make the Script Executable**
```sh
chmod +x run_hive_analysis.sh
```

---

## **🛠 Step 19: Automate Execution with Cron Jobs**
### **1️⃣ Open Cron Job Editor**
```sh
crontab -e
```

### **2️⃣ Add Scheduled Jobs**
```sh
0 2 1 * * /home/tejasjay94/data_ingestion.sh
30 2 1 * * /home/tejasjay94/run_hive_analysis.sh
```
✔ **Runs the data ingestion & Hive analysis on the 1st of every month.**

---

🚀 **Your Data Pipeline is Fully Automated!**  
💡 **Let me know if you need further improvements!** 🚀
