Service Solr {
	Name = "Solr";
	DisplayName = "Solr AutoDeployed";
	StartupType = "Automatic";
	State = "Running";
	Ensure = "Present";
	Path = "D:\Project_Personal\SolrCollectionBackup\solr\nssm.exe";
	DependsOn = "[Environment]SetJavaHomePath", "[WindowsProcess]ExtractJava", "[Script]ExtractSolr", "[xRemoteFile]GetSrvany", "[Registry]Solr1", "[Registry]Solr2";
}
Registry Solr1 {
    Key = "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Solr\Parameters";
    ValueName = "AppDirectory";
    ValueData = "D:\Project_Personal\SolrCollectionBackup\solr\solr-6.1.0";
    Ensure = "Present";
}
Registry Solr2 {
    Key = "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Solr\Parameters";
    ValueName = "Application";
    ValueData = "D:\Project_Personal\SolrCollectionBackup\solr\solr-6.1.0\startSolr.bat";
    Ensure = "Present";
}