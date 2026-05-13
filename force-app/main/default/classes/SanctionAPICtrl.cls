public with sharing class SanctionAPICtrl {
    public string sRes {get;set;}
    public Pagereference  getResponse() {
        String queryString ='';
        queryString = ApexPages.currentPage().getParameters().get('Id');
        Account oAcc = [SELECT Id, Name, Sanaction_API_data__c, Sanaction_API_Data_Date__c from Account WHERE Id=:queryString];
        string sSearchName = oAcc.Name;
        string sReplaceString = sSearchName.replace(' ','%20');
        system.debug(oAcc);
        system.debug(sSearchName);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        //req.setEndpoint('https://api.sanctions.io/search/?data_source=SDN,HM%20TREASURY,PEP,CANADA-SEMA,CFSP&name=Divaker%20Singh');
        req.setEndpoint('callout:Test'+'/search/?data_source=SDN&name='+sReplaceString);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json; version=2.2');
        req.setHeader('Authorization','{!$Credential.sanctionAPI.Token}');
        //req.setHeader( 'Authorization', 'Bearer 7dee3436-d02c-4c4f-9de3-1f79bd85101f');
        System.debug(req);
        HttpResponse res = http.send(req);
        sRes = res.getBody();
        // Log the JSOn content
        System.debug(res.getBody());
        oAcc.Sanaction_API_data__c = sRes;
        oAcc.Sanaction_API_Data_Date__c = system.now();
        Update oAcc;
        System.debug(oAcc);
        JSONParser parser = JSON.createParser(sRes);
        system.debug('parser ====='+parser );
        SanactionAPIParser jsonParser = (SanactionAPIParser)JSON.deserialize(sRes, SanactionAPIParser.class);
        system.debug('jsonParser ====='+jsonParser.count);
        system.debug('jsonParser ====='+jsonParser.Results);
        for(integer i=0;i<jsonParser.count;i++){
        String sName = JSON.serialize(jsonParser.Results[i].name);
        String sConfscore = JSON.serialize(jsonParser.Results[i].confidence_score);
        String sEntrityType = JSON.serialize(jsonParser.Results[i].entity_type);
        String sDataSource = JSON.serialize(jsonParser.Results[i].data_source);
        String sslURL = JSON.serialize(jsonParser.Results[i].source_list_url);
        String sSIURL = JSON.serialize(jsonParser.Results[i].source_information_url);
        String sSIIndet = JSON.serialize(jsonParser.Results[i].si_identifier);
        String sEntityNumber = JSON.serialize(jsonParser.Results[i].entity_number);
        String sDatahash= JSON.serialize(jsonParser.Results[i].data_hash);
        String sremarks= JSON.serialize(jsonParser.Results[i].remarks);
        //String sAdditionalInfo= JSON.serialize(jsonParser.Results[i].additional_information.tax_id);
        //String sregistration_number= JSON.serialize(jsonParser.Results[i].additional_information.registration_number);
        //String sAltName= JSON.serialize(jsonParser.Results[i].alt_names[0]);
        //String sAltName1= JSON.serialize(jsonParser.Results[i].alt_names[1]);
       // String sAltName2= JSON.serialize(jsonParser.Results[i].alt_names[2]);
        //system.debug('sAltName====='+sAltName);
        //system.debug('sAltName1====='+sAltName1);
       // system.debug('sAltName2====='+sAltName2);
        
        system.debug('sName ====='+sName );
        system.debug('sConfscore ====='+sConfscore );
        system.debug('sEntrityType====='+sEntrityType);
        system.debug('sDataSource ====='+sDataSource );
        system.debug('sslURL ====='+sslURL );
        system.debug('sSIURL ====='+sSIURL );
        system.debug('sSIIndet ====='+sSIIndet );
        system.debug('sEntityNumber ====='+sslURL );
        system.debug('sDatahash====='+sDatahash);
        system.debug('sremarks====='+sremarks);
        //system.debug('sAdditionalInfo====='+sAdditionalInfo);
        //system.debug('sregistration_number====='+sregistration_number);
        }
        
        while (parser.nextToken() != null) {
                system.debug('parser.nextToken() ====='+parser.nextToken() );
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                system.debug('parser.getCurrentToken()  ====='+parser.getCurrentToken()  );
                 while (parser.nextToken() != null) {
                     system.debug('parser.nextToken()  ====='+parser.nextToken() );
                     if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                         system.debug('parser.getCurrentToken() ====='+parser.getCurrentToken() );
                     }
                 }
            }
        }
        return null;
    }
}