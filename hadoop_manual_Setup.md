## **📌 Full Hadoop & Hive Setup Notes**

This document contains **detailed step-by-step notes** explaining **everything we did today**, covering:
✔ **Hadoop installation & setup**
✔ **Configuring HDFS & YARN**
✔ **Hive installation & setup**
✔ **Query execution & data ingestion**
✔ **Full automation of the pipeline**


* * *

# **🚀 Part 1: Hadoop Installation & Setup**

Hadoop is the **core framework** that allows us to store and process **large-scale data** using a distributed system.

* * *

## **🛠 Step 1: Install Hadoop on the Master Node**

### **1️⃣ SSH into the Hadoop Master Node**

sh

CopyEdit

`gcloud compute ssh hadoop-master`

### **2️⃣ Download & Install Hadoop**

sh

CopyEdit

`wget https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz`

✔ This command downloads **Hadoop version 3.3.6**.

### **3️⃣ Extract & Move Hadoop**

sh

CopyEdit

`tar -xvzf hadoop-3.3.6.tar.gz sudo mv hadoop-3.3.6 /usr/local/hadoop`

✔ **Extracts the Hadoop package and moves it** to `/usr/local/hadoop`.

* * *

## **🛠 Step 2: Configure Hadoop Environment Variables**

We need to set up **Hadoop paths** so it can be accessed system-wide.

### **1️⃣ Edit `.bashrc` File**

sh

CopyEdit

`nano ~/.bashrc`

### **2️⃣ Add the Following Environment Variables**

sh

CopyEdit

`export HADOOP_HOME=/usr/local/hadoop export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop export YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64`

✔ **Defines paths for Hadoop and Java**.

### **3️⃣ Apply Changes**

sh

CopyEdit

`source ~/.bashrc`

✔ Ensures the new environment variables are active.

* * *

## **🛠 Step 3: Configure Hadoop Core Settings**

Hadoop requires multiple configuration changes.

### **1️⃣ Edit `core-site.xml`**

sh

CopyEdit

`nano /usr/local/hadoop/etc/hadoop/core-site.xml`

🔹 **Update the following properties:**

xml

CopyEdit

`<configuration>     <property>         <name>fs.defaultFS</name>         <value>hdfs://hadoop-master:9000</value>     </property> </configuration>`

✔ **Defines Hadoop’s filesystem (HDFS) URL**.

* * *

### **2️⃣ Edit `hdfs-site.xml` (HDFS Configuration)**

sh

CopyEdit

`nano /usr/local/hadoop/etc/hadoop/hdfs-site.xml`

🔹 **Add replication and block size settings:**

xml

CopyEdit

`<configuration>     <property>         <name>dfs.replication</name>         <value>3</value>  <!-- Ensures data is replicated on multiple nodes -->     </property>     <property>         <name>dfs.blocksize</name>         <value>268435456</value>  <!-- 256MB Block Size -->     </property> </configuration>`

✔ **Configures how Hadoop distributes and stores data.**

* * *

### **3️⃣ Edit `yarn-site.xml` (YARN Configuration)**

sh

CopyEdit

`nano /usr/local/hadoop/etc/hadoop/yarn-site.xml`

🔹 **Update the following properties:**

xml

CopyEdit

`<configuration>     <property>         <name>yarn.nodemanager.resource.memory-mb</name>         <value>8192</value>     </property>     <property>         <name>yarn.scheduler.minimum-allocation-mb</name>         <value>1024</value>     </property>     <property>         <name>yarn.scheduler.maximum-allocation-mb</name>         <value>8192</value>     </property> </configuration>`

✔ **Allocates memory for YARN (Job Scheduler)**.

* * *

## **🛠 Step 4: Configure Worker Nodes**

Worker nodes execute the actual **MapReduce tasks**.

### **1️⃣ Edit the `workers` File**

sh

CopyEdit

`nano /usr/local/hadoop/etc/hadoop/workers`

🔹 **Add the following worker node hostnames:**

nginx

CopyEdit

`localhost hadoop-worker-1 hadoop-worker-2`

✔ **Defines the worker nodes participating in the Hadoop cluster**.

* * *

## **🛠 Step 5: Set Up SSH Access Between Nodes**

Hadoop needs **password-less SSH access** to communicate between nodes.

### **1️⃣ Generate SSH Keys**

sh

CopyEdit

`ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa`

✔ **Creates an SSH key without a passphrase**.

### **2️⃣ Copy SSH Key to Worker Nodes**

sh

CopyEdit

`ssh-copy-id tejasjay94@hadoop-worker-1 ssh-copy-id tejasjay94@hadoop-worker-2`

✔ **Allows the master node to SSH into worker nodes without a password**.

* * *

## **🛠 Step 6: Format the Hadoop Filesystem**

HDFS must be formatted before first use.

sh

CopyEdit

`hdfs namenode -format`

✔ **Prepares Hadoop's distributed storage system (HDFS) for use**.

* * *

## **🛠 Step 7: Start Hadoop Services**

Hadoop has multiple services that need to be started.

### **1️⃣ Start HDFS (Hadoop Distributed File System)**

sh

CopyEdit

`start-dfs.sh`

### **2️⃣ Start YARN (Resource Manager)**

sh

CopyEdit

`start-yarn.sh`

✔ **These commands start Hadoop's storage and job scheduling services.**

* * *

## **🛠 Step 8: Verify Hadoop is Running**

Check that all **Hadoop services** are running:

sh

CopyEdit

`jps`

✅ **Expected Output:**

CopyEdit

`12345 NameNode 12346 DataNode 12347 SecondaryNameNode 12348 ResourceManager 12349 NodeManager 12350 Jps`

✔ **Indicates all core Hadoop services are running successfully.**

* * *

# **🚀 Part 2: Apache Hive Setup & Configuration**

Hive is a **data warehouse system** that allows us to **run SQL-like queries on Hadoop**.

* * *

## **🛠 Step 9: Install Hive**

### **1️⃣ Download & Install Hive**

sh

CopyEdit

`wget https://archive.apache.org/dist/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz tar -xvzf apache-hive-3.1.3-bin.tar.gz sudo mv apache-hive-3.1.3-bin /usr/local/hive`

✔ **Extracts Hive and moves it to the correct directory.**

### **2️⃣ Set Hive Environment Variables**

sh

CopyEdit

`nano ~/.bashrc`

🔹 **Add:**

sh

CopyEdit

`export HIVE_HOME=/usr/local/hive export PATH=$PATH:$HIVE_HOME/bin`

✔ **Ensures Hive commands work system-wide**.

### **3️⃣ Apply Changes**

sh

CopyEdit

`source ~/.bashrc`

* * *

## **🛠 Step 10: Configure Hive Metastore**

Hive stores metadata in a **Metastore Database**.

### **1️⃣ Edit `hive-site.xml`**

sh

CopyEdit

`nano /usr/local/hive/conf/hive-site.xml`

🔹 **Add database connection settings:**

xml

CopyEdit

`<configuration>     <property>         <name>javax.jdo.option.ConnectionURL</name>         <value>jdbc:derby:;databaseName=/usr/local/hive/metastore_db;create=true</value>     </property>     <property>         <name>hive.metastore.warehouse.dir</name>         <value>/user/hive/warehouse</value>     </property> </configuration>`

✔ **Configures Hive to store metadata using Apache Derby.**

* * *

## **🛠 Step 11: Initialize Hive Metastore**

sh

CopyEdit

`schematool -initSchema -dbType derby`

✔ **Prepares Hive's internal database for storing metadata.**

* * *

**📌 Next Up: Hive Query Execution, Data Ingestion & Full Automation!**
(Continuing in next response…) 🚀

4o

##### You said:

continue

###### ChatGPT said:

## **📌 Part 3: Running Hive Queries & Data Ingestion**

Now that Hive is set up, we will:
✔ **Create databases and tables in Hive**
✔ **Load data from HDFS into Hive**
✔ **Run SQL-like queries to analyze data**

* * *

## **🛠 Step 12: Start Hive & Create a Database**

### **1️⃣ Start Hive CLI**

sh

CopyEdit

`hive`

✔ **Opens the Hive interactive command-line interface.**

### **2️⃣ Create a New Database**

sql

CopyEdit

`CREATE DATABASE nyctaxi;`

✔ **Creates a database to store NYC taxi trip data.**

### **3️⃣ Switch to the New Database**

sql

CopyEdit

`USE nyctaxi;`

✔ **Ensures all tables are created under this database.**

* * *

## **🛠 Step 13: Create Hive Table for NYC Taxi Data**

Since our dataset is in **CSV format**, we need a **Hive table** to store structured data.

### **1️⃣ Create a Table**

sql

CopyEdit

`CREATE TABLE yellow_taxi (     VendorID INT,     tpep_pickup_datetime STRING,     tpep_dropoff_datetime STRING,     passenger_count INT,     trip_distance FLOAT,     fare_amount FLOAT,     total_amount FLOAT,     payment_type INT ) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS TEXTFILE;`

✔ **Defines a structured table for NYC taxi data.**

* * *

## **🛠 Step 14: Upload CSV Data to HDFS**

Before loading data into Hive, we must first **move it into HDFS**.

### **1️⃣ Create a Directory in HDFS**

sh

CopyEdit

`hdfs dfs -mkdir -p /user/hive/warehouse/nyc_taxi/`

✔ **Creates an HDFS location for storing taxi data.**

### **2️⃣ Upload the NYC Taxi CSV File**

sh

CopyEdit

`hdfs dfs -put -f yellow_tripdata_2025-03.csv /user/hive/warehouse/nyc_taxi/`

✔ **Transfers the CSV file to HDFS.**

* * *

## **🛠 Step 15: Load Data into Hive**

### **1️⃣ Load NYC Taxi Data from HDFS into Hive**

sql

CopyEdit

`LOAD DATA INPATH '/user/hive/warehouse/nyc_taxi/yellow_tripdata_2025-03.csv' INTO TABLE yellow_taxi;`

✔ **Imports data from HDFS into Hive for querying.**

### **2️⃣ Verify Data in Hive**

sql

CopyEdit

`SELECT * FROM yellow_taxi LIMIT 10;`

✅ **Expected Output:**

yaml

CopyEdit

`1  2025-03-01 00:10:00  2025-03-01 00:20:00  1  2.5  12.00  15.50  1 1  2025-03-01 01:30:00  2025-03-01 01:45:00  2  5.0  20.00  23.00  2 ...`

* * *

## **🛠 Step 16: Run Analytics Queries in Hive**

Hive allows us to run **SQL-like queries** for **big data analysis**.

### **1️⃣ Count Total Number of Trips**

sql

CopyEdit

`SELECT COUNT(*) FROM yellow_taxi;`

✔ **Returns the total number of taxi trips.**

### **2️⃣ Find the Average Fare**

sql

CopyEdit

`SELECT AVG(fare_amount) FROM yellow_taxi;`

✔ **Calculates the average fare per trip.**

### **3️⃣ Find the Busiest Pickup Hours**

sql

CopyEdit

`SELECT HOUR(tpep_pickup_datetime) AS pickup_hour, COUNT(*) AS trip_count FROM yellow_taxi GROUP BY HOUR(tpep_pickup_datetime) ORDER BY trip_count DESC LIMIT 5;`

✔ **Determines the busiest times for taxis.**

### **4️⃣ Order Trips by Fare Amount**

sql

CopyEdit

`SELECT * FROM yellow_taxi ORDER BY fare_amount DESC LIMIT 10;`

✔ **Lists the most expensive taxi trips.**

* * *

## **📌 Part 4: Automating Data Pipeline**

Now that we have manually processed **Parquet → CSV → HDFS → Hive**, we will fully **automate the entire workflow**.

* * *

## **🛠 Step 17: Automating Data Ingestion**

We will create a **shell script** that:
✔ **Downloads new NYC taxi data monthly**
✔ **Converts Parquet to CSV**
✔ **Uploads CSV to HDFS**

### **1️⃣ Create the Script (`data_ingestion.sh`)**

sh

CopyEdit

`nano data_ingestion.sh`

### **2️⃣ Add the Following Script**

sh

CopyEdit

`#!/bin/bash  LOG_FILE="/home/tejasjay94/logs/data_pipeline.log" CURRENT_YEAR=$(date +'%Y') CURRENT_MONTH=$(date +'%m')  DATA_URL="https://www.nyc.gov/assets/tlc/downloads/yellow_tripdata_${CURRENT_YEAR}-${CURRENT_MONTH}.parquet" LOCAL_FILE="yellow_tripdata_${CURRENT_YEAR}-${CURRENT_MONTH}.parquet" CSV_FILE="yellow_tripdata_${CURRENT_YEAR}-${CURRENT_MONTH}.csv" HDFS_DIR="/user/hive/warehouse/nyc_taxi/"  echo "🚀 Starting Data Pipeline - $(date)" | tee -a $LOG_FILE  # Step 1: Download Latest Taxi Data echo "📥 Downloading $DATA_URL..." | tee -a $LOG_FILE wget -O "$LOCAL_FILE" "$DATA_URL"  # Step 2: Convert Parquet to CSV echo "🛠 Converting Parquet to CSV..." | tee -a $LOG_FILE python3 convert_parquet_to_csv.py "$LOCAL_FILE"  # Step 3: Upload to HDFS echo "📤 Uploading to HDFS..." | tee -a $LOG_FILE hdfs dfs -put -f "$CSV_FILE" "$HDFS_DIR"  echo "✅ Data Pipeline Completed Successfully!" | tee -a $LOG_FILE`

### **3️⃣ Make the Script Executable**

sh

CopyEdit

`chmod +x data_ingestion.sh`

* * *

## **🛠 Step 18: Automating Hive Queries**

We will now **automate table creation and incremental data load**.

### **1️⃣ Create the Script (`run_hive_analysis.sh`)**

sh

CopyEdit

`nano run_hive_analysis.sh`

### **2️⃣ Add the Following Script**

sh

CopyEdit

`#!/bin/bash  LOG_FILE="/home/tejasjay94/logs/hive_queries.log" CURRENT_YEAR=$(date +'%Y') CURRENT_MONTH=$(date +'%m')  CSV_FILE="/user/hive/warehouse/nyc_taxi/yellow_tripdata_${CURRENT_YEAR}-${CURRENT_MONTH}.csv" HIVE_QUERY_FILE="/home/tejasjay94/hive_queries_dynamic.sql"  cat <<EOF > $HIVE_QUERY_FILE USE nyctaxi;  CREATE TABLE IF NOT EXISTS yellow_taxi (     VendorID INT,     tpep_pickup_datetime STRING,     tpep_dropoff_datetime STRING,     passenger_count INT,     trip_distance FLOAT,     fare_amount FLOAT,     total_amount FLOAT,     payment_type INT ) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS TEXTFILE;  CREATE TABLE IF NOT EXISTS yellow_taxi_staging LIKE yellow_taxi;  LOAD DATA INPATH '${CSV_FILE}' INTO TABLE yellow_taxi_staging;  INSERT INTO TABLE yellow_taxi SELECT * FROM yellow_taxi_staging WHERE tpep_pickup_datetime NOT IN (SELECT tpep_pickup_datetime FROM yellow_taxi);  DROP TABLE yellow_taxi_staging; EOF  hive -f $HIVE_QUERY_FILE >> $LOG_FILE 2>&1`

### **3️⃣ Make the Script Executable**

sh

CopyEdit

`chmod +x run_hive_analysis.sh`

* * *

## **🛠 Step 19: Automate Execution with Cron Jobs**

### **1️⃣ Open Cron Job Editor**

sh

CopyEdit

`crontab -e`

### **2️⃣ Add Scheduled Jobs**

sh

CopyEdit

`0 2 1 * * /home/tejasjay94/data_ingestion.sh 30 2 1 * * /home/tejasjay94/run_hive_analysis.sh`

✔ **Runs the data ingestion & Hive analysis on the 1st of every month.**

* * *
