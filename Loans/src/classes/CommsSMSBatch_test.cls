@isTest
private class CommsSMSBatch_test {

    static testMethod void testBatchSMSprocessor() {
        Test.startTest();
            Applicant__c applicant = getTestApplicant();
            Database.executeBatch(new CommsSMSBatch(), 20);
        Test.stopTest();
        Integer all_comms_items_count = [Select COUNT() FROM Customer_Comms_Queue_Item__c WHERE Type__c = 'SMS' AND Sent__c = true AND Applicant__c=:applicant.id];
        System.assertEquals(1, all_comms_items_count, 'Number of sent CCQ SMS items should now be 1');
    }

    private static Applicant__c getTestApplicant(){
        insert new SMS_Template__c(Name = 'loan-co-uk-welcome-sms-1', Sender_ID__c = 'bla');
        Account account = AccountBuilder.getBuilder('Test Acc').save().getRecord();
        Application__c app = ApplicationBuilder.getBuilder(account).save().getRecord();
        return ApplicantBuilder.getBuilder(app).setFirstName('Bob').setLastName('Turwilligar').setMobilePhone('07777777777').save().getRecord();
    }
}