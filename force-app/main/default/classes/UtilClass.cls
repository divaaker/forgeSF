public class UtilClass {
	 @AuraEnabled(cacheable=true)
    public static list<sObject> datafetch(string searchKey , string sObjectApiName) {
           
        List < sObject > returnListQueue = new List < sObject > ();
        string TextQueue = '%' + searchKey + '%';
        string sQueryqueue = 'Select Id,Name From ' + sObjectApiName + ' Where type = \'Queue\' AND Name Like : TextQueue order by createdDate DESC LIMIT 5';
        for (sObject obj: database.query(sQueryqueue)) {
            returnListQueue.add(obj);
        }
        return returnListQueue;             
                    
    }
    

    @AuraEnabled(cacheable=true)
    public static list<sObject> LookupData(string searchKey , string sObjectApiName) {

        List < sObject > returnListUser = new List < sObject > ();
            string CardText = '%' + searchKey + '%';
            string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : CardText order by createdDate DESC LIMIT 5';
            for (sObject obj: database.query(sQuery)) {
                returnListUser.add(obj);
            }
            return returnListUser;
    }
}