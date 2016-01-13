@isTest
private class LeadCreateRelatedRecords_Test {

    static testMethod void testCreateRelatedRecordsMethodCreatesExpectedRecords() {
        Test.startTest();
            Account account = AccountBuilder.getBuilder('Loan.co.uk Ltd').save().getRecord();
            account.Auto_convert_Leads__c = true;
            update account;
            Campaign campaign = CampaignBuilder.getBuilder('Hubspot').setAccount(account).save().getRecord();
            Lead lead = new Lead(LastName = 'Test', Company = 'Test');
            lead.Application_Account__c = account.Id;
            insert lead;
        Test.stopTest();
        Integer counter = [SELECT COUNT() FROM Application__c];
        System.assertEquals(1, counter, 'One Application should be created');
        counter = [SELECT COUNT() FROM Mortgage__c];
        System.assertEquals(1, counter, 'One Mortgage should be created');
        counter = [SELECT COUNT() FROM Property__c];
        System.assertEquals(1, counter, 'One Property should be created');
        counter = [SELECT COUNT() FROM Applicant__c];
        System.assertEquals(1, counter, 'One Applicant should be created');
    }
}