public with sharing class TestClassVSCode {
    public TestClassVSCode() {
        Account oAcc = new Account();
        oAcc.Name = 'Test Account';
        insert oAcc; 
    }
}