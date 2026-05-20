@istest
Public class TestClass {
    @isTest
    private static void testPortal() {
    
      UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'CEO' Limit 1];
      ID ProfileID = [ Select id from Profile where name = 'LT SME / Enterprise User Portal Profile'].id;

Account acc = new Account(Name = 'Test Account');

insert acc ;

List<Contact> ContactList = new List<Contact>();

Contact Con = new Contact( AccountID = acc .id, FirstName = 'User', LastName = 'test',

email = 'testuser@xyz.com' );

insert Con;

User u = new User( email='testuser@xyz.com', contactid = Con.id, profileid = ProfileID, UserName='test12user@xyz.com', alias='tuser', CommunityNickName='tuser',

TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1',

LanguageLocaleKey='en_US', FirstName = 'User', LastName = 'Test', UserRoleId = userRole.Id );

insert u;
       
    
 System.RunAs(u)
        {
                 //PortalEmailSubscription.updateEmailSubscription(true);   
        }
    }
}