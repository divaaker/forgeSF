@isTest
Public class test_UtilClass{
    Static testMethod void TestMethodData(){
        Account oAcc = New Account(Name = 'Test Account');
        insert oAcc;
        UtilClass.datafetch(oAcc.Name, 'Account');
        UtilClass.LookupData(oAcc.Name, 'Account');
    }
}