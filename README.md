📌 **An automated data pipeline for processing NYC Taxi monthly reports using Hadoop, Hive, and HDFS.**
✔ **CSV ingestion from NYC Open Data**
✔ **Data storage in HDFS**
✔ **SQL analytics with Hive**
✔ **Automated ETL pipeline using Shell scripting & Cron Jobs**

* * *

## **📂 Project Structure**

```
📦 nyc-taxi-data-pipeline
 ┣ 📂 scripts
 ┃ ┣ 📝 data_ingestion.sh            # Automates data download, cleaning & HDFS upload
 ┃ ┣ 📝 run_hive_analysis.sh         # Automates Hive queries & incremental data load
 ┣ 📂 hive
 ┃ ┣ 📝 hive_queries.sql             # Hive queries for analytics & reporting
 ┣ 📂 logs                           # Stores execution logs
 ┣ 📂 reports                        # Stores Hive-generated reports
 ┣ 📜 README.md                      # Project documentation
 ┣ 📜 .gitignore                      # Ignore large data files
```

* * *

## **🛠 Technologies Used**

✔ **Hadoop 3.3.6** – Distributed storage
✔ **HDFS** – Big data file system
✔ **Hive 3.1.3** – SQL-based data processing
✔ **Shell Scripting** – Automation & data processing
✔ **Bash & Cron Jobs** – Workflow scheduling

* * *

## **🚀 Project Setup**

### **1️⃣ Install Hadoop & Hive**

```sh
# Download & extract Hadoop
wget https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
tar -xvzf hadoop-3.3.6.tar.gz
sudo mv hadoop-3.3.6 /usr/local/hadoop

# Install Hive
wget https://archive.apache.org/dist/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
tar -xvzf apache-hive-3.1.3-bin.tar.gz
sudo mv apache-hive-3.1.3-bin /usr/local/hive
```

### **2️⃣ Configure Environment Variables**

```sh
nano ~/.bashrc
```

Add:

```sh
export HADOOP_HOME=/usr/local/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
export HIVE_HOME=/usr/local/hive
export PATH=$PATH:$HIVE_HOME/bin
```

Apply changes:

```sh
source ~/.bashrc
```

* * *

## **🛠 Data Processing Pipeline**

### **1️⃣ Automate Data Download & Ingestion**

**📜 `scripts/data_ingestion.sh`**

```sh
#!/bin/bash

DATA_URL="https://www.nyc.gov/assets/tlc/downloads/csv/data_reports_monthly.csv"
LOCAL_FILE="taxi_data_$(date +'%Y-%m').csv"
HDFS_DIR="/user/hive/warehouse/taxi_data/"

echo "🚀 Starting NYC Taxi Data Pipeline - $(date)"

# Step 1: Download the latest NYC Taxi data
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

* * *

### **2️⃣ Automate Hive Queries & Data Processing**

**📜 `scripts/run_hive_analysis.sh`**

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

* * *

## **📅 Automate with Cron Jobs**

Schedule the pipeline to run **automatically every month**.

```sh
crontab -e
```

Add:

```sh
0 2 1 * * /home/tejasjay94/scripts/data_ingestion.sh
30 2 1 * * /home/tejasjay94/scripts/run_hive_analysis.sh
```

✅ **This ensures data is ingested & processed monthly!**

* * *

## **📊 Example Hive Queries for Data Analysis**

### **1️⃣ Total Trips**

```sql
SELECT SUM(TripsPerDay) AS total_trips FROM taxi_data;
```

### **2️⃣ Average Farebox Per Day**

```sql
SELECT AVG(FareboxPerDay) AS avg_farebox FROM taxi_data;
```

### **3️⃣ Unique Drivers Count**

```sql
SELECT SUM(UniqueDrivers) AS total_unique_drivers FROM taxi_data;
```

### **4️⃣ Unique Vehicles Count**

```sql
SELECT SUM(UniqueVehicles) AS total_unique_vehicles FROM taxi_data;
```

### **5️⃣ Average Hours Per Day Per Vehicle**

```sql
SELECT AVG(AvgHoursPerDayPerVehicle) AS avg_hours_vehicle FROM taxi_data;
```

### **6️⃣ Average Hours Per Day Per Driver**

```sql
SELECT AVG(AvgHoursPerDayPerDriver) AS avg_hours_driver FROM taxi_data;
```

* * *

## **📜 Logs & Monitoring**

✅ **Log every pipeline execution:**

```sh
tail -f ~/logs/hive_queries.log
```

✅ **Get email alerts on failure using `sendmail`:**

```sh
echo "Pipeline failed" | sendmail tejastj33333@gmail.com
```

* * *

## **🚀 Project Summary**

✔ **Fully automated NYC taxi data pipeline**
✔ **Monthly CSV ingestion from NYC Open Data**
✔ **HDFS data storage & Hive table processing**
✔ **Automated SQL-based reporting**
✔ **No manual intervention needed (cron jobs handle everything)**
✔ **Scalable for any large dataset**

* * *

## **📜 Future Improvements**

🔹 Use **Apache Spark** for faster data processing
🔹 Integrate **Grafana/Tableau** for real-time visualization
🔹 Add **Airflow** for better job scheduling

* * *

## **👨‍💻 Contributing**

**Want to improve this pipeline?**
🔹 **Fork & clone** this repo
🔹 Submit **PRs** for feature improvements
🔹 Open **issues** for bug reports

* * *

🚀 **This is now GitHub-ready!** Let me know if you need modifications! 🎯
