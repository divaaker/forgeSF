/**
 * @description Test class for AccountService.
 *              Covers positive, negative, and bulk scenarios. Targets >90% coverage.
 * @author      Divaker Singh
 */
@IsTest
private class AccountServiceTest {

    @TestSetup
    static void setupData() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(
                Name = 'Setup Account ' + i,
                Industry = 'Technology'
            ));
        }
        insert accounts;
    }

    @IsTest
    static void testCreateAccounts_Positive() {
        List<Account> newAccounts = new List<Account>{
            new Account(Name = 'Acme Corp', Industry = 'Manufacturing'),
            new Account(Name = 'Globex Inc')   // Industry should default
        };

        Test.startTest();
        List<Account> result = AccountService.createAccounts(newAccounts);
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Two accounts should be returned.');
        System.assertNotEquals(null, result[0].Id, 'First account should have an Id.');
        System.assertEquals('Other', result[1].Industry, 'Industry should default to Other.');
    }

    @IsTest
    static void testCreateAccounts_BulkInsert() {
        List<Account> bulkAccounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            bulkAccounts.add(new Account(Name = 'Bulk Account ' + i));
        }

        Test.startTest();
        List<Account> result = AccountService.createAccounts(bulkAccounts);
        Test.stopTest();

        System.assertEquals(200, result.size(), 'All 200 accounts should be inserted.');
    }

    @IsTest
    static void testCreateAccounts_NullList() {
        Boolean exceptionThrown = false;
        try {
            AccountService.createAccounts(null);
        } catch (AccountService.AccountServiceException e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('null or empty'), 'Expected null/empty message.');
        }
        System.assert(exceptionThrown, 'Exception should be thrown for null input.');
    }

    @IsTest
    static void testCreateAccounts_BlankName() {
        List<Account> badAccounts = new List<Account>{ new Account(Industry = 'Retail') };

        Boolean exceptionThrown = false;
        try {
            AccountService.createAccounts(badAccounts);
        } catch (AccountService.AccountServiceException e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('Account Name'), 'Expected Name validation message.');
        }
        System.assert(exceptionThrown, 'Exception should be thrown for blank name.');
    }

    @IsTest
    static void testCreatePrimaryContacts_Positive() {
        Set<Id> accIds = new Map<Id, Account>([SELECT Id FROM Account]).keySet();

        Test.startTest();
        Map<Id, Contact> contactMap = AccountService.createPrimaryContacts(accIds, 'Smith');
        Test.stopTest();

        System.assertEquals(accIds.size(), contactMap.size(), 'One contact per account.');
        for (Id accId : accIds) {
            System.assert(contactMap.containsKey(accId), 'Map should contain account Id.');
            System.assertEquals('Smith', contactMap.get(accId).LastName, 'LastName should match.');
        }
    }

    @IsTest
    static void testCreatePrimaryContacts_EmptySet() {
        Boolean exceptionThrown = false;
        try {
            AccountService.createPrimaryContacts(new Set<Id>(), 'Smith');
        } catch (AccountService.AccountServiceException e) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Exception expected for empty Id set.');
    }

    @IsTest
    static void testCreatePrimaryContacts_BlankLastName() {
        Set<Id> accIds = new Map<Id, Account>([SELECT Id FROM Account LIMIT 1]).keySet();
        Boolean exceptionThrown = false;
        try {
            AccountService.createPrimaryContacts(accIds, '');
        } catch (AccountService.AccountServiceException e) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Exception expected for blank last name.');
    }

    @IsTest
    static void testGetContactCountByAccount() {
        List<Account> accounts = [SELECT Id FROM Account LIMIT 2];
        List<Contact> contacts = new List<Contact>{
            new Contact(LastName = 'A', AccountId = accounts[0].Id),
            new Contact(LastName = 'B', AccountId = accounts[0].Id),
            new Contact(LastName = 'C', AccountId = accounts[1].Id)
        };
        insert contacts;

        Set<Id> accIds = new Set<Id>{ accounts[0].Id, accounts[1].Id };

        Test.startTest();
        Map<Id, Integer> result = AccountService.getContactCountByAccount(accIds);
        Test.stopTest();

        System.assertEquals(2, result.get(accounts[0].Id), 'First account should have 2 contacts.');
        System.assertEquals(1, result.get(accounts[1].Id), 'Second account should have 1 contact.');
    }

    @IsTest
    static void testGetContactCountByAccount_EmptySet() {
        Test.startTest();
        Map<Id, Integer> result = AccountService.getContactCountByAccount(null);
        Test.stopTest();

        System.assert(result.isEmpty(), 'Result should be empty for null input.');
    }
}