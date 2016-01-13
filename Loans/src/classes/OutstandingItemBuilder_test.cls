@isTest
private class OutstandingItemBuilder_test {
	
	 static testMethod void testGetBuilderInstantiatesRecordAndNameIsSet(){
        Test.startTest();
            OutstandingItemBuilder builder = OutstandingItemBuilder.getBuilder(ApplicationBuilder.getBuilder(
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
            OutstandingItemBuilder builder = OutstandingItemBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                            AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord())
                                                                .save();
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord().Id);
    }
	
}