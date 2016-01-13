@isTest
private class MortgageBuilder_Test {

    static testMethod void testGetBuilderInstantiatesRecordAndNameIsSet(){
        Test.startTest();
            MortgageBuilder builder = MortgageBuilder.getBuilder(ApplicationBuilder.getBuilder(
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
            MortgageBuilder builder = MortgageBuilder.getBuilder(ApplicationBuilder.getBuilder(
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
        Property__c property = PropertyBuilder.getBuilder(application)
                                            .save()
                                            .getRecord();
        Date mortgage_start_date = Date.newInstance(2011, 2, 2);
        Boolean on_security_address = true;
        Test.startTest();
            MortgageBuilder builder = MortgageBuilder.getBuilder(application)
                                                            .setOnSecurityAddress(on_security_address)
                                                            .setMortgageStartDate(mortgage_start_date)
                                                            .setProperty(property)
                                                            .save();
        Test.stopTest();
        System.assertEquals(property.Id,builder.getRecord().Property__c);
        System.assertEquals(mortgage_start_date, builder.getRecord().Mortgage_Start_Date__c);
        System.assertEquals(on_security_address, builder.getRecord().On_Security_Address__c);

    }

}