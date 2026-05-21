@IsTest
private class BookControllerTest {

    @TestSetup
    static void setup() {
        insert new Book__c(
            Name = 'Dune',
            Title__c = 'Dune',
            Author__c = 'Frank Herbert',
            Status__c = 'Reading'
        );
    }

    @IsTest
    static void getBooks_returnsSeedRecord() {
        Test.startTest();
        List<Book__c> books = BookController.getBooks();
        Test.stopTest();

        System.assertEquals(1, books.size(), 'Expected one seeded book.');
        System.assertEquals('Dune', books[0].Title__c);
    }

    @IsTest
    static void createBook_insertsRecord() {
        Test.startTest();
        Id newId = BookController.createBook('Foundation', 'Isaac Asimov', 'Wishlist');
        Test.stopTest();

        System.assertNotEquals(null, newId);
        Book__c saved = [SELECT Title__c, Status__c FROM Book__c WHERE Id = :newId];
        System.assertEquals('Foundation', saved.Title__c);
        System.assertEquals('Wishlist', saved.Status__c);
    }

    @IsTest
    static void createBook_blankTitleThrows() {
        Boolean threw = false;
        Test.startTest();
        try {
            BookController.createBook('', 'Anon', 'Wishlist');
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();
        System.assert(threw, 'Expected AuraHandledException for blank title.');
    }

    @IsTest
    static void validationRule_blocksCompletedWithoutRating() {
        Book__c b = new Book__c(
            Name = 'Hyperion',
            Title__c = 'Hyperion',
            Status__c = 'Completed'
        );
        Boolean threw = false;
        Test.startTest();
        try {
            insert b;
        } catch (DmlException e) {
            threw = true;
        }
        Test.stopTest();
        System.assert(threw, 'Validation rule should block Completed without Rating.');
    }
}