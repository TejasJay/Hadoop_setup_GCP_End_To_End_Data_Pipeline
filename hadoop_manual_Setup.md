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

CopyEdit

`gcloud compute ssh hadoop-master`

* * *

## **🛠 Step 2: Installing Java and Hadoop**

### **2.1 Install Java (Required for Hadoop)**

On **each node (master + workers)**, install Java:

sh

CopyEdit

`sudo apt update sudo apt install openjdk-11-jdk -y`

Verify:

sh

CopyEdit

`java -version`

✅ Expected Output:

nginx

CopyEdit

`openjdk version "11.0.x"`

* * *

### **2.2 Download and Install Hadoop**

On **each node (master + workers)**:

1️⃣ **Download Hadoop**:

sh

CopyEdit

`wget https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz`

2️⃣ **Extract and move to `/usr/local/`**:

sh

CopyEdit

`tar -xvzf hadoop-3.3.6.tar.gz sudo mv hadoop-3.3.6 /usr/local/hadoop`

* * *

### **2.3 Set Environment Variables**

On **each node (master + workers)**:

1️⃣ **Edit `.bashrc`:**

sh

CopyEdit

`nano ~/.bashrc`

2️⃣ **Add these lines at the bottom**:

sh

CopyEdit

`export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 export HADOOP_HOME=/usr/local/hadoop export HADOOP_MAPRED_HOME=$HADOOP_HOME export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop export YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop`

3️⃣ **Save and apply changes**:

sh

CopyEdit

`source ~/.bashrc`

4️⃣ **Verify that Hadoop is recognized**:

sh

CopyEdit

`hadoop version`

✅ Expected Output: Hadoop version details.

* * *

## **🛠 Step 3: Configuring Hadoop (HDFS, YARN, MapReduce)**

### **3.1 Update Configuration Files**

On **each node (master + workers)**:

#### **1️⃣ Configure `core-site.xml` (HDFS Settings)**

sh

CopyEdit

`sudo nano /usr/local/hadoop/etc/hadoop/core-site.xml`

Add:

xml

CopyEdit

`<configuration>     <property>         <name>fs.defaultFS</name>         <value>hdfs://hadoop-master:9000</value>     </property>     <property>         <name>hadoop.tmp.dir</name>         <value>/usr/local/hadoop/tmp</value>     </property> </configuration>`

* * *

#### **2️⃣ Configure `hdfs-site.xml` (HDFS Storage Settings)**

sh

CopyEdit

`sudo nano /usr/local/hadoop/etc/hadoop/hdfs-site.xml`

Add:

xml

CopyEdit

`<configuration>     <property>         <name>dfs.replication</name>         <value>2</value>     </property>     <property>         <name>dfs.namenode.name.dir</name>         <value>file:///usr/local/hadoop/hdfs/namenode</value>     </property>     <property>         <name>dfs.datanode.data.dir</name>         <value>file:///usr/local/hadoop/hdfs/datanode</value>     </property> </configuration>`

* * *

#### **3️⃣ Configure `yarn-site.xml` (YARN Resource Manager)**

sh

CopyEdit

`sudo nano /usr/local/hadoop/etc/hadoop/yarn-site.xml`

Add:

xml

CopyEdit

`<configuration>     <property>         <name>yarn.resourcemanager.hostname</name>         <value>hadoop-master</value>     </property>     <property>         <name>yarn.nodemanager.aux-services</name>         <value>mapreduce_shuffle</value>     </property> </configuration>`

* * *

#### **4️⃣ Configure `mapred-site.xml` (MapReduce Engine)**

If missing, **create `mapred-site.xml`**:

sh

CopyEdit

`sudo nano /usr/local/hadoop/etc/hadoop/mapred-site.xml`

Add:

xml

CopyEdit

`<configuration>     <property>         <name>mapreduce.framework.name</name>         <value>yarn</value>     </property>     <property>         <name>yarn.app.mapreduce.am.env</name>         <value>HADOOP_MAPRED_HOME=/usr/local/hadoop</value>     </property>     <property>         <name>mapreduce.map.env</name>         <value>HADOOP_MAPRED_HOME=/usr/local/hadoop</value>     </property>     <property>         <name>mapreduce.reduce.env</name>         <value>HADOOP_MAPRED_HOME=/usr/local/hadoop</value>     </property> </configuration>`

* * *

### **3.2 Add Worker Nodes to `workers` File**

On the **master node (`hadoop-master`)**, edit:

sh

CopyEdit

`sudo nano /usr/local/hadoop/etc/hadoop/workers`

Add:

CopyEdit

`hadoop-worker-1 hadoop-worker-2`

* * *

### **3.3 Format HDFS Namenode**

On the **master node**, run:

sh

CopyEdit

`hdfs namenode -format`

* * *

### **3.4 Start Hadoop Services**

On **the master node**, start all services:

sh

CopyEdit

`start-dfs.sh start-yarn.sh`

Verify:

sh

CopyEdit

`jps`

✅ Expected Output on Master:

nginx

CopyEdit

`NameNode SecondaryNameNode ResourceManager Jps`

✅ Expected Output on Workers:

nginx

CopyEdit

`DataNode NodeManager Jps`

* * *

## **🛠 Step 4: Configuring Hadoop Environment (`hadoop-env.sh`)**

After setting up the core Hadoop configurations, we also needed to **define the Java environment** for Hadoop to run properly.

### **4.1 Set `JAVA_HOME` and `HADOOP_MAPRED_HOME` in `hadoop-env.sh`**

This step was crucial because without setting `JAVA_HOME`, Hadoop services **would fail to start**.

1️⃣ **Edit the `hadoop-env.sh` file** on **each node (master + workers)**:

sh

CopyEdit

`sudo nano /usr/local/hadoop/etc/hadoop/hadoop-env.sh`

2️⃣ **Find the following line (or add it if missing):**

sh

CopyEdit

`# export JAVA_HOME=`

3️⃣ **Update it to point to your Java installation:**

sh

CopyEdit

`export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64`

4️⃣ **Also, add the following line for MapReduce:**

sh

CopyEdit

`export HADOOP_MAPRED_HOME=/usr/local/hadoop`

✅ **Final `hadoop-env.sh` should contain these key settings:**

sh

CopyEdit

`export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 export HADOOP_HOME=/usr/local/hadoop export HADOOP_MAPRED_HOME=$HADOOP_HOME export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop export YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop`

5️⃣ **Save and exit** (`CTRL+X → Y → ENTER`).

6️⃣ **Apply the changes:**

sh

CopyEdit

`source /usr/local/hadoop/etc/hadoop/hadoop-env.sh`

7️⃣ **Verify that `JAVA_HOME` and `HADOOP_MAPRED_HOME` are set properly:**

sh

CopyEdit

`echo $JAVA_HOME echo $HADOOP_MAPRED_HOME`

✅ **Expected Output:**

swift

CopyEdit

`/usr/lib/jvm/java-11-openjdk-amd64 /usr/local/hadoop`

* * *

### **4.2 Restart Hadoop Services**

After updating the environment settings, we restarted Hadoop services:

1️⃣ **Stop any running services (if necessary):**

sh

CopyEdit

`stop-dfs.sh stop-yarn.sh`

2️⃣ **Restart Hadoop services:**

sh

CopyEdit

`start-dfs.sh start-yarn.sh`

3️⃣ **Check if all services are running:**

sh

CopyEdit

`jps`

✅ **Expected Output on Master (`hadoop-master`):**

nginx

CopyEdit

`NameNode SecondaryNameNode ResourceManager Jps`

✅ **Expected Output on Workers (`hadoop-worker-1`, `hadoop-worker-2`):**

nginx

CopyEdit

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

CopyEdit

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

CopyEdit

`hdfs dfs -mkdir /user hdfs dfs -mkdir /user/tejasjay94`

✅ **Verify the directory exists:**

sh

CopyEdit

`hdfs dfs -ls /user`

Expected Output:

pgsql

CopyEdit

`Found 1 items drwxr-xr-x - tejasjay94 supergroup 0 2025-03-08  /user/tejasjay94`

* * *

### **2️⃣ Upload Files to HDFS**

To store data in HDFS, we **upload local files**.

1️⃣ **Create a sample text file locally:**

sh

CopyEdit

`echo "Hadoop is powerful. Hadoop is scalable. Hadoop is open-source." > input.txt`

2️⃣ **Upload the file to HDFS:**

sh

CopyEdit

`hdfs dfs -put input.txt /user/tejasjay94/`

3️⃣ **Verify that the file is uploaded:**

sh

CopyEdit

`hdfs dfs -ls /user/tejasjay94/`

✅ Expected Output:

bash

CopyEdit

`-rw-r--r--   1 tejasjay94 supergroup   58 2025-03-08  /user/tejasjay94/input.txt`

* * *

### **3️⃣ Read a File from HDFS**

To check the content of an HDFS file:

sh

CopyEdit

`hdfs dfs -cat /user/tejasjay94/input.txt`

✅ Expected Output:

kotlin

CopyEdit

`Hadoop is powerful. Hadoop is scalable. Hadoop is open-source.`

* * *

### **4️⃣ Download (Retrieve) a File from HDFS**

If we want to **copy a file from HDFS to our local system**, we use:

sh

CopyEdit

`hdfs dfs -get /user/tejasjay94/input.txt my_local_input.txt`

✅ **Verify:**

sh

CopyEdit

`cat my_local_input.txt`

Expected Output:

kotlin

CopyEdit

`Hadoop is powerful. Hadoop is scalable. Hadoop is open-source.`

* * *

### **5️⃣ Delete a File from HDFS**

If we need to **remove a file** from HDFS:

sh

CopyEdit

`hdfs dfs -rm /user/tejasjay94/input.txt`

✅ **Verify:**

sh

CopyEdit

`hdfs dfs -ls /user/tejasjay94/`

✅ Expected Output: The file should be **gone**.

* * *

### **6️⃣ Delete a Directory from HDFS**

To remove an **entire directory**:

sh

CopyEdit

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

CopyEdit

`echo "Hadoop is powerful. Hadoop is scalable. Hadoop is open-source." > input.txt`

2️⃣ **Upload the file to HDFS:**

sh

CopyEdit

`hdfs dfs -mkdir /user/tejasjay94/input hdfs dfs -put input.txt /user/tejasjay94/input/`

3️⃣ **Verify the file in HDFS:**

sh

CopyEdit

`hdfs dfs -ls /user/tejasjay94/input/`

✅ Expected Output:

css

CopyEdit

`-rw-r--r--   1 tejasjay94 supergroup   58 2025-03-08  /user/tejasjay94/input/input.txt`

* * *

## **🛠 Step 6.3: Write the Python MapReduce Code**

### **1️⃣ Create `mapper.py` (Word Count Mapper)**

1.  Open a new file:

    sh

    CopyEdit

    `nano mapper.py`

2.  Paste this Python code:

    python

    CopyEdit

    `#!/usr/bin/env python3 import sys  # Read input from standard input for line in sys.stdin:     words = line.strip().split()     for word in words:         print(f"{word}\t1")  # Output: word <TAB> count`

3.  **Save and exit** (`CTRL+X → Y → ENTER`).
* * *

### **2️⃣ Create `reducer.py` (Word Count Reducer)**

1.  Open a new file:

    sh

    CopyEdit

    `nano reducer.py`

2.  Paste this Python code:

    python

    CopyEdit

    `#!/usr/bin/env python3 import sys  current_word = None current_count = 0  for line in sys.stdin:     word, count = line.strip().split("\t")     count = int(count)      if word == current_word:         current_count += count     else:         if current_word:             print(f"{current_word}\t{current_count}")  # Print previous word count         current_word = word         current_count = count  # Print the last word count if current_word:     print(f"{current_word}\t{current_count}")`

3.  **Save and exit** (`CTRL+X → Y → ENTER`).
* * *

### **3️⃣ Make Python Scripts Executable**

sh

CopyEdit

`chmod +x mapper.py reducer.py`

* * *

## **🛠 Step 6.4: Run the MapReduce Job in Hadoop**

Now, we run the **MapReduce job using Hadoop Streaming API**.

### **Submit the Job**

sh

CopyEdit

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

CopyEdit

`hdfs dfs -ls /user/tejasjay94/output/`

✅ Expected Output:

bash

CopyEdit

`-rw-r--r--   1 tejasjay94 supergroup         0 2025-03-08  /user/tejasjay94/output/_SUCCESS -rw-r--r--   1 tejasjay94 supergroup        58 2025-03-08  /user/tejasjay94/output/part-00000`

👉 `_SUCCESS` file means the job ran successfully.

* * *

2️⃣ **View the word count results:**

sh

CopyEdit

`hdfs dfs -cat /user/tejasjay94/output/part-00000`

✅ Expected Output:

kotlin

CopyEdit

`Hadoop    3 is        3 open-source. 1 powerful. 1 scalable. 1`

* * *




