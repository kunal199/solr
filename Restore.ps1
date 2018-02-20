<#PSScriptInfo

.AUTHOR Kunal Aggarwal
.VERSION 1.0
.SYNOPSIS
Restore Index Collection from Backup
.DESCRIPTION
Restore index collection from backup. Uses SOLR Restore Api to create new collection. Requires Solr 6.0 or greater version.
.PARAMETER server
IP Address of Solr server where collection need to be created.
.PARAMETER port
Port on which solr server is running. Default value is 8983
.PARAMETER backup_name
Name of the backup available on backup disk.
.PARAMETER path
File Sytem path of the solr backup.
.PARAMETER collection
Name of the collecton to be created.
.PARAMETER basic_auth
Flag to validate if Basic Authentication is enabled. Default value is false
.PARAMETER username
Username to authenticate Rest Api if Basic Authentication is enable. Default value is null
.PARAMETER password
Password to authenticate Rest Api if Basic Authentication is enable. Default value is null
.ALIASES None
.EXAMPLES
1. Restore Collection to Solr Cluster having node running at 127.0.0.1 port 8983 without basic authentication. Backup is available at \\127.0.0.1\collection_backup and name of backup folder is test_collection
Invoke-SolrRestoreCollection -server "127.0.0.1" -port 8983 -backup_name "test_collection" -path "\\127.0.0.1\collection_backup" -name "test_collection"
2. Restore Collection to Solr Cluster having node running at 127.0.0.1 port 8983 with basic authentication. Backup is available at \\127.0.0.1\collection_backup and name of backup folder is test_collection
Invoke-SolrRestoreCollection -server "127.0.0.1" -port 8983 -backup_name "test_collection" -path "\\127.0.0.1\collection_backup" -name "test_collection" -basic_auth=true -username "user" -password "pass"
 
#>

function Invoke-SolrRestoreCollection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$server = "localhost",

        [Parameter(Mandatory=$true)]
        [int]$port = 8983,

        [Parameter(Mandatory=$true)]
        [string]$backup_name,

        [Parameter(Mandatory=$true)]
        [string]$path,

        [Parameter(Mandatory=$true)]
        [string]$collection,

        [Parameter(Mandatory=$false)]
        [bool]$basic_auth=$false,

        [Parameter(Mandatory=$false)]
        [string]$username="",

        [Parameter(Mandatory=$false)]
        [string]$password=""
    )

    $headers = @{"Content-Type"="application/json"}
    $currentDirectory = (Get-Item -Path ".\" -Verbose).FullName

    if($basic_auth -eq $true){
        if(($username -eq "") -or ($password -eq "")){
            Write-Host "Enter Valid Username and Password" -ForegroundColor Red
            exit -1
        }

        $pair = "${username}:${password}"
        $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
        $base64 = [System.Convert]::ToBase64String($bytes)
        $headers = @{Authorization=$base64}
    }

    $url = "http://${server}:${port}/solr/admin/collections?action=RESTORE&name=${backup_name}&location=${path}&collection=${collection}"
    try{
        $resp = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
        Write-Host $collection "Created Successfully" -ForegroundColor Green
    }
    catch{
        Write-Host $collection "creation failed" -ForegroundColor Red
        $errorPath = $currentDirectory + "\restore_error.txt"
        $collection + " Restore Failed" | Add-Content -Path $errorPath

    }



}