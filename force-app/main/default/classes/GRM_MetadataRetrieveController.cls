public class GRM_MetadataRetrieveController {    
   
    @AuraEnabled
    public static string RMgetSeletedMetadataMemberMap(string parentId){
        Deployment_Detail__c recordId = [Select Id, Deployment__c from Deployment_Detail__c where Id =: parentId limit 1];
        Deployment_Metadata__c detail=[Select DeploymentData__c from Deployment_Metadata__c where Deployment__c =: recordId.Deployment__c limit 1];
        String obj =detail.DeploymentData__c;
        return obj;
    }
    @AuraEnabled
    public static string RMgetRollbackMetadataMemberMap(string parentId){
        Deployment_Detail__c recordId = [Select Id, Deployment__c from Deployment_Detail__c where Id =: parentId limit 1];
        Deployment_Metadata__c detail=[Select DataToRollBack__c from Deployment_Metadata__c where Deployment__c =: recordId.Deployment__c limit 1];
        String obj =detail.DataToRollBack__c;
        return obj;
    }
    @AuraEnabled
    public static string RMgetDeletedMetadataMemberMap(string parentId){
        Deployment_Detail__c recordId = [Select Id, Deployment__c from Deployment_Detail__c where Id =: parentId limit 1];
        Deployment_Metadata__c detail=[Select DataToDel__c from Deployment_Metadata__c where Deployment__c =: recordId.Deployment__c limit 1];
        String obj =detail.DataToDel__c;
        return obj;
    }
}