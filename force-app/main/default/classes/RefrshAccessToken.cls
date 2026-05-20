public class RefrshAccessToken {
    //Method to refresh acess token for authenticated SF org
    public static String get(String refreshToken, String orgType) {
        Auth_Provider__c ap = Auth_Provider__c.getInstance();
        String clientId = ap.ClientId__c;
        String clientSecret = ap.ClientSecret__c;
        
        String urlPrefix = DBUtils.getUrl(orgType);
        
        String reqbody = 'client_id='+clientId+'&client_secret='+clientSecret+'&grant_type=refresh_token&refresh_token='+refreshToken;
        
        HttpRequest req = new HttpRequest();    
        //req1.setTimeout(120000);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-type', 'application/x-www-form-urlencoded');
        
        req.setBody(reqbody);
        req.setMethod('POST');
        
        // web server flow request
        req.setEndpoint(urlPrefix+ap.TokenSuffix__c);
        String response = '';
        JSONWrapper jsonDataWrapper = new JSONWrapper();
        
        try{
            Http httpObj = new Http();
            HttpResponse httpResponse = httpObj.send(req);
            if (httpResponse.getStatusCode() == 200) {  
                response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()) );  
                jsonDataWrapper = (JSONWrapper)JSON.deserialize(response,JSONWrapper.class);                
            } 
            else {  
                System.debug(' httpResponse ' + httpResponse.getBody() );  
                throw new CalloutException( httpResponse.getBody() );  
            }  
        } 
        catch(System.Exception e) {  
            System.debug('ERROR: '+ e);  
            throw e;  
        } 
        return jsonDataWrapper.access_token.SubString(15);       
    }

    public class JSONWrapper
    {
        // here rows is the name of field in json this variable should be
        public string access_token;
    }
}