trigger CreditCardvalidation on Contact (after insert, after Update) {
	Set<Id> setAccId = new Set<Id>();
    List<Account> lstAcc = new List<Account>();
    for (Contact c : Trigger.new) {
    	setAccId.add(c.AccountId);
    }
    CCValidation ocls = new CCValidation();
    List<Contact> lstCon = [SELECT Id, Credit_card_number__c, AccountId FROM Contact WHERE AccountId IN : setAccId AND Credit_card_number__c != null];
    If(lstCon.size()>0){
     	for (Contact con : lstCon){
            Account oAcc = new Account();
            oAcc.Id = con.AccountId;
    		oAcc.All_Valid_Credit_Cards__c = ocls.CCValidationMethod(con.Credit_card_number__c);
            lstAcc.add(oAcc);
    	}
        if(lstAcc.size()>0){
            update lstAcc;
        }   
    }	    
}