public class ContactImages {
@AuraEnabled(cacheable=true)

    public static List<String> getCampaignImages(){

        try {

            //User contextUser = [SELECT Id, ContactId FROM User WHERE Id = :userID];

            List<Contact> lstCon = [SELECT Id, Image__c FROM Contact WHERE Id ='003B000000LDPJRIA5'];

            //List<CampaignMember> cm = [SELECT Id , Campaign.IMGBanner__c FROM CampaignMember WHERE ContactId = :contextUser.ContactId];

            

            // Cycle over all images

            List<String> lst = new List<String>();

            for(Integer i=0; i<lstCon.size(); i++){

                lst.add(lstCon[i].Image__c);

            }

            return lst;

        } catch (Exception err) {

        throw new AuraHandledException(err.getMessage());

            

        }

    }

}