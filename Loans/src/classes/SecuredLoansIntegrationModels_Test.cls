@isTest
private class SecuredLoansIntegrationModels_Test {

    static testMethod void testGetAllApplicationDataAppendsCRSDataToApplication() {
        Application__c test_app = setupData();
        Test.startTest();
            SecuredLoansIntegrationModels.Application application_data = SecuredLoansIntegrationModels.getAllApplicationData(test_app.Id);
        Test.stopTest();
        System.assertEquals(1, application_data.CountyCourtJudgements.size());
        System.assertEquals(1, application_data.Mortgages.size());
        System.assertEquals(1, application_data.Debts.size());
        System.assertEquals(1, application_data.Applicants[0].ApplicantIncomes.size());
    }

    private static Application__c setupData(){
        Account account = AccountBuilder.getBuilder('Test Acc').save().getRecord();
        Application__c application = ApplicationBuilder.getBuilder(account).save().getRecord();
        Applicant__c applicant = ApplicantBuilder.getBuilder(application)
                                                 .setFirstName('Bob')
                                                 .setLastName('Turwilligar')
                                                 .setDateOfBirth(Date.newInstance(1984, 12, 1))
                                                 .setTitle('Mr')
                                                 .setPostCode('2AB 3CD')
                                                 .setMaidenName('Something')
                                                 .setEmail('bob@bob.com')
                                                 .save().getRecord();
        Applicant_Income__c applicantincome = ApplicantIncomeBuilder.getBuilder(applicant).save().getRecord();
        Property__c property = PropertyBuilder.getBuilder(application).save().getRecord();
        Mortgage__c mortgage = MortgageBuilder.getBuilder(application).save().getRecord();
        Debt__c debt = DebtBuilder.getBuilder(application).save().getRecord();
        CCJ__c ccj = CCJBuilder.getBuilder(application).save().getRecord();
        return application;
    }

}