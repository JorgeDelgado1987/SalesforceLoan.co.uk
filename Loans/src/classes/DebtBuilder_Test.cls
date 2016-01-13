@isTest
private class DebtBuilder_Test {

    static testMethod void testGetBuilderInstantiatesRecordAndNameIsSet(){
        Test.startTest();
            DebtBuilder builder = DebtBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                            AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord());
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord());
    }

    static testMethod void testSaveMethodSavesRecord(){
        Creditor__c creditor = CreditorBuilder.getBuilder().save().getRecord();
        Test.startTest();
            DebtBuilder builder = DebtBuilder.getBuilder(
                                    ApplicationBuilder.getBuilder(
                                        AccountBuilder.getBuilder('Test')
                                        .save()
                                        .getRecord())
                                    .save()
                                    .getRecord())
                                  .setCreditor(creditor)
                                  .save();
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord().Id);
    }

    static testMethod void testSetMethodsSetAppropriateValues(){
        Application__c application = ApplicationBuilder.getBuilder(
                                            AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord();
        Creditor__c creditor = CreditorBuilder.getBuilder().save().getRecord();
        Date date_account_opened = Date.newInstance(2011, 2, 2);
        Integer debt_index = 1;
        Integer applicant_index = 2;
        Decimal amount_outstanding = 456.78;
        Test.startTest();
            DebtBuilder builder = DebtBuilder.getBuilder(application)
                                                .setCreditor(creditor)
                                                .setDateAccountOpened(date_account_opened)
                                                .setDebtIndex(debt_index)
                                                .setApplicantIndex(applicant_index)
                                                .setAmountOutstanding(amount_outstanding)
                                                .save();
        Test.stopTest();
        System.assertEquals(creditor.Id,builder.getRecord().Creditor__c);
        System.assertEquals(date_account_opened, builder.getRecord().Date_Account_Opened__c);
        System.assertEquals(debt_index, builder.getRecord().Debt_Index__c);
        System.assertEquals(applicant_index, builder.getRecord().Applicant_Index__c);
        System.assertEquals(amount_outstanding, builder.getRecord().Amount_Outstanding__c);

    }

}