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

