public class RM_MetadataRetrieveController 
{    
    public static Map<String,List<String>>  metadataAll = new  Map<String,List<String>>();
    private static final Integer METADATA_API_VERSION = Integer.valueOf(new MetadataService.MetadataPort().endpoint_x.substringAfterLast('/'));
    public static string selectedValue {get;set;}
    public static string selectedValueDestination {get;set;}
    public static string selectedOrg;
    
    public static List<SelectOption> metaDataTypes {get; set;}
    public static String metaDataType {get; set;}    
    public static List<SelectOption> metaDataItems {get; set;}
    public static String metaDataFolder {get; set;} 
    public static String metaDataItem {get; set;}  
    public  static String metadataFileName {get; set;}
    public static String metadataFileData {get; set;}
    public static MetadataService.AsyncResult asyncResult {get; private set;}
    public static String metaDataRetrieveZip { get; private set; }  
    public static string zipvalue{get; private set;}
    public static List<MetadataFile> metadataFiles { get; set; }  
    public static String zipAttachmentId {get; private set;}
    public MetadataService.AsyncResult result{get; private set;}
        
    @AuraEnabled
    public  static string getSourceOrg(String sourceOrg){
        selectedValue = sourceOrg;
        return selectedValue;
    }
    
    @AuraEnabled
    public static string retrieveSelectedPackage(String packagevalueJson, String sourceOrg, String destinationOrg){
        List<packageJson> lstOfTypeAndItem = (List<packageJson>)JSON.deserialize(packagevalueJson,List<packageJson>.class);
        try{
            MetadataService.AsyncResult asynObj = retrieveMetadataItem(lstOfTypeAndItem, sourceOrg, destinationOrg); 
            return asynObj.Id;
        }catch(CalloutException e){
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static string backupretrieveSelectedPackage(String packagevalueJson, String sourceOrg, String destinationOrg){
        List<packageJson> lstOfTypeAndItem = (List<packageJson>)JSON.deserialize(packagevalueJson,List<packageJson>.class);
        try{
            MetadataService.AsyncResult asynObj = backupretrieveMetadataItem(lstOfTypeAndItem, sourceOrg, destinationOrg); 
            return asynObj.Id;
        }catch(CalloutException e){
            return e.getMessage();
        }
    }
    /*
    public SelectOption[] getselectValues() {     
        SelectOption[] options = new SelectOption[]{};
            for(SF_Org__c oneRelationship : [Select  Id, Name FROM SF_Org__c where Authorised__c =:true]) {
                options.add(new SelectOption(
                    String.valueOf(oneRelationship.Id),oneRelationship.Name));                 
            } 
        return options;           
    }*/
    
    @AuraEnabled
    public static List<string> addMap(String  metadataType, String sourceOrg, String destinationOrg){
        List<string>  metaMembers= new List<String>();
        metaMembers = listMetadataItems(metadataType, sourceOrg, destinationOrg);
        if(metaMembers.contains('unfiled$public')){
            metaMembers.remove(metaMembers.indexOf('unfiled$public'));
        }
        return metaMembers;
    }
    
    @AuraEnabled
    public static List<string> targetaddMap(String metadataType, String sourceOrg, String destinationOrg){        
        return rollBacklistMetadataItems(metadataType, sourceOrg, destinationOrg);
    }
    
    @AuraEnabled
    public static Map<string,List<string>> init(string sourceOrg, string destinationOrg)
    {
        // List available Metadata Types via the 'describeMetadata' API call
        MetadataService.MetadataPort service = createService(sourceOrg, destinationOrg);    
        MetadataService.DescribeMetadataResult describeResult = service.describeMetadata(METADATA_API_VERSION);
        List<String> metadataTypeNames = new List<String>();
        for(MetadataService.DescribeMetadataObject metadataObject : describeResult.metadataObjects)
        {
            System.debug('metadataObject.xmlName: '+JSON.serialize(metadataObject));
            metadataTypeNames.add(metadataObject.xmlName);
            // Include child Metadata Types (such as CustomField, ValidationRule etc..)
            if(metadataObject.childXmlNames!=null){
                for(String childXmlName : metadataObject.childXmlNames){
                    if(childXmlName!=null){
                        metadataTypeNames.add(childXmlName);
                    }
                    System.debug('metadataObject.childXmlNames: '+metadataObject.childXmlNames);
                }
            }
        }  
        System.debug('metadataTypeNames@@ ' +metadataTypeNames);        
        // Sort Metadata Types
        metadataTypeNames.sort();
        metaDataTypes = new List<SelectOption>();
        
        for(String metadataTypeName : metadataTypeNames){
            metaDataTypes.add(new SelectOption(metadataTypeName, metadataTypeName));
        }
        // Default to first Metadata Type returned  
        metaDataType = metaDataTypes[0].getValue();        
        
        for(String metadataTypeName : metadataTypeNames)
        {
            List<String> metaMembers = new List<String>();
            metadataAll.put(metadataTypeName,metaMembers);            
        }        
        return metadataAll;        
    }
    
    @AuraEnabled
    public static List<SF_Org__c> getOrgList() {
        return DBUtils.getAuthorizeOrg();
    }

    @AuraEnabled
    public static List<String> listMetadataItems(String metaDataType, String sourceOrg, String destinationOrg)
    {        
        // List Metadata items for the selected Metadata Type
        metaDataItems = new List<SelectOption>();
        
        MetadataService.MetadataPort service = createService(sourceOrg, destinationOrg);
        
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        
        MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
        
        List<String> fullNames = new List<String>();
        if(MetaDataFolder!=null && MetaDataFolder.length()>0){
            queryLayout.folder = metaDataType;
        }
        queryLayout.type_x = metaDataType;
        
        // Fetch folder if metaDataType is Report or Dashboard (Updated by Yashpal singh)
        if(metaDataType=='Report' || metaDataType=='Dashboard' || metaDataType=='EmailTemplate'){
            List<MetadataService.ListMetadataQuery> queriesFolder = new List<MetadataService.ListMetadataQuery>();
            MetadataService.ListMetadataQuery queryFolder = new MetadataService.ListMetadataQuery();
            queryFolder.type_x = metaDataType == 'EmailTemplate'?'EmailFolder': metaDataType + 'Folder';            
            queriesFolder.add(queryFolder);
            MetadataService.FileProperties[] filePropertiesFolder = service.listMetadata(queriesFolder, METADATA_API_VERSION);
            if(filePropertiesFolder!=null){
                List<String> folderNames = new List<String>();
                for(MetadataService.FileProperties fileProperty : filePropertiesFolder){
                    folderNames.add(fileProperty.fullName);
                } 
                fullNames.addAll(folderNames);
                for(string fol : folderNames){  
                    MetadataService.ListMetadataQuery queryLayout1 = new MetadataService.ListMetadataQuery();
                    queryLayout1.type_x = metaDataType;
                    queryLayout1.folder = fol;
                    queries.add(queryLayout1);
                } 
            }else{
                queries.add(queryLayout);
            }                
        }
        else{
            queries.add(queryLayout);  
        }

        MetadataService.FileProperties[] fileProperties = new MetadataService.FileProperties[]{};
            try{         
                if(queries.size()>3){
                    List<MetadataService.ListMetadataQuery> queriesLimit = new List<MetadataService.ListMetadataQuery>();
                    for(integer i=1; i<queries.size(); i++){ 
                        queriesLimit.add(queries[i]);
                        if(queriesLimit.size()==3 && i!=queries.size()){             
                            fileProperties.addall(service.listMetadata(queriesLimit, METADATA_API_VERSION));
                            queriesLimit.clear();
                        }                                       
                    }            
                    fileProperties.addall(service.listMetadata(queriesLimit, METADATA_API_VERSION));
                }
                else{
                    fileProperties= service.listMetadata(queries, METADATA_API_VERSION);   
                }                    
            }
            catch(Exception e){
                system.debug('Exxxxxxxxxception is :: '+e);
            }            
        
        // Sort
        if(fileProperties!=null)
        {
            for(MetadataService.FileProperties fileProperty : fileProperties){
                fullNames.add(fileProperty.fullName);
                System.debug(fileProperty);
                System.debug('fileProperty: '+JSON.serialize(fileProperty));
            }
                                   
            fullNames.sort();
            for(String fullName : fullNames){
                metaDataItems.add(new SelectOption(fullName,EncodingUtil.urlDecode(fullName, 'UTF-8')));
            }                
        }
        return fullNames;
    }
    
    @AuraEnabled
    public static List<String> rollBacklistMetadataItems(String metaDataType, String sourceOrg, String destinationOrg)
    {
        
        // List Metadata items for the selected Metadata Type
        MetaDataItems = new List<SelectOption>();
        
        MetadataService.MetadataPort service = backupcreateService(sourceOrg, destinationOrg);
        
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        
        MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
        
        List<String> fullNames = new List<String>();
        if(MetaDataFolder!=null && MetaDataFolder.length()>0){
            queryLayout.folder = metaDataType;
        }            
        queryLayout.type_x = metaDataType;
        
        // Fetch folder if metaDataType is Report or Dashboard (Updated by Yashpal singh)
        if(metaDataType=='Report' || metaDataType=='Dashboard' || metaDataType=='EmailTemplate'){
            List<MetadataService.ListMetadataQuery> queriesFolder = new List<MetadataService.ListMetadataQuery>();
            MetadataService.ListMetadataQuery queryFolder = new MetadataService.ListMetadataQuery();
            queryFolder.type_x = metaDataType + 'Folder';
            queriesFolder.add(queryFolder);
            MetadataService.FileProperties[] filePropertiesFolder = service.listMetadata(queriesFolder, METADATA_API_VERSION);
            if(filePropertiesFolder!=null){
                List<String> folderNames = new List<String>();
                for(MetadataService.FileProperties fileProperty : filePropertiesFolder){
                    folderNames.add(fileProperty.fullName);
                }
                fullNames.addAll(folderNames);
                for(string fol : folderNames){  
                    MetadataService.ListMetadataQuery queryLayout1 = new MetadataService.ListMetadataQuery();
                    queryLayout1.type_x = metaDataType;
                    queryLayout1.folder = fol;
                    queries.add(queryLayout1);
                } 
            }
            else{
                queries.add(queryLayout);
            }                
        }
        else{
            queries.add(queryLayout);  
        }

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
        }
        else{
            fileProperties= service.listMetadata(queries, METADATA_API_VERSION);
        }
        
        // Sort
        if(fileProperties!=null)
        {
            for(MetadataService.FileProperties fileProperty : fileProperties){
                fullNames.add(fileProperty.fullName);
            }
            fullNames.sort();
            for(String fullName : fullNames){
                metaDataItems.add(new SelectOption(fullName,EncodingUtil.urlDecode(fullName, 'UTF-8')));
            }
        }
        return fullNames;
    }
    
    @AuraEnabled
    public static MetadataService.AsyncResult retrieveMetadataItem(List<packageJson> packageFile, String sourceOrg, String destinationOrg)
    {    
        // Construct unmanaged package with list of desired components to retrieve in zip
        MetadataService.MetadataPort service = createService(sourceOrg, destinationOrg);  
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
    public static MetadataService.AsyncResult backupretrieveMetadataItem(List<packageJson> packageFile, String sourceOrg, String destinationOrg)
    {    
        // Construct unmanaged package with list of desired components to retrieve in zip
        MetadataService.MetadataPort service = backupcreateService(sourceOrg, destinationOrg);  
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
    public static string deploySelectedPackage(Map<String,String> data){
        try{            
            MetadataService.AsyncResult result = MetadataDeployController.deployZip(data.get('zipFile'),data.get('testlevel'),data.get('allTestClass'),data.get('sourceOrg'),data.get('destinationOrg'));          
            return result.Id;
        }catch(CalloutException e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, String> validatedeploymentresult(String resId, string packageId, string sourceOrg, string destinationOrg, string parentId){
        try{
            Map<String, String> response = MetadataDeployController.checkValidationRequest(resId, packageId, sourceOrg, destinationOrg, parentId);
            return response;
        }catch(CalloutException e){
            Map<String, String> err = new Map<String, String>();
            err.put('err',e.getMessage());
            return err;
        }
    }
    
    @AuraEnabled
    public static string validateSelectedPackage(Map<String,String> data){
        try{            
            MetadataService.AsyncResult result = MetadataDeployController.validateZip(data.get('zipFile'), data.get('Testlevel'), data.get('alltestclass'), data.get('sourceOrg'), data.get('destinationOrg'));          
            return result.Id;
        }catch(CalloutException e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string checkdeploymentresult(String resId, string packageId, string sourceOrg, string destinationOrg, string parentId){
        try{
            String response = MetadataDeployController.checkAsyncRequest(resId, packageId, sourceOrg, destinationOrg, parentId);
            return response;
        }catch(CalloutException e){
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static string checkAsyncRequest(String requestId, String sourceOrg, String destinationOrg)
    {
        // Check the status of the retrieve request
        String response = '';
        try{
            MetadataService.MetadataPort service = createService(sourceOrg, destinationOrg);
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
    public static string backupcheckAsyncRequest(String requestId, String sourceOrg, String destinationOrg)
    {
        // Check the status of the retrieve request
        String response = '';
        try{
            MetadataService.MetadataPort service = backupcreateService(sourceOrg, destinationOrg);
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
    public static string getSeletedMetadataMemberMap(){
        GRM_UserStoryDeploymentDetail__c detail=[Select GRM_DeploymentDetail__c from GRM_UserStoryDeploymentDetail__c limit 1 ];
        String obj =detail.GRM_DeploymentDetail__c;
        return obj;
    }
    
    public PageReference receiveMetadataZipFile()
    {
        // In this example the retrieved metadata is stored in viewstate in production cases you would probably use a custom object / attachment
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Expanding ' + MetaDataFileName + '...'));
        MetadataFile metaDataFile = new MetadataFile();
        metaDataFile.fullName = MetaDataFileName;
        metaDataFile.content = MetaDataFileData;
        MetadataFiles.add(metaDataFile);
        return null;
    }
    
    public PageReference receiveComplete()
    {
        // Completed, cleared Base64 encoded zip data from viewstate
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Metadata retrieve completed'));
        //creating zip file.
        Zippex zip = new Zippex();
        string fileName = 'MetaFile.zip';
        //iterating through MetadataFiles for path and file to be zipped.
        for(MetadataFile metaDataRaw : MetadataFiles){
            zip.addFile(metaDataRaw.fullName, Blob.valueOf(metaDataRaw.content), null);
        }
        Blob zipData = zip.getZipArchive();
        //attachment-id to download zip file
        zipAttachmentId = saveToDocument(zipData,fileName);
        MetaDataRetrieveZip = null;    
        return null;
    }
    
    private static MetadataService.MetadataPort createService(String sourceOrg, String destinationOrg)
    {         
        SF_Org__c orgInfo = DBUtils.getOrg(sourceOrg);
        String accessToken = RefrshAccessToken.get(orgInfo.RefreshToken__c,orgInfo.OrgType__c);
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = accessToken;
        service.endpoint_x = orgInfo.instance_url__c+'/services/Soap/m/42.0';
        return service;    
    }
    
    private static MetadataService.MetadataPort backupcreateService(String sourceOrg, String destinationOrg)
    {         
        //String RecordId = selectedValueDestination;
        SF_Org__c orgInfo = DBUtils.getOrg(destinationOrg);
        string accessToken = RefrshAccessToken.get(orgInfo.RefreshToken__c,orgInfo.OrgType__c);
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = accessToken;
        service.endpoint_x = orgInfo.instance_url__c+'/services/Soap/m/42.0';
        return service;    
    }
    
    @AuraEnabled
    public static string saveSeletedMetadataMemberMap(Map<String,String> data)
    {        
        // create deployment detail record
        Deployment_Detail__c deploymentDetail = new Deployment_Detail__c();
        deploymentDetail.Name = data.get('deploymentName');
        deploymentDetail.Description__c = data.get('deploymentdescripton');
        deploymentDetail.Status__c = 'Draft';

        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, new Deployment_Detail__c[]{deploymentDetail});
        insert securityDecision.getRecords();
        return securityDecision.getRecords()[0].Id;
    }
    
    public static PageReference downloadMetadataZipFile()
    {
        // In this example the retrieved metadata is stored in viewstate in production cases you would probably use a custom object / attachment
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Expanding zip ' + MetaDataFileName + '...'));
        MetadataFile metaDataFile = new MetadataFile();
        metaDataFile.fullName = MetaDataFileName;
        metaDataFile.content = MetaDataFileData;
        MetadataFiles.add(metaDataFile);
        PageReference downloadPage;
        if(zipAttachmentId != 'error' || zipAttachmentId != null){
            downloadPage = new PageReference('/servlet/servlet.FileDownload?file='+zipAttachmentId);
            downloadPage.setRedirect(true);
            downloadPage.setRedirectCode(301);            
        }
        return downloadPage;
    }
    
    //method for inserting zip file to attachment.
    public static String saveToDocument( Blob zipData, String fileName ){
        String docId;
        try{            
            List<Document> docList = DBUtils.getDocs(fileName);
            Document doc = new Document();
            if(!docList.isEmpty()) {
                doc.Name = fileName;
                doc.FolderId = UserInfo.getUserId();
                doc.Body = zipData;
                SObjectAccessDecision securityDecision = Security.stripInaccessible
                                                  (AccessType.CREATABLE, new Document[]{doc});
                Insert securityDecision.getRecords();
                docId = securityDecision.getRecords()[0].Id;
            } 
            else {
                doc = docList.get(0);
                doc.Body = zipData;
                SObjectAccessDecision securityDecision = Security.stripInaccessible
                                                  (AccessType.UPDATABLE, new Document[]{doc});
                Update securityDecision.getRecords();
                docId = securityDecision.getRecords()[0].Id;           
            }
        } 
        catch ( Exception ex ) {
            docId = 'error' ;
        }
        return docId;
    }
    
    @AuraEnabled
    public static string  getInsertCustomSetdata(string selectedOrg) {
        string returnMsg ='';
        //fetches or creates a Custom Setting at the organization level 
        try{
            // insert select source org value in custom setting for tem basis 
            OrgTempData__c setting = OrgTempData__c.getOrgDefaults();
            setting.SourceOrg__c = selectedOrg;
            upsert setting;
            returnMsg ='Success';
        }
        catch(exception e){
            returnMsg ='Error';
        }
        return returnMsg;
    }

    @AuraEnabled
    public  static void  getInsertCustomSetdataDestination(String Dest_Org) {
        string returnMsg ='';
        //fetches or creates a Custom Setting at the organization level 
        try{
            // insert select source org value in custom setting for tem basis 
            OrgTempData__c setting = OrgTempData__c.getOrgDefaults();
            setting.DestinationOrg__c = Dest_Org;
            upsert setting;
            returnMsg ='Success';
        }
        catch(exception e){
            returnMsg ='Error';
        }
        //   return returnMsg;
    }
    
    @AuraEnabled
    public static String downloadZipFile(){
        system.debug('downloading....');
        return null;
    }
    public class MetadataFile extends MetadataService.MetadataWithContent
    {
        public String getFullname()
        {
            return fullName;
        }
        
        public String getContent()
        {
            return content;
        }
    }
    public class packageJson{
        public string key;
        public List<string> value;
    }
    
    // Added by Yashpal Singh, 12-01-2020
    // Description: To get Destination org Admin user name
    @AuraEnabled
    public static String nameDestinationAdmin(String sourceOrg, String destinationOrg)
    {
        system.debug('in naameDestinationAdmin method');
        system.debug('distinationOrg is :: '+destinationOrg);
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
    
    // Added by Yashpal Singh, 12-16-2020
    // Description: Insert data in Deployment, DeploymentDetails and DeploymentMetaData objects when deployment successs or failure.    
    @AuraEnabled
    public static string insertInDeploymentObjects(string selectedMetadataMap, string quickDeploy, string testLevel, string testClass, boolean isBackUp, string sourceOrg, string destinationOrg,String rollbackdata, String destructdata, string datatodel, string datatoroll){
        // create deployment  record
        String attId;
        SF_Org__c source  = DBUtils.getOrg(sourceOrg);
        SF_Org__c destination  = DBUtils.getOrg(destinationOrg);
        
        Deployment__c deployment= new  Deployment__c(); 
        deployment.Is_Backup_Taken__c = isBackUp;
        deployment.Test_Level__c = testLevel;
        deployment.Test_Classes__c = testClass;
        deployment.Source_Org__c = source.id;
        deployment.Destination_Org__c = destination.id;
        SObjectAccessDecision securityDecision1 = Security.stripInaccessible(AccessType.CREATABLE, new Deployment__c[]{deployment});
        Insert securityDecision1.getRecords();        
        
        Deployment_Metadata__c detail=new Deployment_Metadata__c();
        detail.DeploymentData__c = selectedMetadataMap+'';
        detail.Deployment__c = securityDecision1.getRecords()[0].id;
        detail.DataToDel__c = datatodel+'';
        detail.DataToRollBack__c = datatoroll+'';
        SObjectAccessDecision securityDecision2 = Security.stripInaccessible(AccessType.CREATABLE, new Deployment_Metadata__c[]{detail});
        Insert securityDecision2.getRecords();
        
        if(rollbackdata != null || destructdata != null){
            Blob tempBlob = Blob.valueOf(rollbackdata);
            Blob delBlob = Blob.valueOf(destructdata);
            Blob dataBlob = Blob.valueOf(quickDeploy);
            
            List<Attachment> attchmenttosave = new List<Attachment>();
            
            Attachment dataattach = new Attachment();
            dataattach.Name = 'QuickDeployData';
            dataattach.ParentId = detail.Id;
            dataattach.Body = dataBlob;
            
            Attachment fileattach =  new Attachment();
            fileattach.Name = 'RollbackData';
            fileattach.ParentId = securityDecision2.getRecords()[0].Id;
            fileattach.Body = tempBlob;
            
            Attachment destattach =  new Attachment();
            destattach.Name = 'DestructiveData';
            destattach.ParentId = detail.Id;
            destattach.Body = delBlob;
            
            attchmenttosave.add(dataattach);
            attchmenttosave.add(fileattach);
            attchmenttosave.add(destattach);
            SObjectAccessDecision securityDecision3 = Security.stripInaccessible(AccessType.CREATABLE, attchmenttosave);
            Insert securityDecision3.getRecords();
            attId = securityDecision3.getRecords()[0].Id;
        }
        return attId;
    }
}