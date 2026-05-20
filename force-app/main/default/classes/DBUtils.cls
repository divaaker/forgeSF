public with sharing class DBUtils {
    public static OrgTempData__c getOrgTemp(){
        return [Select Id, OrgRecordId__c FROM OrgTempData__c WITH SECURITY_ENFORCED LIMIT 1];
    }

    public static List<SF_Org__c> getOrgList(){
        return [SELECT Id, Name, AccessToken__c, Authorised__c, Instance_URL__c, OauthID__c, OrgType__c, Org_Name__c, RefreshToken__c, UserEmail__c FROM SF_Org__c WHERE Name!='' WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
    }

    public static SF_Org__c getOrg(String orgId){
        return [SELECT Id, Name, AccessToken__c, Authorised__c, Instance_URL__c, OauthID__c, OrgType__c, Org_Name__c, RefreshToken__c, UserEmail__c  FROM SF_Org__c WHERE Id=:String.escapeSingleQuotes(orgId) WITH SECURITY_ENFORCED LIMIT 1];
    }

    public static List<SF_Org__c> getOrgByName(String name){
        return [SELECT Id FROM SF_Org__c WHERE Name=:String.escapeSingleQuotes(name) WITH SECURITY_ENFORCED LIMIT 1];
    }
    @AuraEnabled
    public static List<SF_Org__c> getAuthorizeOrg(){
        return [SELECT Id, Name, AccessToken__c, Authorised__c, Instance_URL__c, OauthID__c, OrgType__c, Org_Name__c, RefreshToken__c, UserEmail__c FROM SF_Org__c WHERE Authorised__c=true WITH SECURITY_ENFORCED ORDER BY Org_Name__c ASC];
    }

    public static List<Document> getDocs(String fileName){
        return [SELECT Id, Name, FolderId, Body FROM Document WHERE Name = :fileName AND FolderId =:UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];
    }

    public static String getUrl(String type){
        return type =='Sandbox'?Label.Sandbox_Login_URL:Label.Production_Login_URL;
    }

    public static OrgAuthorizationInfo__c getOrgAuthInfo(String selectedOrg){
        return [SELECT Id, AccessToken__c, OrgType__c, RefreshToken__c, Instance_URL__c FROM OrgAuthorizationInfo__c WHERE Id=:String.escapeSingleQuotes(selectedOrg) WITH SECURITY_ENFORCED LIMIT 1];
    }
}