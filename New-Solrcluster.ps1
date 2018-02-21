<#PSScriptInfo
.AUTHOR Kunal Aggarwal
.VERSION V1.0
.SYNOPSIS
Setup Multi Node Solr Cluster
.DESCRIPTION
Setup Multinode Zookeeper cluster on Microsoft Windows Server. Script downloads the Solr source code from apache archive based on version provided.
.PARAMETER version
Version of Solr to be installed. (Mandatory)
.PARAMETER path
Path of solr root folder. Script will extract Solr setup at this location. (Mandatory)
.PARAMETER jvm
Java Virtual Machine (JVM) heap size. Default is 8 GB
.PARAMETER machines
Pass comma separated Machine Name/IP:Port string to be configured.
.EXAMPLE
Import-Module .\New-Solrcluster.ps1
New-SolrCluster -version 6.1.0 -path "E:\" -jvm 16 -machines "127.0.0.1:2181,127.0.0.2:2181,127.0.0.3:2181"

#>


function New-SolrCluster {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$version = "6.1.0",

        [parameter(Mandatory=$true)]
        [Alias("path")]
        [ValidateNotNullOrEmpty()]
        [string]$destination,

        [parameter]
        [Alias("jvm")]
        [int]$jvmheap = 8,

        [parameter(Mandatory=$true)]
        [Alias("machines")]
        [ValidateNotNullOrEmpty()]
        [string]$machineNames

    )

    
    $url="http://archive.apache.org/dist/lucene/solr/"
    $downloadUrl = "${url}${version}/solr-${version}.zip"
    $downloadPath = "${PSScriptRoot}\solr-${version}.zip"
    $nssmDownloadUrl = "https://nssm.cc/release/nssm-2.24.zip"
    $nssmDownloadPath = "${PSScriptRoot}\nssm-2.24.zip"
    $nssmPath = "${PSScriptRoot}"

    if(!(Test-Path -Path $downloadPath)){
        Write-Host "Downloading Solr Setup from ${url} Version ${version}"
        (New-Object System.Net.WebClient).DownloadFile($downloadUrl,$downloadPath)
    }
    if(!(Test-Path -Path $nssmDownloadPath)){
        Write-Host "Downloading NSSM Setup from ${nssmDownloadUrl}"
        (New-Object System.Net.WebClient).DownloadFile($nssmDownloadUrl,$nssmDownloadPath)
    }
    if(Test-Path -Path $destination){
        Write-Host "Extracting Solr Setup at ${destination}"
        $shellApp = New-Object -com shell.application
        $dest = $shellApp.namespace($destination)
        $dest.Copyhere($shellApp.namespace($downloadPath).items())
        Write-Host "Solr Setup Extraction Successfull"
        Remove-Item "${destination}\solr-${version}\example"
    }

    "bin\solr start -c -f -z '${machineNames}' -m ${jvmheap}g"|Out-File "${destination}\solr-${version}\startSolr.bat" -Encoding ascii

    if(Test-Path -path "${destination}\solr-${version}\startSolr.bat"){
        if(Test-Path -Path $nssmDownloadPath){
            try{
            
                Write-Host "Extracting NSSM Installer at ${nssmPath}"
                $shellApp = New-Object -com shell.application
                $dest = $shellApp.NameSpace($nssmPath)
                $dest.CopyHere($shellApp.NameSpace($nssmDownloadPath).items())
                Write-Host "NSSM Extraction Successfull"            

                cd "${nssmPath}\nssm-2.24\win64"
                .\nssm install solr "${destination}\solr-${version}\startSolr.bat"
            
                Write-Host "Service Installation Successfull" -ForegroundColor Green
            }
            catch{
                Write-Error "Service Installation Failed"
            }
        }
    }
    #Cleanup
    if(Test-Path -Path $nssmDownloadPath){
        Remove-Item -Path $nssmDownloadPath
    }
    if(Test-Path -Path $downloadPath){
        Remove-Item -Path $downloadPath
    }
}
