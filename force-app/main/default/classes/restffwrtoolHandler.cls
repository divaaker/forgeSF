public class restffwrtoolHandler{
    public static void restffwrtoolHandler(){
         HttpRequest req = new HttpRequest();
         req.setEndpoint('https://api-staging.ffwrtool.com/api/auth/login');
         req.setMethod('POST');
         //String email= 'Amro@shaketech.com';
         //String password = 'Shaketech2022#';
         //string provider = 'API';
         //Blob headerValue = Blob.valueOf(email + ':' + password + ':' + provider + ':' + provider);
         //String authorizationHeader = 'BASIC ' +
         //EncodingUtil.base64Encode(headerValue);
         string sJosn = '{"email": "Amro@shaketech.com","password": "Shaketech2022#","provider": "API"}';
         req.setHeader('content-type', 'application/json');
         //req.setHeader('Authorization', authorizationHeader);
         req.setHeader('email','Amro@shaketech.com');
         req.setHeader('password','Shaketech2022#');
         req.setHeader('provider','API');
         req.setBody(sJosn);
         Http http = new Http();
         HTTPResponse res = http.send(req);
         System.debug(res.getBody());
         
         HttpRequest req1 = new HttpRequest();
         req1.setEndpoint('https://api-staging.ffwrtool.com/api/beneficiary');
         req1.setMethod('POST');
         string sJosnBenifi = '{"id": 0,"externalId": "string","firstName": "divaker","middleName": "Singh","noMiddleName": true,"lastName": "string","suffix": "None","dateOfBirth": "1987-03-29","street": "string","city": "string","state": "California","zipcode": "11000","noAddress": true,"primaryEmail": "user@example.com","secondaryEmail": "user@example.com","primaryCountryCode": "1 (US)","primaryPhone": "1234567890","secondaryCountryCode": "1 (US)","secondaryPhone": "0987654321","noContactInfo": true,"profession": "Farmworker (Field)","socCode": "Unknown","employerName": "string","intakeMethod": "Paper submission","howDidYouHear": "None","proofOfIdentity": "H2A/H2B visa","proofOfEmployment": "Pay stub","notes": "string","latitude": 0,"longitude": 0,"accuracy": 0,"source": "string"}';
         string sToken = 'eyJhbGciOiJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGRzaWctbW9yZSNobWFjLXNoYTUxMiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiNzEiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9lbWFpbGFkZHJlc3MiOiJhbXJvQHNoYWtldGVjaC5jb20iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJBUEkiLCJHcmFudFJlY2lwaWVudElkIjoiMTUiLCJleHAiOjE2NjkzODc1MTV9.QvKt0orElj_wu-jpBjauvT3yWN4PXkpJI-AKa719fW0cKvVAdM0JuNM_0RSj5CHDbffm3iLkPYm53Bagpt0CRw';
         //req1.setHeader('Token', sToken );
         req1.setHeader('Authorization', sToken );
         Http http1 = new Http();
         HTTPResponse res1 = http1.send(req1);
         System.debug(res1.getBody());
    }
}