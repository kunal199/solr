<#PSScriptInfo
.AUTHOR Kunal Aggarwal
.VERSION V1.0
.SYNOPSIS
Setup Zookeeper Cluster
.DESCRIPTION
Setup Multinode Zookeeper cluster on Microsoft Windows Server.
.PARAMETER zooLink
Zookeeper Archive Blob storage link.
.PARAMETER destination
File System Path to extract and install zookeeper.
.PARAMETER javaLink
JAVA JDK installer download link.
.PARAMETER nodeCount
Number of Nodes in Zookeeper cluster. Default value is 3
.PARAMETER serverId
Server/Node Id to be configured in myid file in data folder.
.PARAMETER nodes
Comma separated string of machine Name/IP available in cluster.
.EXAMPLE
Import-Module new-zookeepercluster.ps1
New-ZookeeperCluster -zooLink "http://localhost/zookeeper.zip" -destination "E:\" -javaLink "http://localhost/jdk.exe" -nodeCount 3 -serverId 1 -nodes "server1,server2,server3"

#>

function New-ZookeeperCluster {
    
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [Alias("zooLink")]
        [ValidateNotNullOrEmpty()]
        [string]$zooDownloadLink,

        [parameter(Mandatory=$true)]
        [Alias("destination")]
        [ValidateNotNullOrEmpty()]
        [string]$destination,

        [parameter(Mandatory=$true)]
        [Alias("javaLink")]
        [ValidateNotNullOrEmpty()]
        [string]$javaDownloadLink,

        [parameter]
        [int]$nodeCount = 3,

        [parameter(Mandatory=$true)]
        [Alias("serverId")]
        [ValidateNotNullOrEmpty()]
        [int]$zookeeperId = 1,

        [parameter(Mandatory=$true)]
        [Alias("nodes")]
        [ValidateNotNullOrEmpty()]
        [string]$nodeAddress
    
    )

    $zooDownloadPath = "$PSScriptRoot\zookeeper.zip"
    $javaInstallerPath = "${PSScriptRoot}\jdk-8u161-windows-x64.exe"
    $nssmDownloadUrl = "https://nssm.cc/release/nssm-2.24.zip"
    $nssmDownloadPath = "${PSScriptRoot}\nssm-2.24.zip"
    $nssmPath = "${PSScriptRoot}"


    if(!(Test-Path -Path $zooDownloadPath)){
        Write-Host "Downloading Zookeeper Installer Archive"
        (New-Object System.Net.WebClient).DownloadFile($zooDownloadLink,$zooDownloadPath)
        Write-Host "Zookeeper Setup Downloaded Successfully" -ForegroundColor Green
    }

    if(!(Test-Path -Path $javaInstallerPath)){
        Write-Host "Downloading JAVA installer"
        (New-Object System.Net.WebClient).DownloadFile($javaDownloadLink,$javaInstallerPath)
        Write-Host "JAVA Installer Downloaded Successfully" -ForegroundColor Green
    }

    if(!(Test-Path -Path $nssmDownloadPath)){
        Write-Host "Downloading NSSM Setup from ${nssmDownloadUrl}"
        (New-Object System.Net.WebClient).DownloadFile($nssmDownloadUrl,$nssmDownloadPath)
    }

    if(Test-Path -Path $javaInstallerPath){
        Write-Host "Installing JAVA JDK"
        Execute-Process "${javaInstallerPath}" -Arguments '/s INSTALL_SILENT=1 INSTALLDIR=C:\java\jre STATIC=0 AUTO_UPDATE=0 WEB_JAVA=1 WEB_JAVA_SECURITY_LEVEL=H WEB_ANALYTICS=0 EULA=0 REBOOT=0 NOSTARTMENU=0 SPONSORS=0 /L c:\temp\jre-8u45-windows-x64.log'
        setx /M JAVA_HOME "c:\Program Files\Java\jdk1.8.0_66"

        Write-Host "JAVA Installed Successfully" -ForegroundColor Green
    }

    if(Test-Path -Path $source){
        Write-Host "Extracting Zookeeper Setup"
        try{
            Expand-Archive -Path $source -DestinationPath $destination
        }
        catch{
            $shellApp = New-Object -com shell.application
            $dest = $shellApp.namespace($destination)
            $dest.Copyhere($shellApp.namespace($zooDownloadPath).items())
        }
    }



    mkdir "${destination}\data"
    $zookeeperId | Out-File "${destination}\data\myid"

    Move-Item -Path "${destination}\conf\zoo_sample.cfg" -Destination "${destination}\conf\zoo.cfg"
    (Get-Content "${destination}\conf\zoo.cfg").replace('/tmp/zookeeper', "${destination}\data") | Set-Content "${destination}\conf\zoo.cfg"

    $naList = $nodeAddress.Split(",")
    if($naList.Count -eq $nodeCount){
        $x = 1
        foreach($n in $naList){
            Add-Content "${destination}\conf\zoo.cfg" "server.${x}=${n}:2888:3888"
            $x = $x + 1
        }
    }

    if(Test-Path -Path $nssmDownloadPath){
        try{
            
            Write-Host "Extracting NSSM Installer at ${nssmPath}"
            $shellApp = New-Object -com shell.application
            $dest = $shellApp.NameSpace($nssmPath)
            $dest.CopyHere($shellApp.NameSpace($nssmDownloadPath).items())
            Write-Host "NSSM Extraction Successfull"            

            cd "${nssmPath}\nssm-2.24\win64"
            .\nssm install zookeeper "${destination}\bin\zkServer.cmd"
            
            Write-Host "Service Installation Successfull" -ForegroundColor Green
        }
        catch{
            Write-Error "Service Installation Failed"
        }
    }

    #cleanup
    if(Test-Path -Path $zooDownloadPath){
        Remove-Item -Path $zooDownloadPath
    }
    if(Test-Path -Path $nssmDownloadPath){
        Remove-Item -Path $nssmDownloadPath
    }
}
