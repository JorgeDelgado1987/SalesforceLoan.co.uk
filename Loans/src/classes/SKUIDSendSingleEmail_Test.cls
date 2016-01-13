@isTest
private class SKUIDSendSingleEmail_Test {

    static testMethod void testSend() {
        Account account = AccountBuilder.getBuilder('Test Acc').save().getRecord();
        Application__c app = ApplicationBuilder.getBuilder(account).setBusiness('Loan.co.uk').save().getRecord();
        Applicant__c applicant = ApplicantBuilder.getBuilder(app).setFirstName('Bob').setLastName('Turwilligar')
            .setMobilePhone('07777777777').setEmail('tes@asdfghtgfr.com').setIsPrimary(true).save().getRecord();
        HttpMockHandler.addSuccessfulMock('');
        System.debug('TEST START');
        Test.startTest();
            CommsEmailService.SendResult result = SKUIDSendSingleEmail.send(applicant.Id, 'test');
        Test.stopTest();
        System.debug('TEST STOP');
        System.assertEquals(true, result.IsSuccess());
    }
}