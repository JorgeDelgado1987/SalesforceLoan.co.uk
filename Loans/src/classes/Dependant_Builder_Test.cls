@isTest
private class Dependant_Builder_Test {
	
	  static testMethod void testGetBuilderInstantiatesRecordAndNameIsSet(){
        Test.startTest();
         DependantBuilder builder = DependantBuilder.getBuilder(ApplicantBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                            AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord())
            													.save()
            													.getRecord());



        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord());
    }

   static testMethod void testGetBuilderInstantiatesRecordAndNameIsSetforExistingRecord(){
        Test.startTest();
            DependantBuilder builder = DependantBuilder.getBuilder(ApplicantBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                            AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord())
                                                                .save()
                                                                .getRecord());

            DependantBuilder updatedBuilder = DependantBuilder.getBuilder(builder.getRecord());


        Test.stopTest();
        System.assertNotEquals(null, updatedBuilder.getRecord());
    }

     static testMethod void testSaveMethodSavesRecord(){
        Test.startTest();
            DependantBuilder builder = DependantBuilder.getBuilder(ApplicantBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                            		AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord())
                                                                .save()
                                                                .getRecord())
            														.save();
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord().Id);
    }
	
}