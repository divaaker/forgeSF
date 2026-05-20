trigger primaryCount on Contact (after insert, after update) {
    
    Set<Id> setAccId = new Set<Id>();
    for (Contact c : Trigger.new) {
       setAccId.add(c.AccountId);
    }
    
    List<Account> accToCon = [SELECT Id,(SELECT Id, Name, Commission_Total__c FROM Contacts WHERE Commission_Total__c != null ORDER BY Commission_Total__c DESC LIMIT 1) FROM Account WHERE Id =: setAccId];
    
    
    for(Account acc: accToCon){
        for(Contact con : acc.Contacts){
            Contact primaryCount;
            if(acc.contacts!=null){
                if(triggerVariable.conTrigger ==false){
                    primaryCount = findMaxCommission(acc.contacts);
                    System.debug(primaryCount);
                    choosePrimaryContact(acc.contacts, primaryCount.id);
                 }
            }
            else{
                continue;
            }
        }
    }
    
    Contact findMaxCommission(List<Contact> contacts){ 
        Contact chosenContact = contacts[0];
        double max = contacts[0].Commission_Total__c;
        for (Contact c : contacts) { 
            if (max < c.Commission_Total__c) { 
                max = c.Commission_Total__c; 
                chosenContact = c;
            } 
        } 
        return chosenContact; 
    } 
    
    void choosePrimaryContact(List<Contact> contacts, id primaryCountId){
        list<Contact> lstUpdate = new List<Contact>();
        for(Contact c : contacts){
            if(c.id == primaryCountId){
                c.Primary__c = true;
            }
            else{
                c.Primary__c = false;
                }
          lstUpdate.add(c);
        } 
        if(lstUpdate.size()>0){
            triggerVariable.conTrigger = true;
            update lstUpdate;
        }       
    }
}