public with sharing class BookController {

    @AuraEnabled(cacheable=true)
    public static List<Book__c> getBooks() {
        return [
            SELECT Id, Name, Title__c, Author__c, Rating__c, Status__c, DateFinished__c
            FROM Book__c
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
            LIMIT 200
        ];
    }

    @AuraEnabled
    public static Id createBook(String title, String author, String status) {
        if (String.isBlank(title)) {
            throw new AuraHandledException('Title is required.');
        }
        Book__c b = new Book__c(
            Name = title,
            Title__c = title,
            Author__c = author,
            Status__c = String.isBlank(status) ? 'Wishlist' : status
        );
        insert b;
        return b.Id;
    }
}