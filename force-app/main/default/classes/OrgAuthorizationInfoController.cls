public with sharing class OrgAuthorizationInfoController{
    @AuraEnabled
    public static List<SF_Org__c> getOrgList() {
        return DBUtils.getOrgList();
    }

    @AuraEnabled
    public static List<SF_Org__c> deleteOrg(String orgId){
        SF_Org__c delOrg = DBUtils.getOrg(orgId);
        if(Schema.SObjectType.SF_Org__c.isDeletable()){
            Delete (delOrg);
        }
        return getOrgList();
    }
    
    //Method to return acess token for authenticated SF org
    @auraEnabled
    public static String returnAccessToken() {
        Auth_Provider__c ap = Auth_Provider__c.getInstance();
        // Comment : Need to replace this see if it possible to fetch client id and secret using apex directly  
        String clientId = ap.ClientId__c;
        String clientsecret = ap.ClientSecret__c;
        String urlPrefix = '';
        
        // comment: make url dynamic 
        String redirectionurl = ap.CallbackUrl__c;
        
        OrgTempData__c orgtemData = DBUtils.getOrgTemp();
        SF_Org__c orgInfo = DBUtils.getOrg(orgtemData.OrgRecordId__c);
        
        String orgType = OrgInfo.OrgType__c;
        
        urlPrefix = DBUtils.getUrl(orgType);
        // web server flow request
        String reqbody = urlPrefix+ap.AuthSuffix__c+'?response_type=code&display=popup&client_id=' + clientId + '&redirect_uri=' + redirectionurl + '&response_type=code&scope=' + encodingUtil.URLEncode('full refresh_token','UTF-8');
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('GET');
        
        // web server flow request
        req.setEndpoint(URLPrefix+ap.AuthSuffix__c);
        HttpResponse res = h.send(req);
        return res.getStatusCode() == 302?res.getHeader('Location'):'';        
    }
    
    @AuraEnabled
    public static string  insertCustomSetdata(string orgId) {
        string returnMsg ='';
        //fetches or creates a Custom Setting at the organization level 
        try{
            OrgTempData__c setting = OrgTempData__c.getOrgDefaults();
            setting.OrgRecordId__c = orgId;            
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPSERTABLE, new OrgTempData__c[]{setting});
            Upsert securityDecision.getRecords();
            returnMsg ='Success';
        }
        catch(exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        return returnMsg;
    }
    
    @AuraEnabled
    public static String duplicateOrgName(String orgname, String orgtype){
        String msg ='';
        List<SF_Org__c> orglist = DBUtils.getOrgByName(orgname);
        
        if(String.isBlank(orgname)){
            msg ='NUllERROR';
        }
        else{
            if(orglist.isEmpty()){                
                SF_Org__c org= new SF_Org__c();
                org.Name = orgname;
                org.OrgType__c = orgtype;
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, new SF_Org__c[]{org});
                Insert securityDecision.getRecords();                
                Msg ='SUCCESS';
            }
            else{
                Msg ='ERROR';
            }
        }
        return Msg;
    }
}