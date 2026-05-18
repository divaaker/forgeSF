/**
 * @description Service class for Account-related business operations.
 *              Demonstrates bulkified DML, exception handling, and related record creation.
 * @author      Divaker Singh
 * @Change      First change after the deployment to see, what is the change in commit.
 */
public with sharing class AccountService {

    public class AccountServiceException extends Exception {}

    /**
     * Creates accounts in bulk with default values applied where needed.
     * @param accountsToCreate List of Account records to insert
     * @return List of inserted Account records (with IDs)
     */
    public static List<Account> createAccounts(List<Account> accountsToCreate) {
        if (accountsToCreate == null || accountsToCreate.isEmpty()) {
            throw new AccountServiceException('Account list cannot be null or empty.');
        }

        for (Account acc : accountsToCreate) {
            if (String.isBlank(acc.Name)) {
                throw new AccountServiceException('Account Name is required.');
            }
            if (String.isBlank(acc.Industry)) {
                acc.Industry = 'Other';
            }
        }

        try {
            insert accountsToCreate;
        } catch (DmlException e) {
            throw new AccountServiceException('Failed to insert accounts: ' + e.getMessage());
        }

        return accountsToCreate;
    }

    /**
     * Creates a primary contact for each provided account.
     * @param accountIds Set of Account Ids
     * @param lastName Default last name to use for the contact
     * @return Map of AccountId to created Contact
     */
    public static Map<Id, Contact> createPrimaryContacts(Set<Id> accountIds, String lastName) {
        if (accountIds == null || accountIds.isEmpty()) {
            throw new AccountServiceException('Account Id set cannot be null or empty.');
        }
        if (String.isBlank(lastName)) {
            throw new AccountServiceException('Last name is required.');
        }

        List<Contact> contactsToInsert = new List<Contact>();
        for (Id accId : accountIds) {
            contactsToInsert.add(new Contact(
                LastName = lastName,
                AccountId = accId
            ));
        }

        insert contactsToInsert;

        Map<Id, Contact> result = new Map<Id, Contact>();
        for (Contact c : contactsToInsert) {
            result.put(c.AccountId, c);
        }
        return result;
    }

    /**
     * Returns accounts with their contact count.
     * @param accountIds Account Ids to query
     * @return Map of AccountId to contact count
     */
    public static Map<Id, Integer> getContactCountByAccount(Set<Id> accountIds) {
        Map<Id, Integer> countMap = new Map<Id, Integer>();
        if (accountIds == null || accountIds.isEmpty()) {
            return countMap;
        }

        for (Id accId : accountIds) {
            countMap.put(accId, 0);
        }

        for (AggregateResult ar : [
            SELECT AccountId, COUNT(Id) total
            FROM Contact
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            countMap.put((Id) ar.get('AccountId'), (Integer) ar.get('total'));
        }

        return countMap;
    }
}