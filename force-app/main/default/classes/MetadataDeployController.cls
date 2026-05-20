public with sharing class MetadataDeployController 
{       
    public static MetadataService.AsyncResult deployZip(String zipData,String testlevel,String allTestClass, String sourceOrg, String destinationOrg){
        // Deploy zip file posted back from the page action function    
        MetadataService.MetadataPort service = createServiceDeployNew(sourceOrg, destinationOrg);
        MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = false;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        //deployOptions.testLevel = 'NoTestRun';
        deployOptions.singlePackage = true; 
        deployOptions.testLevel = testlevel;
        // Set the appropriate test level.
        // deployOptions.setTestLevel(TestLevel.RunSpecifiedTests);
        if(testlevel=='RunSpecifiedTests'){
            String[] testclass = allTestClass.split(',');
            deployOptions.runTests=testclass;            
        }
        return service.deploy(zipData, deployOptions);
    }
    
    public static MetadataService.AsyncResult validateZip(String zipData, String testlevel, String alltestclass, String sourceOrg, String destinationOrg){
        // Deploy zip file posted back from the page action function    
        MetadataService.MetadataPort service = createServiceDeployNew(sourceOrg, destinationOrg);
        MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = true;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        deployOptions.singlePackage = true; 
        deployOptions.testLevel = testlevel;
        if(testlevel=='RunSpecifiedTests'){
            String[] testclass = allTestClass.split(',');
            deployOptions.runTests=testclass;            
        }
        return service.deploy(ZipData, DeployOptions);
    }
    
    public static String checkAsyncRequest(String asyncResultId, string packageId, string sourceOrg, string destinationOrg, string parentId)
    {   
        string response ='';
        // Check the status of the retrieve request
        MetadataService.MetadataPort service = createServiceDeployNew(sourceOrg, destinationOrg);
        MetadataService.DeployResult deployResult = service.checkDeployStatus(asyncResultId, true);
        if(deployResult!=null){            
            String runTestErrorMessage='';
            if(deployResult.details!=null&&deployResult.details.runTestResult!=null){                
                if(deployResult.details.runTestResult.codeCoverageWarnings!=null)
                {
                    for(MetadataService.CodeCoverageWarning codewarning :deployResult.details.runTestResult.codeCoverageWarnings){
                        RunTestErrorMessage=RunTestErrorMessage+' '+codewarning.message;
                    }
                }                
            }
            // if(deployResult.details!=null&&deployResult.details.retrieveResult!=null){
                
            // }
            
            String componentFailureReason='';
            // Deployment errors?            
            if(deployResult.done && deployResult.details!=null && deployResult.details.componentFailures!=null){
                for(MetadataService.DeployMessage deployMessage : deployResult.details.componentFailures){
                    if(deployMessage.problem!=null){
                        response = response + deployMessage.fileName + ' (Line: ' + deployMessage.lineNumber + ': Column:' + deployMessage.columnNumber + ') : ' + deployMessage.problem;
                    }
                    componentFailureReason=componentFailureReason +'     '+ deployMessage.problem;                        
                }
            }
            if(deployResult.done && deployResult.success) 
            {
                response = 'Success';
                system.debug('Deployment Success');
            }
            else if(deployResult.done){
                response='Failure';
                system.debug('Deployment Failed');
            }
            if(deployResult.done){
                Deployment_Detail__c deploymentresult= new  Deployment_Detail__c(); 
                //deploymentresult.Done__c    ='True';
                deploymentresult.id = packageId;
                deploymentresult.Deployment__c = parentId;
                //  deploymentresult.GRM_UserStoryDeploymentDetail__c = packageId;
                //deploymentresult.ErrorMessage__c    =deployResult.errorMessage;
                //deploymentresult.StateDetail__c =deployResult.stateDetail;
                deploymentresult.Status__c  =response;
                //deploymentresult.TestCompleted__c   =deployResult.numberTestsCompleted;
                deploymentresult.Deployment_Error__c    =componentFailureReason;
                deploymentresult.Deployment_Id__c    =deployResult.id;
                deploymentresult.Test_Error__c =RunTestErrorMessage;
                //deploymentresult.TotalTest__c   =deployResult.numberTestsTotal;
                //deploymentresult.TotalComponent__c  =deployResult.numberComponentsTotal;
                //deploymentresult.Canceled__c    =deployResult.canceledBy;
                //deploymentresult.CancelledbyName__c =deployResult.canceledByName;
                //deploymentresult.ErrorStatusCode__c     =deployResult.errorStatusCode;
                //deploymentresult.ComponentDeployed__c       =deployResult.numberComponentsDeployed;
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, new Deployment_Detail__c[]{deploymentresult});
                Update securityDecision.getRecords();  
            }
        }
        return response;
    }
    
    public static Map<String,String> checkValidationRequest(String asyncResultId, string packageId,string sourceOrg, string destinationOrg, string parentId)
    {   
        Map<String,String> returnMap = new Map<String,String>();
        string response ='';
        // Check the status of the retrieve request
        MetadataService.MetadataPort service = createServiceDeployNew(sourceOrg, destinationOrg);
        MetadataService.DeployResult deployResult = service.checkDeployStatus(asyncResultId, true);
        
        if(deployResult!=null){
            
            String runTestErrorMessage='';
            
            if(deployResult.details!=null&&deployResult.details.runTestResult!=null){                
                if(deployResult.details.runTestResult.codeCoverageWarnings!=null){                    
                    for(MetadataService.CodeCoverageWarning codewarning :deployResult.details.runTestResult.codeCoverageWarnings){
                        RunTestErrorMessage=RunTestErrorMessage+' '+codewarning.message;
                    }
                }                
            }

            // if(deployResult.details!=null&&deployResult.details.retrieveResult!=null){
                
            // }
            
            String componentFailureReason='';
            // Deployment errors?
            
            if(deployResult.done && deployResult.details!=null && deployResult.details.componentFailures!=null){
                for(MetadataService.DeployMessage deployMessage : deployResult.details.componentFailures){
                    if(deployMessage.problem!=null){
                        response = response + deployMessage.fileName + ' (Line: ' + deployMessage.lineNumber + ': Column:' + deployMessage.columnNumber + ') : ' + deployMessage.problem;
                    }
                    componentFailureReason=componentFailureReason +'     '+ deployMessage.problem;                    
                    returnmap.put('msg',componentFailureReason);
                }
            }
            
            if(deployResult.done && deployResult.success){
                response = 'Validated';
            }
            else if(deployResult.done){
                response='Validation Failure';
            }
            
            Deployment_Detail__c deploymentresult= new  Deployment_Detail__c(); 
            //deploymentresult.Done__c    ='True';
            deploymentresult.id = packageId;
            //  deploymentresult.GRM_UserStoryDeploymentDetail__c = packageId;
            //deploymentresult.ErrorMessage__c    =deployResult.errorMessage;
            //deploymentresult.StateDetail__c =deployResult.stateDetail;
            deploymentresult.Status__c  =response;
            deploymentresult.Deployment__c = parentId;
            //deploymentresult.TestCompleted__c   =deployResult.numberTestsCompleted;
            deploymentresult.Deployment_Error__c    =componentFailureReason;
            deploymentresult.Deployment_Id__c    =deployResult.id;
            deploymentresult.Test_Error__c =RunTestErrorMessage;
            //deploymentresult.TotalTest__c   =deployResult.numberTestsTotal;
            //deploymentresult.TotalComponent__c  =deployResult.numberComponentsTotal;
            //deploymentresult.Canceled__c    =deployResult.canceledBy;
            //deploymentresult.CancelledbyName__c =deployResult.canceledByName;
            //deploymentresult.ErrorStatusCode__c     =deployResult.errorStatusCode;
            //deploymentresult.ComponentDeployed__c       =deployResult.numberComponentsDeployed;
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, new Deployment_Detail__c[]{deploymentresult});
            update securityDecision.getRecords();
        }
        returnmap.put('response',response);        
        return returnmap;
    }
    
    private static MetadataService.MetadataPort createServiceDeploy()
    { 
        OrgTempData__c orgdata = OrgTempData__c.getOrgDefaults();        
        OrgAuthorizationInfo__c orgInfo = DBUtils.getOrgAuthInfo(orgdata.DestinationOrg__c);

        String accessToken = RefrshAccessToken.get(orgInfo.RefreshToken__c,orgInfo.OrgType__c);
        
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = accessToken;
        service.endpoint_x = orgInfo.instance_url__c+'/services/Soap/m/42.0';
        
        return service;     
    }
    
    private static MetadataService.MetadataPort createServiceDeployNew(String sourceOrg, String destinationOrg)
    { 
        SF_Org__c orgInfo = DBUtils.getOrg(destinationOrg);
        string accessToken = RefrshAccessToken.get(orgInfo.RefreshToken__c,orgInfo.OrgType__c);
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = accessToken;
        service.endpoint_x = orgInfo.instance_url__c+'/services/Soap/m/42.0';        
        return service;     
    }
}