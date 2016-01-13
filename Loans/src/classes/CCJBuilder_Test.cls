@isTest
private class CCJBuilder_Test
{
    static testMethod void testGetBuilderInstantiatesRecordAndNameIsSet(){
        Test.startTest();
            CCJBuilder builder = CCJBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                            AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord());
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord());
    }

    static testMethod void testSaveMethodSavesRecord(){
        Test.startTest();
            CCJBuilder builder = CCJBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                            AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord())
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
        Applicant__c applicant = ApplicantBuilder.getBuilder(application)
                                                    .save()
                                                    .getRecord();
        Date judgement_date = Date.newInstance(2011, 2, 2);
        Integer applicant_index  = 1;
        Integer ccj_index = 1;
        Decimal value = 123.34;
        Test.startTest();
            CCJBuilder builder = CCJBuilder.getBuilder(application)
                                                .setApplicant(applicant)
                                                .setJudgementDate(judgement_date)
                                                .setApplicantIndex(1)
                                                .setCCJIndex(1)
                                                .setValue(value)
                                                .save();
        Test.stopTest();
        System.assertEquals(applicant.Id,builder.getRecord().Applicant__c);
        System.assertEquals(judgement_date, builder.getRecord().Judgement_Date__c);
        System.assertEquals(applicant_index, builder.getRecord().Applicant_Index__c);
        System.assertEquals(ccj_index, builder.getRecord().CCJ_Index__c);
        System.assertEquals(value, builder.getRecord().Value__c);

    }
}