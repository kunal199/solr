# Solr
Powershell scripts to administer solr cluster

## Collection Backup
Powershell Script to backup all index collections from solr cluster.

**Requirements**

You need to have 3.0 or newer version of Powershell installed.

**Steps to Use**
1. `Import-Module ./Backup.ps1`
2. `Invoke-SolrBackupAllCollections -server "127.0.0.1" -port 8983 -path "\\127.0.0.1\collection_backup"` (Refer Example for more information)

## Collection Restore
Powershell Script to restore index collection to solr cluster.

**Requirements**

You need to have 3.0 or newer version of Powershell installed.

**Steps to Use**
1. `Import-Module ./Restore.ps1`
2. `Invoke-SolrRestoreCollection -server "127.0.0.1" -port 8983 -backup_name "test_collection" -path "\\127.0.0.1\collection_backup" -name "test_collection"` (Refer Example for more information)

## Create New Solr Cluster
Powershell Script to install and configure multi-node solr cluster.

**Requirements**

You need to have 3.0 or newer version of Powershell installed.

**Steps to Use**
1. `Import-Module ./New-Solrcluster.ps1`
2. `New-SolrCluster -version 6.1.0 -path "E:\" -jvm 16 -machines "127.0.0.1:2181,127.0.0.2:2181,127.0.0.3:2181"` (Refer Example for more information)

## Create New Zookeeper Cluster
Powershell Script to install and configure multi-node zookeeper cluster.

**Requirements**

You need to have 3.0 or newer version of Powershell installed.

**Steps to Use**
1. `Import-Module new-zookeepercluster.ps1`
2. `New-ZookeeperCluster -zooLink "http://localhost/zookeeper.zip" -destination "E:\" -javaLink "http://localhost/jdk.exe" -nodeCount 3 -serverId 1 -nodes "server1,server2,server3"` (Refer Example for more information)
