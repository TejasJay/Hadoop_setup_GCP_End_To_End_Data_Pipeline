### **📌 Hadoop Cluster Setup on Google Cloud Platform (GCP) - Step-by-Step Notes**

Below is a **detailed breakdown** of everything we did to **set up Hadoop on GCP** from scratch. Since this is long, I will split it into **multiple responses**.

* * *

## **🛠 Step 1: Understanding Hadoop & GCP Setup**

### **1.1 What is Hadoop?**

Hadoop is an **open-source framework** that enables distributed processing of large datasets across clusters of computers. It consists of:
✔ **HDFS (Hadoop Distributed File System)** – Storage Layer
✔ **MapReduce** – Data Processing Engine
✔ **YARN (Yet Another Resource Negotiator)** – Resource Manager
✔ **Apache Hive (SQL on Hadoop)** – Query Engine
✔ **Apache HBase (NoSQL on Hadoop)** – Database

* * *

### **1.2 Setting Up Virtual Machines on GCP**

To run a Hadoop cluster, we created three **Compute Engine instances**:
🔹 **hadoop-master** → Runs NameNode, ResourceManager, and SecondaryNameNode
🔹 **hadoop-worker-1** → Runs DataNode and NodeManager
🔹 **hadoop-worker-2** → Runs DataNode and NodeManager

#### **1️⃣ Create Master Node**

1.  **Go to** Google Cloud Console.
2.  Navigate to **Compute Engine → VM Instances → Create Instance**.
3.  **Set the following configuration**:
    -   Name: `hadoop-master`
    -   Machine Type: `e2-standard-2` (2 vCPUs, 8GB RAM)
    -   OS Image: `Ubuntu 22.04 LTS`
    -   Boot Disk: `50GB`
    -   Allow HTTP/HTTPS traffic
4.  Click **Create**.

#### **2️⃣ Create Worker Nodes**

1.  **Repeat the same process** for `hadoop-worker-1` and `hadoop-worker-2`:
    -   Use the same **machine type** and **OS image**.
    -   Set the **names** as `hadoop-worker-1` and `hadoop-worker-2`.
2.  Click **Create**.
* * *

### **1.3 SSH Into the Master Node**

To install and configure Hadoop, SSH into the master node:

sh

""

`gcloud compute ssh hadoop-master`

* * *

## **🛠 Step 2: Installing Java and Hadoop**

### **2.1 Install Java (Required for Hadoop)**

On **each node (master + workers)**, install Java:

sh

""

`sudo apt update sudo apt install openjdk-11-jdk -y`

Verify:

sh

""

`java -version`

✅ Expected Output:

nginx

""

`openjdk version "11.0.x"`

* * *

### **2.2 Download and Install Hadoop**

On **each node (master + workers)**:

1️⃣ **Download Hadoop**:

sh

""

`wget https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz`

2️⃣ **Extract and move to `/usr/local/`**:

sh

""

`tar -xvzf hadoop-3.3.6.tar.gz sudo mv hadoop-3.3.6 /usr/local/hadoop`

* * *

### **2.3 Set Environment Variables**

On **each node (master + workers)**:

1️⃣ **Edit `.bashrc`:**

sh

""

`nano ~/.bashrc`

2️⃣ **Add these lines at the bottom**:

sh

""

`export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 export HADOOP_HOME=/usr/local/hadoop export HADOOP_MAPRED_HOME=$HADOOP_HOME export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop export YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop`

3️⃣ **Save and apply changes**:

sh

""

`source ~/.bashrc`

4️⃣ **Verify that Hadoop is recognized**:

sh

""

`hadoop version`

✅ Expected Output: Hadoop version details.

* * *

## **🛠 Step 3: Configuring Hadoop (HDFS, YARN, MapReduce)**

### **3.1 Update Configuration Files**

On **each node (master + workers)**:

#### **1️⃣ Configure `core-site.xml` (HDFS Settings)**

sh

""

`sudo nano /usr/local/hadoop/etc/hadoop/core-site.xml`

Add:

xml

""

`<configuration>     <property>         <name>fs.defaultFS</name>         <value>hdfs://hadoop-master:9000</value>     </property>     <property>         <name>hadoop.tmp.dir</name>         <value>/usr/local/hadoop/tmp</value>     </property> </configuration>`

* * *

#### **2️⃣ Configure `hdfs-site.xml` (HDFS Storage Settings)**

sh

""

`sudo nano /usr/local/hadoop/etc/hadoop/hdfs-site.xml`

Add:

xml

""

`<configuration>     <property>         <name>dfs.replication</name>         <value>2</value>     </property>     <property>         <name>dfs.namenode.name.dir</name>         <value>file:///usr/local/hadoop/hdfs/namenode</value>     </property>     <property>         <name>dfs.datanode.data.dir</name>         <value>file:///usr/local/hadoop/hdfs/datanode</value>     </property> </configuration>`

* * *

#### **3️⃣ Configure `yarn-site.xml` (YARN Resource Manager)**

sh

""

`sudo nano /usr/local/hadoop/etc/hadoop/yarn-site.xml`


### **📌 Detailed Notes: Apache Hive Setup, Queries, and Optimization**

Here are **comprehensive notes** covering everything you have learned so far about Hive. Since this will be detailed, I'll split it into multiple responses.

* * *

# **📖 Part 1: Apache Hive Overview & Installation**

## **🛠 What is Apache Hive?**

Apache Hive is a **data warehouse system** built on Hadoop that allows you to:
✔ Run **SQL-like queries** on large datasets stored in HDFS
✔ Convert **HiveQL (SQL queries) into MapReduce jobs**
✔ Store **structured and semi-structured data**
✔ Support **batch processing and analytics**

* * *

## **🛠 Hive vs. Traditional Databases**

| Feature | Hive (Hadoop) | Traditional RDBMS |
| --- | --- | --- |
| Query Language | HiveQL (SQL-like) | SQL |
| Storage | HDFS (Distributed) | Local Disk |
| Execution | Converts queries to MapReduce/Tez | Direct execution |
| Schema | Schema-on-Read | Schema-on-Write |
| Optimized For | Batch Processing & Big Data | Transactions & OLTP |

👉 **Hive is NOT meant for real-time transactional processing.** It is best used for **data analysis and reporting**.

* * *

## **🛠 Hive Architecture**

Hive consists of several key components:

✔ **Hive Metastore** → Stores metadata (table schemas, partitions, locations)
✔ **Driver** → Compiles, optimizes, and executes queries
✔ **Execution Engine** → Converts SQL into MapReduce or Tez jobs
✔ **HDFS Storage** → Stores structured data in a distributed fashion

* * *

# **📌 Part 2: Installing and Configuring Hive**

## **🛠 Step 1: Download and Install Hive**

1️⃣ **SSH into Hadoop Master Node**

sh

""

`gcloud compute ssh hadoop-master`

2️⃣ **Download Apache Hive (3.1.3)**

sh

""

`wget https://archive.apache.org/dist/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz`

3️⃣ **Extract Hive and Move to `/usr/local/`**

sh

""

`tar -xvzf apache-hive-3.1.3-bin.tar.gz sudo mv apache-hive-3.1.3-bin /usr/local/hive`

* * *

## **🛠 Step 2: Set Hive Environment Variables**

1️⃣ **Edit `.bashrc`**

sh

""

`nano ~/.bashrc`

2️⃣ **Add the following lines**

sh

""

`export HIVE_HOME=/usr/local/hive export PATH=$PATH:$HIVE_HOME/bin`

3️⃣ **Apply changes**

sh

""

`source ~/.bashrc`

4️⃣ **Verify Hive Installation**

sh

""

`hive --version`

✅ Expected Output:

nginx

""

`Hive 3.1.3`

* * *

## **🛠 Step 3: Configure Hive Metastore**

Hive **stores metadata** in the **Metastore Database**.

1️⃣ **Edit `hive-site.xml`**

sh

""

`sudo nano /usr/local/hive/conf/hive-site.xml`

2️⃣ **Add the following configuration**

xml

""

`<configuration>     <property>         <name>javax.jdo.option.ConnectionURL</name>         <value>jdbc:derby:;databaseName=/usr/local/hive/metastore_db;create=true</value>     </property>     <property>         <name>hive.metastore.warehouse.dir</name>         <value>/user/hive/warehouse</value>     </property> </configuration>`

3️⃣ **Save and apply changes**

sh

""

`source ~/.bashrc`

* * *

## **🛠 Step 4: Initialize Hive Metastore**

1️⃣ **Delete any existing Metastore (if reinitializing)**

sh

""

`rm -r /usr/local/hive/metastore_db`

2️⃣ **Run Hive Schema Initialization**

sh

""

`schematool -initSchema -dbType derby`

3️⃣ **Start Hive Metastore**

sh

""

`hive --service metastore &`

* * *

## **🛠 Step 5: Create Hive Warehouse in HDFS**

1️⃣ **Create the Hive directory in HDFS**

sh

""

`hdfs dfs -mkdir -p /user/hive/warehouse hdfs dfs -chmod g+w /user/hive/warehouse`

2️⃣ **Verify**

sh

""

`hdfs dfs -ls /user/hive/`

✅ Expected Output:

bash

""

`drwxr-xr-x - hive supergroup 0 2025-03-08  /user/hive/warehouse`

* * *

## **🛠 Step 6: Start Hive**

1️⃣ **Start Hive CLI**

sh

""

`hive`

✅ Expected Output:

shell

""

`hive>`

2️⃣ **Check available databases**

sql

""

`SHOW DATABASES;`

✅ Expected Output:

cpp

""

`default`

* * *

## **✅ Hive Setup Summary**

| Step | Description |
| --- | --- |
| Install Hive | Download and extract Hive 3.1.3 |
| Set Environment Variables | Add `HIVE_HOME` and update `PATH` |
| Configure Hive Metastore | Set up `hive-site.xml` with Derby database |
| Initialize Hive Metastore | Run `schematool -initSchema -dbType derby` |
| Start Hive | Run `hive --service metastore` and enter `hive` CLI |
| Verify Setup | Run `SHOW DATABASES;` |

* * *

# **🛠 Step 1: Creating Databases in Hive**

### **1️⃣ Create a New Database**

sql

""

`CREATE DATABASE hadoopdb;`

### **2️⃣ View Available Databases**

sql

""

`SHOW DATABASES;`

✅ Expected Output:

cpp

""

`default hadoopdb`

### **3️⃣ Use a Specific Database**

sql

""

`USE hadoopdb;`

* * *

# **🛠 Step 2: Creating Tables in Hive**

Hive tables store **structured data** inside HDFS.

### **1️⃣ Create a Simple Table**

sql

""

`CREATE TABLE employees (     id INT,     name STRING,     department STRING,     salary FLOAT ) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS TEXTFILE;`

✅ This table is now stored in HDFS.

### **2️⃣ Check Available Tables**

sql

""

`SHOW TABLES;`

✅ Expected Output:

nginx

""

`employees`

### **3️⃣ View Table Schema**

sql

""

`DESCRIBE employees;`

✅ Expected Output:

csharp

""

`id            int name          string department    string salary        float`

* * *

# **🛠 Step 3: Loading Data into Hive Tables**

### **1️⃣ Create Sample Employee Data**

Run this command on `hadoop-master`:

sh

""

`echo -e "1,John,Engineering,80000\n2,Alice,HR,75000\n3,Bob,Marketing,72000" > employees.txt`

### **2️⃣ Upload Data to HDFS**

sh

""

`hdfs dfs -mkdir -p /user/hive/warehouse/employees/ hdfs dfs -put employees.txt /user/hive/warehouse/employees/`

### **3️⃣ Load Data into Hive Table**

sql

""

`LOAD DATA INPATH '/user/hive/warehouse/employees/' INTO TABLE employees;`

### **4️⃣ Verify the Data**

sql

""

`SELECT * FROM employees;`

✅ Expected Output:

""

`1   John    Engineering   80000 2   Alice   HR            75000 3   Bob     Marketing     72000`

* * *

# **🛠 Step 4: Running SQL Queries on Hive Data**

Hive supports **SQL-like queries** for data analysis.

### **1️⃣ Retrieve All Employees**

sql

""

`SELECT * FROM employees;`

### **2️⃣ Filter Employees by Salary**

sql

""

`SELECT * FROM employees WHERE salary > 75000;`

✅ Expected Output:

""

`1   John    Engineering   80000`

### **3️⃣ Count Employees per Department**

sql

""

`SELECT department, COUNT(*) FROM employees GROUP BY department;`

✅ Expected Output:

nginx

""

`Engineering   1 HR            1 Marketing     1`

### **4️⃣ Find Average Salary per Department**

sql

""

`SELECT department, AVG(salary) FROM employees GROUP BY department;`

✅ Expected Output:

nginx

""

`Engineering   80000 HR            75000 Marketing     72000`

### **5️⃣ Order Employees by Salary**

sql

""

`SELECT * FROM employees ORDER BY salary DESC;`

✅ Expected Output:

""

`1   John    Engineering   80000 2   Alice   HR            75000 3   Bob     Marketing     72000`

* * *

# **🛠 Step 5: Partitioning & Bucketing for Faster Queries**

Partitioning and bucketing **optimize performance** by reducing the data scanned.

### **1️⃣ Create a Partitioned Table**

sql

""

`CREATE TABLE employees_partitioned (     id INT,     name STRING,     salary FLOAT ) PARTITIONED BY (department STRING) STORED AS TEXTFILE;`

### **2️⃣ Add Partitions Manually**

sql

""

`ALTER TABLE employees_partitioned ADD PARTITION (department='Engineering') LOCATION '/user/hive/warehouse/employees/engineering';`

### **3️⃣ Query Using Partitioning**

sql

""

`SELECT * FROM employees_partitioned WHERE department='Engineering';`

✅ **This scans only the `Engineering` partition, making queries faster.**

* * *

# **🛠 Step 6: Hive Query Optimization Techniques**

## **1️⃣ Enable Tez Execution Engine (Faster Queries)**

sh

""

`sudo nano /usr/local/hive/conf/hive-site.xml`

Add:

xml

""

`<property>     <name>hive.execution.engine</name>     <value>tez</value> </property>`

Restart Hive:

sh

""

`exit hive`

## **2️⃣ Enable Query Caching**

sh

""

`sudo nano /usr/local/hive/conf/hive-site.xml`

Add:

xml

""

`<property>     <name>hive.compute.query.using.stats</name>     <value>true</value> </property>`

Restart Hive:

sh

""

`exit hive`

## **3️⃣ Increase Hive Reducer Memory**

sh

""

`sudo nano /usr/local/hadoop/etc/hadoop/mapred-site.xml`

Add:

xml

""

`<property>     <name>mapreduce.reduce.memory.mb</name>     <value>8192</value> </property>`

Restart Hadoop:

sh

""

`stop-dfs.sh start-dfs.sh`

* * *

# **✅ Hive Queries & Optimization Summary**

| Hive Command | Description |
| --- | --- |
| `CREATE DATABASE hadoopdb;` | Create a Hive database |
| `SHOW DATABASES;` | List available databases |
| `USE hadoopdb;` | Select a database |
| `CREATE TABLE employees (...);` | Create a Hive table |
| `SHOW TABLES;` | List all tables in the current database |
| `LOAD DATA INPATH '/path' INTO TABLE employees;` | Load data into a Hive table |
| `SELECT * FROM employees;` | Retrieve all records |
| `SELECT * FROM employees WHERE salary > 75000;` | Filter records |
| `SELECT department, COUNT(*) FROM employees GROUP BY department;` | Count employees per department |
| `SELECT department, AVG(salary) FROM employees GROUP BY department;` | Compute averages |
| `SELECT * FROM employees ORDER BY salary DESC;` | Sort results |
| `CREATE TABLE employees_partitioned (...) PARTITIONED BY (department STRING);` | Create a partitioned table |
| `ALTER TABLE employees_partitioned ADD PARTITION (department='Engineering');` | Add partitions |
| `SELECT * FROM employees_partitioned WHERE department='Engineering';` | Query a partitioned table |

* * *


## **🛠 Step 1: Tuning HDFS Performance**

Since **HDFS** stores data across multiple nodes, optimizing it ensures **fast read/write operations**.

### **1️⃣ Increase HDFS Block Size**

👉 **Why?** Larger blocks reduce overhead and improve efficiency for large files.

📌 **Modify `hdfs-site.xml` on `hadoop-master`**

sh

""

`sudo nano /usr/local/hadoop/etc/hadoop/hdfs-site.xml`

🔹 **Change the default block size to 256MB**

xml

""

`<property>     <name>dfs.blocksize</name>     <value>268435456</value>  <!-- 256MB block size --> </property>`

📌 **Save & Restart Hadoop**

sh

""

`stop-dfs.sh start-dfs.sh`

* * *

### **2️⃣ Increase DataNode Replication Factor**

👉 **Why?** Higher replication ensures **fault tolerance**, but increases storage requirements.

📌 **Modify `hdfs-site.xml`**

xml

""

`<property>     <name>dfs.replication</name>     <value>3</value>  <!-- Default is 3 --> </property>`

📌 **Restart Hadoop**

sh

""

`stop-dfs.sh start-dfs.sh`

* * *

## **🛠 Step 2: Optimizing YARN Resource Management**

Since **YARN** manages computing resources, optimizing it ensures **efficient scheduling of jobs**.

### **1️⃣ Allocate More Memory to YARN**

👉 **Why?** Increasing memory ensures **MapReduce and Hive jobs have enough resources**.

📌 **Modify `yarn-site.xml`**

sh

""

`sudo nano /usr/local/hadoop/etc/hadoop/yarn-site.xml`

🔹 **Increase memory allocation**

xml

""

`<property>     <name>yarn.nodemanager.resource.memory-mb</name>     <value>8192</value>  <!-- 8GB per node --> </property>  <property>     <name>yarn.scheduler.maximum-allocation-mb</name>     <value>8192</value> </property>  <property>     <name>yarn.scheduler.minimum-allocation-mb</name>     <value>1024</value>  <!-- Minimum 1GB per container --> </property>`

📌 **Restart YARN**

sh

""

`stop-yarn.sh start-yarn.sh`

* * *

### **2️⃣ Increase Number of CPU Cores per Job**

👉 **Why?** Allocating more CPU cores speeds up **parallel processing**.

📌 **Modify `yarn-site.xml`**

xml

""

`<property>     <name>yarn.nodemanager.resource.cpu-vcores</name>     <value>4</value>  <!-- 4 cores per node --> </property>`

📌 **Restart YARN**

sh

""

`stop-yarn.sh start-yarn.sh`

* * *

## **🛠 Step 3: Optimizing Hive Query Performance**

Since **Hive translates SQL queries into MapReduce jobs**, optimizing it speeds up **big data analysis**.

### **1️⃣ Enable Tez Execution Engine**

👉 **Why?** **Tez is faster than MapReduce** for SQL-based queries.

📌 **Modify `hive-site.xml`**

sh

""

`sudo nano /usr/local/hive/conf/hive-site.xml`

🔹 **Enable Tez Execution**

xml

""

`<property>     <name>hive.execution.engine</name>     <value>tez</value> </property>`

📌 **Restart Hive**

sh

""

`exit hive`

* * *

### **2️⃣ Enable Query Caching**

👉 **Why?** Caching prevents re-running expensive queries.

📌 **Modify `hive-site.xml`**

xml

""

`<property>     <name>hive.compute.query.using.stats</name>     <value>true</value> </property>`

📌 **Restart Hive**

sh

""

`exit hive`

* * *

### **3️⃣ Partition Tables for Faster Queries**

👉 **Why?** **Partitioning reduces the amount of data scanned**, improving query speed.

📌 **Modify table creation**

sql

""

`CREATE TABLE employees_partitioned (     id INT,     name STRING,     salary FLOAT ) PARTITIONED BY (department STRING) STORED AS TEXTFILE;`

📌 **Add Partitioned Data**

sql

""

`ALTER TABLE employees_partitioned ADD PARTITION (department='Engineering') LOCATION '/user/hive/warehouse/employees/engineering';`

📌 **Query Partitioned Data**

sql

""

`SELECT * FROM employees_partitioned WHERE department='Engineering';`

✅ **This scans only the `Engineering` partition, making queries much faster**.

* * *

## **🛠 Step 4: Configuring Hadoop for Large-Scale Data Processing**

### **1️⃣ Enable Speculative Execution to Prevent Slow Tasks**

👉 **Why?** Sometimes **some tasks run slower** than others. This setting **launches backup tasks** to prevent slowdowns.

📌 **Modify `mapred-site.xml`**

sh

""

`sudo nano /usr/local/hadoop/etc/hadoop/mapred-site.xml`

🔹 **Enable Speculative Execution**

xml

""

`<property>     <name>mapreduce.map.speculative</name>     <value>true</value> </property>  <property>     <name>mapreduce.reduce.speculative</name>     <value>true</value> </property>`

📌 **Restart Hadoop**

sh

""

`stop-dfs.sh start-dfs.sh`

* * *

### **2️⃣ Enable Hadoop Compression to Reduce Data Size**

👉 **Why?** Compressed files **reduce disk usage** and **speed up processing**.

📌 **Modify `core-site.xml`**

sh

""

`sudo nano /usr/local/hadoop/etc/hadoop/core-site.xml`

🔹 **Enable Snappy Compression**

xml

""

`<property>     <name>io.compression.codecs</name>     <value>org.apache.hadoop.io.compress.SnappyCodec</value> </property>`

📌 **Restart Hadoop**

sh

""

`stop-dfs.sh start-dfs.sh`

* * *

# **✅ Hadoop & Hive Optimization Summary**

| Optimization | Description |
| --- | --- |
| **Increase HDFS Block Size** | Improves storage efficiency (Set to **256MB**) |
| **Increase YARN Memory & CPU Allocation** | Ensures better resource management (**8GB RAM, 4 cores per node**) |
| **Enable Tez Execution Engine** | Makes Hive queries faster by replacing MapReduce |
| **Use Table Partitioning in Hive** | **Reduces query execution time** by scanning only relevant data |
| **Enable Speculative Execution** | Prevents slow tasks from delaying jobs |
| **Enable Compression** | Saves **storage and speeds up processing** |

* * *


Add:

xml

""

`<configuration>     <property>         <name>yarn.resourcemanager.hostname</name>         <value>hadoop-master</value>     </property>     <property>         <name>yarn.nodemanager.aux-services</name>         <value>mapreduce_shuffle</value>     </property> </configuration>`

* * *

#### **4️⃣ Configure `mapred-site.xml` (MapReduce Engine)**

If missing, **create `mapred-site.xml`**:

sh

""

`sudo nano /usr/local/hadoop/etc/hadoop/mapred-site.xml`

Add:

xml

""

`<configuration>     <property>         <name>mapreduce.framework.name</name>         <value>yarn</value>     </property>     <property>         <name>yarn.app.mapreduce.am.env</name>         <value>HADOOP_MAPRED_HOME=/usr/local/hadoop</value>     </property>     <property>         <name>mapreduce.map.env</name>         <value>HADOOP_MAPRED_HOME=/usr/local/hadoop</value>     </property>     <property>         <name>mapreduce.reduce.env</name>         <value>HADOOP_MAPRED_HOME=/usr/local/hadoop</value>     </property> </configuration>`

* * *

### **3.2 Add Worker Nodes to `workers` File**

On the **master node (`hadoop-master`)**, edit:

sh

""

`sudo nano /usr/local/hadoop/etc/hadoop/workers`

Add:

""

`hadoop-worker-1 hadoop-worker-2`

* * *

### **3.3 Format HDFS Namenode**

On the **master node**, run:

sh

""

`hdfs namenode -format`

* * *

### **3.4 Start Hadoop Services**

On **the master node**, start all services:

sh

""

`start-dfs.sh start-yarn.sh`

Verify:

sh

""

`jps`

✅ Expected Output on Master:

nginx

""

`NameNode SecondaryNameNode ResourceManager Jps`

✅ Expected Output on Workers:

nginx

""

`DataNode NodeManager Jps`

* * *

## **🛠 Step 4: Configuring Hadoop Environment (`hadoop-env.sh`)**

After setting up the core Hadoop configurations, we also needed to **define the Java environment** for Hadoop to run properly.

### **4.1 Set `JAVA_HOME` and `HADOOP_MAPRED_HOME` in `hadoop-env.sh`**

This step was crucial because without setting `JAVA_HOME`, Hadoop services **would fail to start**.

1️⃣ **Edit the `hadoop-env.sh` file** on **each node (master + workers)**:

sh

""

`sudo nano /usr/local/hadoop/etc/hadoop/hadoop-env.sh`

2️⃣ **Find the following line (or add it if missing):**

sh

""

`# export JAVA_HOME=`

3️⃣ **Update it to point to your Java installation:**

sh

""

`export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64`

4️⃣ **Also, add the following line for MapReduce:**

sh

""

`export HADOOP_MAPRED_HOME=/usr/local/hadoop`

✅ **Final `hadoop-env.sh` should contain these key settings:**

sh

""

`export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 export HADOOP_HOME=/usr/local/hadoop export HADOOP_MAPRED_HOME=$HADOOP_HOME export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop export YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop`

5️⃣ **Save and exit** (`CTRL+X → Y → ENTER`).

6️⃣ **Apply the changes:**

sh

""

`source /usr/local/hadoop/etc/hadoop/hadoop-env.sh`

7️⃣ **Verify that `JAVA_HOME` and `HADOOP_MAPRED_HOME` are set properly:**

sh

""

`echo $JAVA_HOME echo $HADOOP_MAPRED_HOME`

✅ **Expected Output:**

swift

""

`/usr/lib/jvm/java-11-openjdk-amd64 /usr/local/hadoop`

* * *

### **4.2 Restart Hadoop Services**

After updating the environment settings, we restarted Hadoop services:

1️⃣ **Stop any running services (if necessary):**

sh

""

`stop-dfs.sh stop-yarn.sh`

2️⃣ **Restart Hadoop services:**

sh

""

`start-dfs.sh start-yarn.sh`

3️⃣ **Check if all services are running:**

sh

""

`jps`

✅ **Expected Output on Master (`hadoop-master`):**

nginx

""

`NameNode SecondaryNameNode ResourceManager Jps`

✅ **Expected Output on Workers (`hadoop-worker-1`, `hadoop-worker-2`):**

nginx

""

`DataNode NodeManager Jps`

* * *

### **📌 Step 5: Running HDFS Commands (Working with the Hadoop File System)**

After setting up the Hadoop environment, the next step was to **store and manage files in HDFS (Hadoop Distributed File System)**.

#### **Why Use HDFS?**

-   Stores **large-scale** data efficiently across multiple nodes.
-   Provides **fault tolerance** (data is replicated across nodes).
-   Can handle **high-throughput access** for large files.
* * *

## **🛠 Step 5.1: Verify HDFS is Running**

Before working with HDFS, we checked if our cluster was running properly.

1️⃣ **Run this command on the master node (`hadoop-master`)**:

sh

""

`hdfs dfsadmin -report`

✅ **Expected Output:**

-   Lists **all active DataNodes** (`hadoop-worker-1`, `hadoop-worker-2`).
-   Shows total **storage capacity and usage**.
* * *

## **🛠 Step 5.2: Basic HDFS Operations**

Now, we ran **basic HDFS commands** to interact with the file system.

### **1️⃣ Create a Directory in HDFS**

HDFS requires a **user directory** for storing files.

sh

""

`hdfs dfs -mkdir /user hdfs dfs -mkdir /user/tejasjay94`

✅ **Verify the directory exists:**

sh

""

`hdfs dfs -ls /user`

Expected Output:

pgsql

""

`Found 1 items drwxr-xr-x - tejasjay94 supergroup 0 2025-03-08  /user/tejasjay94`

* * *

### **2️⃣ Upload Files to HDFS**

To store data in HDFS, we **upload local files**.

1️⃣ **Create a sample text file locally:**

sh

""

`echo "Hadoop is powerful. Hadoop is scalable. Hadoop is open-source." > input.txt`

2️⃣ **Upload the file to HDFS:**

sh

""

`hdfs dfs -put input.txt /user/tejasjay94/`

3️⃣ **Verify that the file is uploaded:**

sh

""

`hdfs dfs -ls /user/tejasjay94/`

✅ Expected Output:

bash

""

`-rw-r--r--   1 tejasjay94 supergroup   58 2025-03-08  /user/tejasjay94/input.txt`

* * *

### **3️⃣ Read a File from HDFS**

To check the content of an HDFS file:

sh

""

`hdfs dfs -cat /user/tejasjay94/input.txt`

✅ Expected Output:

kotlin

""

`Hadoop is powerful. Hadoop is scalable. Hadoop is open-source.`

* * *

### **4️⃣ Download (Retrieve) a File from HDFS**

If we want to **copy a file from HDFS to our local system**, we use:

sh

""

`hdfs dfs -get /user/tejasjay94/input.txt my_local_input.txt`

✅ **Verify:**

sh

""

`cat my_local_input.txt`

Expected Output:

kotlin

""

`Hadoop is powerful. Hadoop is scalable. Hadoop is open-source.`

* * *

### **5️⃣ Delete a File from HDFS**

If we need to **remove a file** from HDFS:

sh

""

`hdfs dfs -rm /user/tejasjay94/input.txt`

✅ **Verify:**

sh

""

`hdfs dfs -ls /user/tejasjay94/`

✅ Expected Output: The file should be **gone**.

* * *

### **6️⃣ Delete a Directory from HDFS**

To remove an **entire directory**:

sh

""

`hdfs dfs -rm -r /user/tejasjay94`

✅ **This deletes the directory and all its files**.

* * *

## **🛠 Step 5.3: Summary of HDFS Commands**

| Command | Description |
| --- | --- |
| `hdfs dfs -ls /` | List files/directories in HDFS |
| `hdfs dfs -mkdir /path` | Create a new directory in HDFS |
| `hdfs dfs -put localfile /path` | Upload a file to HDFS |
| `hdfs dfs -cat /path/file.txt` | Read file contents from HDFS |
| `hdfs dfs -get /path/file.txt localfile` | Download a file from HDFS |
| `hdfs dfs -rm /path/file.txt` | Delete a file from HDFS |
| `hdfs dfs -rm -r /path` | Delete a directory from HDFS |

* * *

### **📌 Step 6: Running a Python-Based MapReduce Job in Hadoop**

Now that we have **HDFS set up**, it's time to process data using **MapReduce**.
We will implement a **Word Count program** using Python.

* * *

## **🛠 Step 6.1: Understanding MapReduce**

MapReduce **processes big data in parallel** by splitting tasks across multiple nodes.

1️⃣ **Mapper**

-   Reads input data **line by line**.
-   Emits **key-value pairs (word → count)**.

2️⃣ **Reducer**

-   Aggregates key-value pairs.
-   Produces the **final count** for each word.
* * *

## **🛠 Step 6.2: Prepare Input Data**

Before running MapReduce, we **create input data**.

1️⃣ **Create a text file on the master node (`hadoop-master`)**:

sh

""

`echo "Hadoop is powerful. Hadoop is scalable. Hadoop is open-source." > input.txt`

2️⃣ **Upload the file to HDFS:**

sh

""

`hdfs dfs -mkdir /user/tejasjay94/input hdfs dfs -put input.txt /user/tejasjay94/input/`

3️⃣ **Verify the file in HDFS:**

sh

""

`hdfs dfs -ls /user/tejasjay94/input/`

✅ Expected Output:

css

""

`-rw-r--r--   1 tejasjay94 supergroup   58 2025-03-08  /user/tejasjay94/input/input.txt`

* * *

## **🛠 Step 6.3: Write the Python MapReduce Code**

### **1️⃣ Create `mapper.py` (Word Count Mapper)**

1.  Open a new file:

    sh

    ""

    `nano mapper.py`

2.  Paste this Python code:

    python

    ""

    `#!/usr/bin/env python3 import sys  # Read input from standard input for line in sys.stdin:     words = line.strip().split()     for word in words:         print(f"{word}\t1")  # Output: word <TAB> count`

3.  **Save and exit** (`CTRL+X → Y → ENTER`).
* * *

### **2️⃣ Create `reducer.py` (Word Count Reducer)**

1.  Open a new file:

    sh

    ""

    `nano reducer.py`

2.  Paste this Python code:

    python

    ""

    `#!/usr/bin/env python3 import sys  current_word = None current_count = 0  for line in sys.stdin:     word, count = line.strip().split("\t")     count = int(count)      if word == current_word:         current_count += count     else:         if current_word:             print(f"{current_word}\t{current_count}")  # Print previous word count         current_word = word         current_count = count  # Print the last word count if current_word:     print(f"{current_word}\t{current_count}")`

3.  **Save and exit** (`CTRL+X → Y → ENTER`).
* * *

### **3️⃣ Make Python Scripts Executable**

sh

""

`chmod +x mapper.py reducer.py`

* * *

## **🛠 Step 6.4: Run the MapReduce Job in Hadoop**

Now, we run the **MapReduce job using Hadoop Streaming API**.

### **Submit the Job**

sh

""

`hadoop jar /usr/local/hadoop/share/hadoop/tools/lib/hadoop-streaming-3.3.6.jar \   -input /user/tejasjay94/input/input.txt \   -output /user/tejasjay94/output \   -mapper mapper.py \   -reducer reducer.py \   -file mapper.py \   -file reducer.py`

✅ **Explanation of the Command:**

-   `-input` → Input file location in HDFS.
-   `-output` → Output directory in HDFS.
-   `-mapper` → Specifies the **Python mapper script**.
-   `-reducer` → Specifies the **Python reducer script**.
-   `-file` → Uploads Python scripts to Hadoop.
* * *

## **🛠 Step 6.5: Check the Output**

1️⃣ **List the output directory in HDFS**:

sh

""

`hdfs dfs -ls /user/tejasjay94/output/`

✅ Expected Output:

bash

""

`-rw-r--r--   1 tejasjay94 supergroup         0 2025-03-08  /user/tejasjay94/output/_SUCCESS -rw-r--r--   1 tejasjay94 supergroup        58 2025-03-08  /user/tejasjay94/output/part-00000`

👉 `_SUCCESS` file means the job ran successfully.

* * *

2️⃣ **View the word count results:**

sh

""

`hdfs dfs -cat /user/tejasjay94/output/part-00000`

✅ Expected Output:

kotlin

""

`Hadoop    3 is        3 open-source. 1 powerful. 1 scalable. 1`

* * *




