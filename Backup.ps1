<#PSScriptInfo

.AUTHOR Kunal Aggarwal

.VERSION 1.0

.PROJECTURI 

.SYNOPSIS
Backup All Index Collection from Solr Cluster

.DESCRIPTION
Backup all Index Collection from Solr Cluster. Uses Solr collection List api to get collection and create backup using Backup api. Require Solr 6.0 or greater version.

.PARAMETER server
IP address of the solr server the collection belongs to. Default value is localhost

.PARAMETER path
Share Drive / DFS path to save the collection backup

.PARAMETER port
Port on which solr server is running. Default value is 8983

.PARAMETER basic_auth
Flag to validate if Basic Authentication is enabled. Default value is false

.PARAMETER username
Username to authenticate Rest Api if Basic Authentication is enable. Default value is null

.PARAMETER password
Password to authenticate Rest Api if Basic Authentication is enable. Default value is null

.ALIASES None

.EXAMPLE
1. Backup collections from Solr cluster having node running at 127.0.0.1 port 8983 without any authentication and save it to \\127.0.0.1\collection_backup. 
   Invoke-SolrBackupAllCollections -server "127.0.0.1" -port 8983 -path "\\127.0.0.1\collection_backup"

2. Backup collections from Solr cluster having node running at 127.0.0.1 port 8983 with basic authentication and save it to \\127.0.0.1\collection_backup. 
   Invoke-SolrBackupAllCollections -server "127.0.0.1" -port 8983 -path "\\127.0.0.1\collection_backup" -basic_auth=true -username="user" -password="password"

#>


function Invoke-SolrBackupAllCollections {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$server = "localhost",

        [parameter(Mandatory=$true)]
        [string]$path,

        [parameter(Mandatory=$true)]
        [int]$port=8983,

        [parameter(Mandatory=$false)]
        [bool]$basic_auth=$false,
        
        [parameter(Mandatory=$false)]
        [string]$username="",

        [parameter(Mandatory=$false)]
        [string]$password=""

    )

    $headers = @{"Content-Type"="application/json"}

    if($basic_auth -eq $true){
        if($username -or $password){
		Write-Output "Enter Valid Username and Password"
		exit -1
	}
	
	$pair = "${username}:${password}"
	$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
	$base64 = [System.Convert]::ToBase64String($bytes)
	$basicAuth = "Basic $base64"
	$headers = @{Authorization = $basicAuth}
    }

    $url = "http://${server}:${port}/solr/admin/collections?action=list&wt=json"
    $resp = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
    $collections = $resp.collections
    $currentDirectory = (Get-Item -Path ".\" -Verbose).FullName

    foreach($collection in $collections){
        $collection_temp_path = $path + "\" + $collection
        if(Test-Path $collection_temp_path){
            Remove-Item $collection_temp_path -Recurse
        }

        $BackupUrl = "http://${server}:${port}/solr/admin/collections?action=BACKUP&name=${collection}&collection=${collection}&location=${path}&wt=json"
        try{
            $JsonResponse = Invoke-RestMethod -Uri $BackupUrl -Method Get -Headers $headers
            Write-Host $collection "Backup Created" -ForegroundColor Green
        }
        catch{
            Write-Host $collection "Backup Failed" -ForegroundColor Red
            $errorPath = $currentDirectory + "\error.txt"
            $collection + "Backup Failed" | Add-Content -Path $errorPath
        }
    }
}
