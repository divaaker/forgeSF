public class UserStoryWrapper {
    @AuraEnabled
    public String sourceOrg, destinationOrg;
    @AuraEnabled
    public Map<string,List<string>> metadata;

}