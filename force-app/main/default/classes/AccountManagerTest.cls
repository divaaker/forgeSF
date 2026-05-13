@IsTest
private class AccountManagerTest {
    @isTest static void testGetContactsByAccountId() {
        Id recordId = createTestRecord();
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://girikonllc2-dev-ed.my.salesforce.com/services/apexrest/Account/contacts/'+recordId;
           
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        system.debug('recordId=='+RestContext.request);
        Account thisAccount = AccountManager.getAccount();
        // Verify results
        System.assert(thisAccount != null);
        System.assertEquals('Test record', thisAccount.Name);
    }
    
    // Helper method
    static Id createTestRecord() {
        // Create test record
        Account accountTest = new Account(
            Name='Test record' );
        insert accountTest;
         Contact contactTest = new Contact(FirstName='John',LastName='Doe',AccountId=accountTest.Id);
        
        insert contactTest;
        return accountTest.Id;
    }          
}