public class listDetails {     
    @AuraEnabled     public static list<Account> getClist(){                  
    return [select Id, Name,  Type from Account];       
	}  
}