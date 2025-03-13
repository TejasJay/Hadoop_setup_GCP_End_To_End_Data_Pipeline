# Hadoop Ecosystem Manual Setup on GCP VM

## **1\. GCP VM Setup**

### **Create a VM Instance**

1.  Go to [Google Cloud Console](https://console.cloud.google.com/).
2.  Create a new Compute Engine VM.
    -   Machine Type: `n1-standard-4`
    -   OS: Ubuntu 20.04 LTS
    -   Boot Disk: 100GB
    -   Allow HTTP/HTTPS Traffic
3.  SSH into the VM:

    ```sh
    gcloud compute ssh hadoop-master --zone=us-east1-b
    ```

* * *

## **2\. Install Java 8**

1.  Remove existing Java:

    ```sh
    sudo apt remove -y openjdk-11-jdk
    ```

2.  Install Java 8:

    ```sh
    sudo apt update && sudo apt install -y openjdk-8-jdk
    ```

3.  Verify installation:

    ```sh
    java -version
    ```

4.  Set JAVA\_HOME:

    ```sh
    echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> ~/.bashrc
    source ~/.bashrc
    ```

* * *

## **3\. Install Hadoop (HDFS + YARN + MapReduce)**

1.  Download Hadoop:

    ```sh
    cd /opt
    sudo wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
    ```

2.  Extract and move:

    ```sh
    sudo tar -xvzf hadoop-3.3.6.tar.gz
    sudo mv hadoop-3.3.6 /usr/local/hadoop
    ```

3.  Set up environment variables:

    ```sh
    echo "export HADOOP_HOME=/usr/local/hadoop" >> ~/.bashrc
    echo "export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH" >> ~/.bashrc
    echo "export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop" >> ~/.bashrc
    source ~/.bashrc
    ```

4.  Verify Hadoop installation:

    ```sh
    hadoop version
    ```

* * *

## **4\. Configure HDFS and YARN**

### **Edit Configuration Files**

1.  **core-site.xml**:

    ```sh
    nano /usr/local/hadoop/etc/hadoop/core-site.xml
    ```

    Add:

    ```xml
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
    ```

2.  **hdfs-site.xml**:

    ```sh
    nano /usr/local/hadoop/etc/hadoop/hdfs-site.xml
    ```

    Add:

    ```xml
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:///usr/local/hadoop/data/namenode</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///usr/local/hadoop/data/datanode</value>
    </property>
    ```

3.  **yarn-site.xml**:

    ```sh
    nano /usr/local/hadoop/etc/hadoop/yarn-site.xml
    ```

    Add:

    ```xml
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    ```

4.  **mapred-site.xml**:

    ```sh
    cp /usr/local/hadoop/etc/hadoop/mapred-site.xml.template /usr/local/hadoop/etc/hadoop/mapred-site.xml
    nano /usr/local/hadoop/etc/hadoop/mapred-site.xml
    ```

    Add:

    ```xml
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    ```

* * *

## **5\. Create Hadoop Storage Directories**

```sh
sudo mkdir -p /usr/local/hadoop/data/namenode
sudo mkdir -p /usr/local/hadoop/data/datanode
sudo chown -R $USER:$USER /usr/local/hadoop/data
```

Format the NameNode:

```sh
hdfs namenode -format
```

* * *

## **6\. Start Hadoop Services**

### **Start HDFS**

```sh
start-dfs.sh
```

### **Start YARN**

```sh
start-yarn.sh
```

### **Verify Processes**

```sh
jps
```

You should see:

```
NameNode
DataNode
ResourceManager
NodeManager
SecondaryNameNode
```

* * *

## **7\. Fix Permission Issues (If Any)**

### **Set Correct File Permissions**

```sh
sudo chown -R $USER:$USER /usr/local/hadoop
sudo chown -R $USER:$USER /usr/local/hadoop/data
```

### **Enable Passwordless SSH**

```sh
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Test SSH:

```sh
ssh localhost
```

If SSH asks for a password, check `/etc/ssh/sshd_config`:

```sh
sudo nano /etc/ssh/sshd_config
```

Ensure these lines exist and are **not commented out (`#`)**:

```
PermitRootLogin yes
PubkeyAuthentication yes
PasswordAuthentication yes
```

Restart SSH:

```sh
sudo systemctl restart ssh
```

* * *

## **8\. Verify Hadoop Setup**

Run:

```sh
hdfs dfsadmin -report
```

If it shows the **live datanode**, the setup is successful! 🎉

* * *


