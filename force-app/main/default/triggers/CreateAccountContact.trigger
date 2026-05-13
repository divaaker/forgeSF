trigger CreateAccountContact on Account (after insert, after update) {
    List<Contact> lstconUpdate = new List<Contact>();
    List<Contact> lstCon = [SELECT Id, Email, Phone, AccountId FROM Contact WHERE Email =:trigger.new[0].Email__c AND PHONE =:trigger.new[0].Phone AND AccountId =null];
    If(lstCon.size()>0){
        For(Contact oCon: lstCon){
            oCon.AccountId = trigger.new[0].Id;
            lstconUpdate.add(oCon);
        }
        if(lstconUpdate.size()>0){
            Update lstconUpdate;
        }
    }
    else {
        Contact oCon = new Contact();
        oCon.lastName = trigger.new[0].Name;
        oCon.Email = trigger.new[0].Email__c;
        oCon.Phone = trigger.new[0].Phone;
        oCon.AccountId = trigger.new[0].Id;
        Insert oCon;
    }
}