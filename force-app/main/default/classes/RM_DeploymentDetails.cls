public class RM_DeploymentDetails {
    
    private static final Integer METADATA_API_VERSION = Integer.valueOf(new MetadataService.MetadataPort().endpoint_x.substringAfterLast('/'));
    public static List<SelectOption> MetaDataTypes {get; set;}
    public static String MetaDataType {get; set;}
    public static List<SelectOption> MetaDataItems {get; set;}
    public static String MetaDataFolder {get; set;} 
    public static Map<String,List<String>>  metadata_all=new  Map<String,List<String>>();
    
    @AuraEnabled
    public static MetadataService.AsyncResult retrieveMetadataItem(List<packageJson> packageFile, string parentId)
    {       
        // Construct unmanaged package with list of desired components to retrieve in zip
        Id idofsourceOrg;
        if(parentId != null){
            Deployment_Detail__c sourceId = [Select Id, Source_Org__c,Destination_Org__c from Deployment_Detail__c where Id =: parentId limit 1];
            idofsourceOrg = sourceId.Source_Org__c;
            
        }
        MetadataService.MetadataPort service = createService(idofsourceOrg);
        MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
        retrieveRequest.apiVersion = METADATA_API_VERSION;
        retrieveRequest.packageNames = null;
        retrieveRequest.singlePackage = true;
        retrieveRequest.specificFiles = null;
        retrieveRequest.unpackaged = new MetadataService.Package_x();
        retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
        for(packageJson packageReq : packageFile){
            MetadataService.PackageTypeMembers packageType = new MetadataService.PackageTypeMembers();
            packageType.name = packageReq.key; 
            packageType.members = packageReq.value;
            retrieveRequest.unpackaged.types.add(packageType);
        }
        return service.retrieve(retrieveRequest);
    }
    
    @AuraEnabled
    public static string retrieveSelectedPackage(String packagevalueJson, string parentId){
        List<packageJson> lstOfTypeAndItem = (List<packageJson>)JSON.deserialize(packagevalueJson,List<packageJson>.class);
        system.debug('lstOfTypeAndItem'+lstOfTypeAndItem);
        try{
            MetadataService.AsyncResult asynObj = retrieveMetadataItem(lstOfTypeAndItem, parentId); 
            return asynObj.Id;
        }catch(CalloutException e){
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static string backupretrieveSelectedPackage(String packagevalueJson, string parentId){
        List<packageJson> lstOfTypeAndItem = (List<packageJson>)JSON.deserialize(packagevalueJson,List<packageJson>.class);
        try{
            MetadataService.AsyncResult asynObj = backupretrieveMetadataItem(lstOfTypeAndItem,parentId); 
            return asynObj.Id;
        }catch(CalloutException e){
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static MetadataService.AsyncResult backupretrieveMetadataItem(List<packageJson> packageFile, string parentId)
    {    
        Id idofdestOrg;
        if(parentId != null){
            Deployment_Detail__c sourceId = [Select Id, Source_Org__c,Destination_Org__c from Deployment_Detail__c where Id =: parentId limit 1];
            idofdestOrg = sourceId.Destination_Org__c;
            
        }
        
        // Construct unmanaged package with list of desired components to retrieve in zip
        MetadataService.MetadataPort service = backupcreateService(idofdestOrg);  
        MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
        retrieveRequest.apiVersion = METADATA_API_VERSION;
        retrieveRequest.packageNames = null;
        retrieveRequest.singlePackage = true;
        retrieveRequest.specificFiles = null;
        retrieveRequest.unpackaged = new MetadataService.Package_x();
        retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
        for(packageJson packageReq : packageFile){
            MetadataService.PackageTypeMembers packageType = new MetadataService.PackageTypeMembers();
            packageType.name = packageReq.key; 
            packageType.members = packageReq.value;
            retrieveRequest.unpackaged.types.add(packageType);
        }
        return service.retrieve(retrieveRequest);
    }
    
    @AuraEnabled
    public static List<string> addMap(String metadataType, string parentId){        
        return listMetadataItems(metadataType, parentId);        
    }
    
    @AuraEnabled
    public static List<string> targetaddMap(String  metadataType, string parentId){
        return rollBacklistMetadataItems(metadataType, parentId);        
    }
    
    @AuraEnabled
    public static List<String> listMetadataItems(String MetaData_Type, string parentId)
    {
        
        // List Metadata items for the selected Metadata Type
        MetaDataItems = new List<SelectOption>();   
        System.debug('MetaDataItems@@@@@@ '+MetaDataItems);
        Id idofsourceOrg;
        if(parentId != null){
            Deployment_Detail__c sourceId = [Select Id, Source_Org__c,Destination_Org__c from Deployment_Detail__c where Id =: parentId limit 1];
            idofsourceOrg = sourceId.Source_Org__c;
            
        }
        MetadataService.MetadataPort service = createService(idofsourceOrg);
        
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();    
        
        MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
        
        List<String> fullNames = new List<String>();
        if(MetaDataFolder!=null && MetaDataFolder.length()>0)
            queryLayout.folder = MetaData_Type;
        queryLayout.type_x = MetaData_Type;
        
        // Fetch folder if MetaData_Type is Report or Dashboard (Updated by Yashpal singh)
        if(MetaData_Type=='Report' || MetaData_Type=='Dashboard' || MetaData_Type=='EmailTemplate'){
            List<MetadataService.ListMetadataQuery> queriesFolder = new List<MetadataService.ListMetadataQuery>();
            MetadataService.ListMetadataQuery queryFolder = new MetadataService.ListMetadataQuery();
            queryFolder.type_x = MetaData_Type + 'Folder';
            queriesFolder.add(queryFolder);
            MetadataService.FileProperties[] filePropertiesFolder = service.listMetadata(queriesFolder, METADATA_API_VERSION);
            List<String> folderNames = new List<String>();
            for(MetadataService.FileProperties fileProperty : filePropertiesFolder){
                folderNames.add(fileProperty.fullName);
                
            }
            fullNames.addAll(folderNames);
            for(string fol : folderNames){  
                MetadataService.ListMetadataQuery queryLayout1 = new MetadataService.ListMetadataQuery();
                queryLayout1.type_x = MetaData_Type;
                queryLayout1.folder = fol;
                queries.add(queryLayout1);
            }
        }else
            queries.add(queryLayout);   
        
        MetadataService.FileProperties[] fileProperties = new MetadataService.FileProperties[]{};
            if(queries.size()>3){
                List<MetadataService.ListMetadataQuery> queriesLimit = new List<MetadataService.ListMetadataQuery>();
                for(integer i=0; i<queries.size(); i++){
                    queriesLimit.add(queries[i]);
                    if(queriesLimit.size()==3 && i!=queries.size()-1){
                        fileProperties.addall(service.listMetadata(queriesLimit, METADATA_API_VERSION));
                        queriesLimit.clear();
                    }                                       
                }            
                fileProperties.addall(service.listMetadata(queriesLimit, METADATA_API_VERSION));
            }else
                fileProperties= service.listMetadata(queries, METADATA_API_VERSION);
        
        // Sort
        if(fileProperties!=null)
        {
            for(MetadataService.FileProperties fileProperty : fileProperties)
                fullNames.add(fileProperty.fullName);                   
            fullNames.sort();
            for(String fullName : fullNames)
                MetaDataItems.add(new SelectOption(fullName,EncodingUtil.urlDecode(fullName, 'UTF-8')));
        }
        return fullNames;
    }
    
    @AuraEnabled
    public static List<String> rollBacklistMetadataItems(String MetaData_Type, string parentId)
    {
        Id idofdestOrg;
        if(parentId != null){
            Deployment_Detail__c sourceId = [Select Id, Source_Org__c,Destination_Org__c from Deployment_Detail__c where Id =: parentId limit 1];
            idofdestOrg = sourceId.Destination_Org__c;
        }
        system.debug('MetaData_Type'+MetaData_Type);
        // List Metadata items for the selected Metadata Type
        MetaDataItems = new List<SelectOption>();
        
        MetadataService.MetadataPort service = backupcreateService(idofdestOrg);
        
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        
        MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
        
        List<String> fullNames = new List<String>();
        if(MetaDataFolder!=null && MetaDataFolder.length()>0)
            queryLayout.folder = MetaData_Type;
        queryLayout.type_x = MetaData_Type;
        
        // Fetch folder if MetaData_Type is Report or Dashboard (Updated by Yashpal singh)
        if(MetaData_Type=='Report' || MetaData_Type=='Dashboard' || MetaData_Type=='EmailTemplate'){
            List<MetadataService.ListMetadataQuery> queriesFolder = new List<MetadataService.ListMetadataQuery>();
            MetadataService.ListMetadataQuery queryFolder = new MetadataService.ListMetadataQuery();
            queryFolder.type_x = MetaData_Type + 'Folder';
            queriesFolder.add(queryFolder);
            MetadataService.FileProperties[] filePropertiesFolder = service.listMetadata(queriesFolder, METADATA_API_VERSION);
            if(filePropertiesFolder!=null){
                List<String> folderNames = new List<String>();
                for(MetadataService.FileProperties fileProperty : filePropertiesFolder)
                    folderNames.add(fileProperty.fullName);                              
                fullNames.addAll(folderNames);
                for(string fol : folderNames){  
                    MetadataService.ListMetadataQuery queryLayout1 = new MetadataService.ListMetadataQuery();
                    queryLayout1.type_x = MetaData_Type;
                    queryLayout1.folder = fol;
                    queries.add(queryLayout1);
                } 
            }else
                queries.add(queryLayout);            
        }else                  
            queries.add(queryLayout);  
        
        MetadataService.FileProperties[] fileProperties = new MetadataService.FileProperties[]{};
            if(queries.size()>3){
                List<MetadataService.ListMetadataQuery> queriesLimit = new List<MetadataService.ListMetadataQuery>();
                for(integer i=0; i<queries.size(); i++){
                    queriesLimit.add(queries[i]);
                    if(queriesLimit.size()==3 && i!=queries.size()-1){
                        fileProperties.addall(service.listMetadata(queriesLimit, METADATA_API_VERSION));
                        queriesLimit.clear();
                    }                                       
                }            
                fileProperties.addall(service.listMetadata(queriesLimit, METADATA_API_VERSION));
            }else
                fileProperties= service.listMetadata(queries, METADATA_API_VERSION);
        
        // Sort
        if(fileProperties!=null)
        {
            for(MetadataService.FileProperties fileProperty : fileProperties)
                fullNames.add(fileProperty.fullName);                   
            fullNames.sort();
            for(String fullName : fullNames)
                MetaDataItems.add(new SelectOption(fullName,EncodingUtil.urlDecode(fullName, 'UTF-8')));
        }
        return fullNames;
    }
    
    @AuraEnabled
    public static List<string> selectedadd_Map(String MetaData_Type, string parentId){
        system.debug('MetaData_Type---'+MetaData_Type);
        List<string>  meta_members= new List<String>();
        meta_members=selectedlistMetadataItems(MetaData_Type, parentId);
        return meta_members;
    }
    
    @AuraEnabled
    public static List<String> selectedlistMetadataItems(String MetaData_Type, string parentId)
    {
        Id idofdestOrg;
        if(parentId != null){
            Deployment_Detail__c sourceId = [Select Id, Source_Org__c,Destination_Org__c from Deployment_Detail__c where Id =: parentId limit 1];
            idofdestOrg = sourceId.Destination_Org__c;
        }
        system.debug('idofdestOrg'+idofdestOrg);
        // List Metadata items for the selected Metadata Type
        MetaDataItems = new List<SelectOption>();
        
        MetadataService.MetadataPort service = backupcreateService(idofdestOrg);
        
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        
        MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
        
        List<String> fullNames = new List<String>();
        if(MetaDataFolder!=null && MetaDataFolder.length()>0)
            queryLayout.folder = MetaData_Type;
        queryLayout.type_x = MetaData_Type;
        
        system.debug('MetaData_Type'+MetaData_Type);
        // Fetch folder if MetaData_Type is Report or Dashboard (Updated by Yashpal singh)
        if(MetaData_Type=='Report' || MetaData_Type=='Dashboard' || MetaData_Type=='EmailTemplate'){
            List<MetadataService.ListMetadataQuery> queriesFolder = new List<MetadataService.ListMetadataQuery>();
            MetadataService.ListMetadataQuery queryFolder = new MetadataService.ListMetadataQuery();
            queryFolder.type_x = MetaData_Type + 'Folder';
            queriesFolder.add(queryFolder);
            MetadataService.FileProperties[] filePropertiesFolder = service.listMetadata(queriesFolder, METADATA_API_VERSION);
            if(filePropertiesFolder!=null){
                List<String> folderNames = new List<String>();
                for(MetadataService.FileProperties fileProperty : filePropertiesFolder)
                    folderNames.add(fileProperty.fullName);                              
                fullNames.addAll(folderNames);
                for(string fol : folderNames){
                    MetadataService.ListMetadataQuery queryLayout1 = new MetadataService.ListMetadataQuery();
                    queryLayout1.type_x = MetaData_Type;
                    queryLayout1.folder = fol;
                    queries.add(queryLayout1);
                } 
            }else
                queries.add(queryLayout);
        }else                  
            queries.add(queryLayout);
        system.debug('queries-------'+queries);
        
        
        MetadataService.FileProperties[] fileProperties = new MetadataService.FileProperties[]{};
            if(queries.size()>3){
                List<MetadataService.ListMetadataQuery> queriesLimit = new List<MetadataService.ListMetadataQuery>();
                for(integer i=0; i<queries.size(); i++){
                    queriesLimit.add(queries[i]);
                    if(queriesLimit.size()==3 && i!=queries.size()-1){
                        fileProperties.addall(service.listMetadata(queriesLimit, METADATA_API_VERSION));
                        queriesLimit.clear();
                    }                                       
                }
                fileProperties.addall(service.listMetadata(queriesLimit, METADATA_API_VERSION));
            }else
                fileProperties= service.listMetadata(queries, METADATA_API_VERSION);
        
        // Sort
        if(fileProperties!=null)
        {
            for(MetadataService.FileProperties fileProperty : fileProperties)
                fullNames.add(fileProperty.fullName);                   
            fullNames.sort();
            for(String fullName : fullNames)
                MetaDataItems.add(new SelectOption(fullName,EncodingUtil.urlDecode(fullName, 'UTF-8')));
        }
        return fullNames;
    }
    
    @AuraEnabled
    public static UserStoryWrapper init(string parentId)
    {
        // List available Metadata Types via the 'describeMetadata' API call
        Id idofsourceOrg;
        UserStoryWrapper userStoryWrapper = new UserStoryWrapper();
        if(parentId != null){
            Deployment_Detail__c sourceId = [Select Id, Source_Org__c,Destination_Org__c from Deployment_Detail__c where Id =: parentId limit 1];
            idofsourceOrg = sourceId.Source_Org__c;
            userStoryWrapper.sourceOrg = sourceId.Source_Org__c;
            userStoryWrapper.destinationOrg= sourceId.Destination_Org__c;
        }
        MetadataService.MetadataPort service = createService(idofsourceOrg);
        MetadataService.DescribeMetadataResult describeResult = service.describeMetadata(METADATA_API_VERSION);
        List<String> metadataTypeNames = new List<String>();
        for(MetadataService.DescribeMetadataObject metadataObject : describeResult.metadataObjects)
        {
            metadataTypeNames.add(metadataObject.xmlName);
            // Include child Metadata Types (such as CustomField, ValidationRule etc..)
            if(metadataObject.childXmlNames!=null)
                for(String childXmlName : metadataObject.childXmlNames)
                if(childXmlName!=null)
                metadataTypeNames.add(childXmlName);
        }   
        // Sort Metadata Types
        metadataTypeNames.sort();
        MetaDataTypes = new List<SelectOption>();
        
        for(String metadataTypeName : metadataTypeNames)
            MetaDataTypes.add(new SelectOption(metadataTypeName, metadataTypeName));
        // Default to first Metadata Type returned  
        MetaDataType = MetaDataTypes[0].getValue();             
        
        for(String metadata_TypeName : metadataTypeNames)
        {
            List<String> meta_members =new List<String>();
            metadata_all.put(metadata_TypeName,meta_members);
        }
        userStoryWrapper.metadata = metadata_all;
        return userStoryWrapper;
    }
    
    private static MetadataService.MetadataPort createService(string orgId)
    { 
        SF_Org__c OrgInfo = [select id,AccessToken__c,Name,RefreshToken__c,OrgType__c,instance_url__c   from SF_Org__c where id=:orgId];
        string accessToken = RefrshAccessToken.get(OrgInfo.RefreshToken__c,OrgInfo.OrgType__c);
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = accessToken;
        service.endpoint_x = OrgInfo.instance_url__c+'/services/Soap/m/42.0';
        return service; 
    }
    
    private static MetadataService.MetadataPort backupcreateService(string orgId)
    { 
        SF_Org__c OrgInfo = [select id,AccessToken__c,Name,RefreshToken__c,OrgType__c,instance_url__c   from SF_Org__c where id=:orgId];
        system.debug('OrgInfo'+OrgInfo);
        string accessToken = RefrshAccessToken.get(OrgInfo.RefreshToken__c,OrgInfo.OrgType__c);
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = accessToken;
        service.endpoint_x = OrgInfo.instance_url__c+'/services/Soap/m/42.0';
        return service; 
    }
    
    @AuraEnabled
    public static string backupcheckAsyncRequest(String requestId, string parentId)
    {
        // Check the status of the retrieve request
        String response = '';
        Id idofdestOrg;
        if(parentId != null){
            Deployment_Detail__c sourceId = [Select Id, Source_Org__c,Destination_Org__c from Deployment_Detail__c where Id =: parentId limit 1];
            idofdestOrg = sourceId.Destination_Org__c;
            
        }
        try{
            MetadataService.MetadataPort service = backupcreateService(idofdestOrg);
            MetadataService.RetrieveResult retrieveResult = service.checkRetrieveStatus(requestId, true);
            if(retrieveResult.done)
            {
                if(retrieveResult.status != 'Succeeded')
                {
                    response = 'error';
                }
                else
                {
                    response = retrieveResult.zipFile;
                }
                
            }
            return response;
        }catch(CalloutException e){
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static List<Deployment_Detail__c> findByName(String searchKey){
        String name =  + searchKey + '%';
        system.debug('name'+name);
        return [Select Name, Deployment__c, Status__c, Deployment_Id__c, Deployment_No__c, Deployment_Error__c, Created_Date__c, Destination_Org__c, Source_Org__c, Test_Error__c from Deployment_Detail__c where Name LIKE : name and (Status__c='success' OR Status__c='Validated') and CreatedDate = LAST_N_DAYS:30 order by Created_Date__c Desc];
    }
    
    @AuraEnabled
    public static List<Deployment_Detail__c> findByName1(String searchKeyfailure){
        String name =  + searchKeyfailure + '%';
        system.debug('name'+name);
        return [Select Name, Deployment__c, Deployment_No__c, Deployment_Id__c, Status__c, Created_Date__c, Deployment_Error__c, Destination_Org__c, Source_Org__c, Test_Error__c from Deployment_Detail__c where Name LIKE : name and (Status__c='failure' OR Status__c='Validation Failure') and CreatedDate = LAST_N_DAYS:30 order by Created_Date__c Desc];
    }
    
    @AuraEnabled
    public static List<Deployment_Detail__c> getDeploymentDetailSuccess(){
        
        List<Deployment_Detail__c> deploymentDetailSuccess = [Select Name, Deployment__c, Status__c, Deployment_Id__c, Deployment_No__c, Deployment_Error__c, Created_Date__c, Destination_Org__c, Source_Org__c, Test_Error__c
                                                             from Deployment_Detail__c where (Status__c='success' OR Status__c='Validated') and CreatedDate = LAST_N_DAYS:30   order by Created_Date__c   Desc];
        return deploymentDetailSuccess;
    }
    
    @AuraEnabled
    public static List<Deployment_Detail__c> getDeploymentDetailFailure(){
      
        List<Deployment_Detail__c> deploymentDetailFailure = [Select Name, Deployment__c, Deployment_No__c, Deployment_Id__c, Status__c, Created_Date__c, Deployment_Error__c, Destination_Org__c, Source_Org__c, Test_Error__c
                                                             from Deployment_Detail__c where (Status__c='failure' OR Status__c='Validation Failure') and CreatedDate = LAST_N_DAYS:30 order by Created_Date__c Desc];
        return deploymentDetailFailure;
    }
    
    @AuraEnabled
    public static Deployment_Detail__c getDeploymentDetail(string deploymentid){
        
        
        Deployment_Detail__c  deploymentDetail=[Select Id, Deployment_Error__c, Test_Error__c from Deployment_Detail__c where Id=:deploymentid  ];
        return deploymentDetail;
    }
    @AuraEnabled
    public static string checkAsyncRequest(String requestId, string parentId)
    {
        // Check the status of the retrieve request
        String response = '';
        
        try{
            Id idofsourceOrg;
            if(parentId != null){
             Deployment_Detail__c sourceId = [Select Id, Source_Org__c,Destination_Org__c from Deployment_Detail__c where Id =: parentId limit 1];
            idofsourceOrg = sourceId.Source_Org__c;
                
            }
            MetadataService.MetadataPort service = createService(idofsourceOrg);
            MetadataService.RetrieveResult retrieveResult = service.checkRetrieveStatus(requestId, true);
            if(retrieveResult.done)
            {
                if(retrieveResult.status != 'Succeeded')
                {
                    response = 'error';
                }
                else
                {
                    response = retrieveResult.zipFile;
                }
            }
            return response;
        }catch(CalloutException e){
            return e.getMessage();
        }
    }
    @AuraEnabled
    public static String deploySelectedPackage(String ZipData,String testlevel,String allTestClass, string parentId){
        // Deploy zip file posted back from the page action function    
        Id idofdestinationOrg;
        if(parentId != null){
            Deployment_Detail__c sourceId = [Select Id, Source_Org__c,Destination_Org__c from Deployment_Detail__c where Id =: parentId limit 1];
            idofdestinationOrg = sourceId.Destination_Org__c;
            
        }
        MetadataService.MetadataPort service = createService(idofdestinationOrg);
        MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = false;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        deployOptions.singlePackage = true; 
        deployOptions.testLevel = testlevel;
        // Set the appropriate test level.
        if(testlevel=='RunSpecifiedTests'){
            String[] testclass = allTestClass.split(',');
            deployOptions.runTests=testclass;
            
        }
        MetadataService.AsyncResult result = service.deploy(ZipData, DeployOptions);
        return result.Id;
    }
    @AuraEnabled
    public static String checkdeploymentresult(String asyncResultId, string parentId, string deployrecordId)
    {   
        string response ='';
        // Check the status of the retrieve request
        Id idofdestinationOrg;
        Id idofsourceOrg;
        if(parentId != null){
            Deployment_Detail__c sourceId = [Select Id, Source_Org__c,Destination_Org__c from Deployment_Detail__c where Id =: parentId limit 1];
            idofdestinationOrg = sourceId.Destination_Org__c;
            idofsourceOrg = sourceId.Source_Org__c;
        }
        MetadataService.MetadataPort service = createService(idofdestinationOrg);
        MetadataService.DeployResult deployResult = service.checkDeployStatus(asyncResultId, true);
        if(deployResult!=null){
            
            String RunTestErrorMessage='';
            if(deployResult.details!=null&&deployResult.details.runTestResult!=null){
                
                if(deployResult.details.runTestResult.codeCoverageWarnings!=null)
                {
                    for(MetadataService.CodeCoverageWarning codewarning :deployResult.details.runTestResult.codeCoverageWarnings){
                        RunTestErrorMessage=RunTestErrorMessage+' '+codewarning.message;
                    }
                }
                
            }
            if(deployResult.details!=null&&deployResult.details.retrieveResult!=null){
                
            }
            
            String componentFailureReason='';
            if(deployResult.done)
            {
                // Deployment errors?
                
                if(deployResult.details!=null && deployResult.details.componentFailures!=null){
                    for(MetadataService.DeployMessage deployMessage : deployResult.details.componentFailures){
                        if(deployMessage.problem!=null)
                            response = response + deployMessage.fileName + ' (Line: ' + deployMessage.lineNumber + ': Column:' + deployMessage.columnNumber + ') : ' + deployMessage.problem;
                        componentFailureReason=componentFailureReason +'     '+     deployMessage.problem     ;
                        System.debug('responsedeployMessage @@@@@@@   '+componentFailureReason);
                        
                    }
                }
                if(deployResult.success) 
                {
                    response = 'success';
                }
                else{
                    response='failure';
                }
                
                Deployment_Detail__c reDeploydeploymentresult= new  Deployment_Detail__c(); 
                //deploymentresult.Done__c    ='True';
                reDeploydeploymentresult.Deployment__c = deployrecordId;
                //  deploymentresult.GRM_UserStoryDeploymentDetail__c = packageId;
                //deploymentresult.ErrorMessage__c    =deployResult.errorMessage;
                //deploymentresult.StateDetail__c =deployResult.stateDetail;
                reDeploydeploymentresult.Status__c  =response;
                //deploymentresult.TestCompleted__c   =deployResult.numberTestsCompleted;
                reDeploydeploymentresult.Deployment_Error__c    =componentFailureReason;
                reDeploydeploymentresult.Deployment_Id__c    =deployResult.id;
                //deploymentresult.Test_Error__c =
                //deploymentresult.TotalTest__c   =deployResult.numberTestsTotal;
                //deploymentresult.TotalComponent__c  =deployResult.numberComponentsTotal;
                //deploymentresult.Canceled__c    =deployResult.canceledBy;
                //deploymentresult.CancelledbyName__c =deployResult.canceledByName;
                //deploymentresult.ErrorStatusCode__c     =deployResult.errorStatusCode;
                //deploymentresult.ComponentDeployed__c       =deployResult.numberComponentsDeployed;
                
                insert reDeploydeploymentresult;
            }
        }
        return response;
    }
    
    @AuraEnabled
    public static Map<String,String> destructivepackage(string destructivevalue){
        List<packageJson> desJsonArray = (List<packageJson>)JSON.deserialize(destructivevalue, List<packageJson>.class);
        Map<string,Set<string>> packageFile = new Map<string,Set<string>>();
        for(packageJson pj : desJsonArray){
            packageFile.put(pj.key, new Set<string>(pj.value));
        }
        Map<String,String> destructiveMap = new Map<String,String>();
        destructiveMap.put('package.xml', DestructiveRollback.packageXml());
        destructiveMap.put('destructiveChanges.xml', DestructiveRollback.destructivePackageXml(packageFile));
        return destructiveMap;
    }
    
    @AuraEnabled
    public static string rollbackMethod(string parentId){
        Deployment_Detail__c recordId = [Select Id, Deployment__c from Deployment_Detail__c where Id =: parentId limit 1];
        Deployment_Metadata__c detail=[Select Id from Deployment_Metadata__c where Deployment__c =: recordId.Deployment__c limit 1];
        Attachment rollbackdata = [Select Id, Name, Body from Attachment where ParentId =: detail.Id and Name =:'RollbackData'];
        string paramvalue = (rollbackdata.Body).toString();
        return paramvalue;
    }
    
    @AuraEnabled
    public static string quickDeployMethod(string parentId){
        Deployment_Detail__c recordId = [Select Id, Deployment__c from Deployment_Detail__c where Id =: parentId limit 1];
        Deployment_Metadata__c detail=[Select Id from Deployment_Metadata__c where Deployment__c =: recordId.Deployment__c limit 1];
        Attachment quickdata = [Select Id, Name, Body from Attachment where ParentId =: detail.Id and Name =:'QuickDeployData'];
        string paramvalue = (quickdata.Body).toString();
        return paramvalue;
    }
    
    @AuraEnabled
    public static string deleteMethod(string parentId){
        Deployment_Detail__c recordId = [Select Id, Deployment__c from Deployment_Detail__c where Id =: parentId limit 1];
        Deployment_Metadata__c detail=[Select Id from Deployment_Metadata__c where Deployment__c =: recordId.Deployment__c limit 1];
        Attachment deldata = [Select Id, Name, Body from Attachment where ParentId =: detail.Id and Name =: 'DestructiveData'];
        string paramvalue = (deldata.Body).toString();
        return paramvalue;
    }
    
    @AuraEnabled
    public static String rollbackdeploySelectedPackage(String ZipData, string parentId){
        // Deploy zip file posted back from the page action function    
        Id idofdestinationOrg;
        if(parentId != null){
            Deployment_Detail__c sourceId = [Select Id, Source_Org__c,Destination_Org__c from Deployment_Detail__c where Id =: parentId limit 1];
            idofdestinationOrg = sourceId.Destination_Org__c;
            
        }
        MetadataService.MetadataPort service = createService(idofdestinationOrg);
        MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = false;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        deployOptions.testLevel = 'NoTestRun';
        deployOptions.singlePackage = true; 
        // Set the appropriate test level.
        MetadataService.AsyncResult result = service.deploy(ZipData, DeployOptions);
        return result.Id;
    }
    @AuraEnabled
    public static String rollbackcheckdeploymentresult(String asyncResultId, string parentId)
    {   
        string response ='';
        // Check the status of the retrieve request
        Id idofdestinationOrg;
        Id idofsourceOrg;
        if(parentId != null){
            Deployment_Detail__c sourceId = [Select Id, Source_Org__c,Destination_Org__c from Deployment_Detail__c where Id =: parentId limit 1];
            idofdestinationOrg = sourceId.Destination_Org__c;
            idofsourceOrg = sourceId.Source_Org__c;
        }
        MetadataService.MetadataPort service = createService(idofdestinationOrg);
        MetadataService.DeployResult deployResult = service.checkDeployStatus(asyncResultId, true);
        if(deployResult!=null){
            
            if(deployResult.details!=null&&deployResult.details.retrieveResult!=null){
                
            }
            
            String componentFailureReason='';
            if(deployResult.done)
            {
                // Deployment errors?
                
                if(deployResult.details!=null && deployResult.details.componentFailures!=null){
                    for(MetadataService.DeployMessage deployMessage : deployResult.details.componentFailures){
                        if(deployMessage.problem!=null)
                            response = response + deployMessage.fileName + ' (Line: ' + deployMessage.lineNumber + ': Column:' + deployMessage.columnNumber + ') : ' + deployMessage.problem;
                        componentFailureReason=componentFailureReason +'     '+     deployMessage.problem     ;
                        
                    }
                }
                if(deployResult.success) 
                {
                    response = 'success';
                }
                else{
                    response='failure';
                }
            }
        }
        return response;
    }
    
     @AuraEnabled
    public static String quickdeploySelectedPackage(String ZipData, string parentId){
        system.debug('quickdeploySelectedPackage called @@@@@@@@@@@@@@@@@@@@@@@------------');
        // Deploy zip file posted back from the page action function    
        Id idofdestinationOrg;
        if(parentId != null){
            Deployment_Detail__c sourceId = [Select Id, Source_Org__c,Destination_Org__c from Deployment_Detail__c where Id =: parentId limit 1];
            idofdestinationOrg = sourceId.Destination_Org__c;
            
        }
        MetadataService.MetadataPort service = createService(idofdestinationOrg);
        MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = false;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        deployOptions.testLevel = 'NoTestRun';
        deployOptions.singlePackage = true; 
        // Set the appropriate test level.
        MetadataService.AsyncResult result = service.deploy(ZipData, DeployOptions);
        system.debug('result@@@@'+result);
        return result.Id;
    }
    @AuraEnabled
    public static String quickcheckdeploymentresult(String asyncResultId, string parentId, string deployrecordId)
    {   
        string response ='';
        // Check the status of the retrieve request
        Id idofdestinationOrg;
        Id idofsourceOrg;
        if(parentId != null){
            Deployment_Detail__c sourceId = [Select Id, Source_Org__c,Destination_Org__c from Deployment_Detail__c where Id =: parentId limit 1];
            idofdestinationOrg = sourceId.Destination_Org__c;
            idofsourceOrg = sourceId.Source_Org__c;
        }
        MetadataService.MetadataPort service = createService(idofdestinationOrg);
        MetadataService.DeployResult deployResult = service.checkDeployStatus(asyncResultId, true);
        if(deployResult!=null){
            
            if(deployResult.details!=null&&deployResult.details.retrieveResult!=null){
                
            }
            
            String componentFailureReason='';
            if(deployResult.done)
            {
                // Deployment errors?
                
                if(deployResult.details!=null && deployResult.details.componentFailures!=null){
                    for(MetadataService.DeployMessage deployMessage : deployResult.details.componentFailures){
                        if(deployMessage.problem!=null)
                            response = response + deployMessage.fileName + ' (Line: ' + deployMessage.lineNumber + ': Column:' + deployMessage.columnNumber + ') : ' + deployMessage.problem;
                        componentFailureReason=componentFailureReason +'     '+     deployMessage.problem     ;
                        
                    }
                }
                if(deployResult.success) 
                {
                    response = 'success';
                }
                else{
                    response='failure';
                }
                Deployment_Detail__c reDeploydeploymentresult= new  Deployment_Detail__c(); 
                //deploymentresult.Done__c    ='True';
                reDeploydeploymentresult.Deployment__c = deployrecordId;
                //  deploymentresult.GRM_UserStoryDeploymentDetail__c = packageId;
                //deploymentresult.ErrorMessage__c    =deployResult.errorMessage;
                //deploymentresult.StateDetail__c =deployResult.stateDetail;
                reDeploydeploymentresult.Status__c  =response;
                //deploymentresult.TestCompleted__c   =deployResult.numberTestsCompleted;
                reDeploydeploymentresult.Deployment_Error__c    =componentFailureReason;
                reDeploydeploymentresult.Deployment_Id__c    =deployResult.id;
                //deploymentresult.Test_Error__c =
                //deploymentresult.TotalTest__c   =deployResult.numberTestsTotal;
                //deploymentresult.TotalComponent__c  =deployResult.numberComponentsTotal;
                //deploymentresult.Canceled__c    =deployResult.canceledBy;
                //deploymentresult.CancelledbyName__c =deployResult.canceledByName;
                //deploymentresult.ErrorStatusCode__c     =deployResult.errorStatusCode;
                //deploymentresult.ComponentDeployed__c       =deployResult.numberComponentsDeployed;
                
                insert reDeploydeploymentresult;
            }
        }
        return response;
    }
    
    @AuraEnabled
    public static String deletedeploySelectedPackage(String delData, string parentId){
        // Deploy zip file posted back from the page action function    
        Id idofdestinationOrg;
        if(parentId != null){
            Deployment_Detail__c sourceId = [Select Id, Source_Org__c,Destination_Org__c from Deployment_Detail__c where Id =: parentId limit 1];
            idofdestinationOrg = sourceId.Destination_Org__c;
            
        }
        MetadataService.MetadataPort service = createService(idofdestinationOrg);
        MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = false;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        deployOptions.testLevel = 'NoTestRun';
        deployOptions.singlePackage = true; 
        // Set the appropriate test level.
        MetadataService.AsyncResult result = service.deploy(delData, DeployOptions);
        return result.Id;
    }
    @AuraEnabled
    public static String deletecheckdeploymentresult(String asyncResultId, string parentId)
    {   
        string response ='';
        // Check the status of the retrieve request
        Id idofdestinationOrg;
        Id idofsourceOrg;
        if(parentId != null){
            Deployment_Detail__c sourceId = [Select Id, Source_Org__c,Destination_Org__c from Deployment_Detail__c where Id =: parentId limit 1];
            idofdestinationOrg = sourceId.Destination_Org__c;
            idofsourceOrg = sourceId.Source_Org__c;
        }
        MetadataService.MetadataPort service = createService(idofdestinationOrg);
        MetadataService.DeployResult deployResult = service.checkDeployStatus(asyncResultId, true);
        if(deployResult!=null){
            
            
            if(deployResult.done)
            {
                // Deployment errors?
                
                if(deployResult.details!=null && deployResult.details.componentFailures!=null){
                    for(MetadataService.DeployMessage deployMessage : deployResult.details.componentFailures){
                        if(deployMessage.problem!=null)
                            response = response + deployMessage.fileName + ' (Line: ' + deployMessage.lineNumber + ': Column:' + deployMessage.columnNumber + ') : ' + deployMessage.problem;
                        
                    }
                }
                if(deployResult.success) 
                {
                    response = 'success';
                }
                else{
                    response='failure';
                }
            }
        }
        return response;
    }
    
    @AuraEnabled
    public static string getSeletedMetadataMemberMap(string parentId){
        Deployment_Detail__c recordId = [Select Id, Deployment__c from Deployment_Detail__c where Id =: parentId limit 1];
        Deployment_Metadata__c detail=[Select DeploymentData__c from Deployment_Metadata__c where Id =: recordId.Deployment__c limit 1];
        String obj =detail.DeploymentData__c;
        return obj;
    }
    
    @AuraEnabled
    public static string saveRollbackData(String rollbackdata, string quickDeploy, String destructdata, boolean isBackUp, string datatodel, string datatoroll, string parentId,string selectedMetadataMap, string bollbackup, string testLevel, string testClass){
        
        Id idofdestinationOrg;
        Id idofsourceOrg;
        if(parentId != null){
            Deployment_Detail__c sourceId = [Select Id, Source_Org__c,Destination_Org__c from Deployment_Detail__c where Id =: parentId limit 1];
            idofsourceOrg = sourceId.Source_Org__c;
            idofdestinationOrg = sourceId.Destination_Org__c;
        }
        SF_Org__c source  = [select id ,org_name__c from SF_Org__c where id =: idofsourceOrg];
        SF_Org__c destination  = [select id ,org_name__c from SF_Org__c where id =: idofdestinationOrg];
        
        Deployment__c deployment= new  Deployment__c(); 
        deployment.Is_Backup_Taken__c = isBackUp;
        deployment.Test_Level__c = testLevel;
        deployment.Test_Classes__c = testClass;
        deployment.Source_Org__c = source.id;
        deployment.Destination_Org__c = destination.id;
        insert deployment;
        
        
       Deployment_Metadata__c insertRedeployData=new Deployment_Metadata__c();
        insertRedeployData.DeploymentData__c = selectedMetadataMap+'';
        insertRedeployData.Deployment__c = deployment.id;
        if(bollbackup == 'true'){
            insertRedeployData.DataToDel__c = datatodel+'';
            insertRedeployData.DataToRollBack__c = datatoroll+'';
            system.debug('hello');
        }
        insert insertRedeployData;
        
        if(rollbackdata != null || destructdata != null){
            if(bollbackup == 'true'){
                Blob tempBlob = Blob.valueOf(rollbackdata);
                Blob delBlob = Blob.valueOf(destructdata);
                Blob dataBlob = Blob.valueOf(quickDeploy);
                
                List<Attachment> attchmenttosave = new List<Attachment>();
                
                Attachment dataattach = new Attachment();
                dataattach.Name = 'QuickDeployData';
                dataattach.ParentId = insertRedeployData.Id;
                dataattach.Body = dataBlob;
                
                Attachment fileattach =  new Attachment();
                fileattach.Name = 'RollbackData';
                fileattach.ParentId = insertRedeployData.id;
                fileattach.Body = tempBlob;
                
                Attachment destattach =  new Attachment();
                destattach.Name = 'DestructiveData';
                destattach.ParentId = insertRedeployData.id;
                destattach.Body = delBlob;
                
                attchmenttosave.add(dataattach);
                attchmenttosave.add(fileattach);
                attchmenttosave.add(destattach);
                insert attchmenttosave;
                
            }
        }
        return deployment.Id;
    }
    
    public class packageJson{
        public string key;
        public List<string> value;
    }
    
    @AuraEnabled
    public static String nameDestinationAdmin(String sourceOrg, String destinationOrg)
    {
        Http h1 = new Http();
        HttpRequest request = new HttpRequest();
        String userName;
        String targetProfile = 'System+Administrator';
        SF_Org__c orgInfo = DBUtils.getOrg(destinationOrg);
        string accessToken = RefrshAccessToken.get(orgInfo.RefreshToken__c,orgInfo.OrgType__c);
        string endPt = orgInfo.instance_url__c+'/services/data/v42.0/query?q=SELECT+Username+FROM+User+where+profile.name='+'\'' + String.escapeSingleQuotes(targetProfile) + '\'+&IsActive=true';
        system.debug('endpoint url is : '+ endPt);
        request.setHeader('Authorization','Bearer '+ accessToken);
        request.setMethod('GET');
        request.setEndpoint(endPt);
        HttpResponse response; 
        try{
            response = h1.send(request);
        }catch(Exception e){
            system.debug('Exception is : '+e.getMessage());
        }       
        String strResponse = response.getBody().unescapeCsv().remove('\\');
        Map<String,Object> mp_StrObj = (Map<string,Object>)(Object)Json.deserializeUntyped(strResponse);
        
        List<Object> recObj = (List<Object>)mp_StrObj.get('records');
        for(Object obj : recObj){
            Map<String,Object> mpObj = (Map<string,Object>)obj;
            userName =String.valueOf(mpObj.get('Username'));
        }
        return userName;
    }    
}