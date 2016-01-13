@isTest
private class SKUIDSendSingleSMS_Test {

    static testMethod void testSend() {
        Account account = AccountBuilder.getBuilder('Test Acc').save().getRecord();
        Application__c app = ApplicationBuilder.getBuilder(account).setBusiness('Loan.co.uk').save().getRecord();
        Applicant__c applicant = ApplicantBuilder.getBuilder(app).setFirstName('Bob').setLastName('Turwilligar')
            .setMobilePhone('07777777777').setIsPrimary(true).save().getRecord();
        Test.startTest();
            SKUIDSendSingleSMS.send(applicant.Id, 'test', 'Call for full app');
        Test.stopTest();
        List<Customer_Comms_Queue_Item__c> comms_items = [SELECT Remote_Template_Name__c, Send_Date_Time__c, Resend_after_hours__c,
            Application_Stage_to_Handle__c FROM Customer_Comms_Queue_Item__c
            WHERE Applicant__c = :applicant.Id AND Type__c = 'SMS' AND Remote_Template_Name__c = 'test'];
        System.assertEquals(1, comms_items.size());
    }
}