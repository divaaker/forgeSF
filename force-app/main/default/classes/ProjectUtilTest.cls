@IsTest
private class ProjectUtilTest {

    @IsTest
    static void applyDefaults_setsStatusAndStartDate() {
        Project__c p = new Project__c(Name = 'Phoenix');

        Test.startTest();
        ProjectUtil.applyDefaults(new List<Project__c>{ p });
        Test.stopTest();

        System.assertNotEquals(null, p.Status__c, 'Status should be defaulted.');
        System.assertEquals(Date.today(), p.StartDate__c, 'StartDate should default to today.');
    }

    @IsTest
    static void applyDefaults_preservesExplicitStatus() {
        Project__c p = new Project__c(Name = 'Apollo', Status__c = 'Active');

        Test.startTest();
        ProjectUtil.applyDefaults(new List<Project__c>{ p });
        Test.stopTest();

        System.assertEquals('Active', p.Status__c, 'Explicit status must not be overwritten.');
    }

    @IsTest
    static void trigger_appliesDefaults_onInsert() {
        Project__c p = new Project__c(Name = 'Vega');

        Test.startTest();
        insert p;
        Test.stopTest();

        Project__c saved = [SELECT Status__c, StartDate__c FROM Project__c WHERE Id = :p.Id];
        System.assertNotEquals(null, saved.Status__c);
        System.assertEquals(Date.today(), saved.StartDate__c);
    }
}