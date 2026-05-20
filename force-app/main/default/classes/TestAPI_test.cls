@isTest
Public class TestAPI_test{
    static testMethod void testSetupAPI(){
        Opportunity oOpp = new Opportunity(Name= 'Test Opportunity', StageName = 'Closed Won', Amount = 100, CloseDate = System.Today().AddDays(10));
        insert oOpp;
        TestAPI.OpportunityWrapper wrapperCls = new TestAPI.OpportunityWrapper();
        wrapperCls.projectId = '1234567890'; 
        wrapperCls.arcProjectName = 'Test Proj';
        wrapperCls.opportunityId = oOpp.Id;
        List<TestAPI.OpportunityWrapper> lstWrapper = new List<TestAPI.OpportunityWrapper>();
        lstWrapper.add(wrapperCls);
        TestAPI.doPost(lstWrapper);
    }
}