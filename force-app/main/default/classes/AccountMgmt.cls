@RestResource(urlMapping='/SendEventToMyOrg/*')
global class AccountMgmt{
   global class SendGridEventDTO {
        public String email;
        public Long timestamp;
        public String event;
        public SendGridEventDTO() {}
    } 

    @HttpPost
    global static void sendEventToMe() {
        system.debug('sendEventToMe====');
        RestRequest request = RestContext.request;
        system.debug('request====='+request );
        List<SendGridEventDTO> eventList = (List<SendGridEventDTO>)JSON.deserialize( request.requestBody.toString(),List<SendGridEventDTO>.class );
        system.debug('eventList ====='+eventList );
        if ( eventList != null && eventList.size() > 0 ) {
            for(SendGridEventDTO oDTO : eventList ){
                System.debug(oDTO.email);
            }
            // do something useful here
        }
    }
}