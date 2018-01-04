# Solr
Powershell scripts to administer solr cluster

## Collection Backup
Powershell Script to backup all index collections from solr cluster.

**Requirements**

You need to have a latest version of Powershell installed.

**Steps to Use**
1. `Import-Module ./Backup.ps1`
2. `Invoke-SolrBackupAllCollections -server "127.0.0.1" -port 8983 -path "\\127.0.0.1\collection_backup"` (Refer Example for more information)
