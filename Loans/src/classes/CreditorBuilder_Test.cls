@isTest
private class CreditorBuilder_Test {

    static testMethod void testGetBuilderInstantiatesRecord(){
        Test.startTest();
            CreditorBuilder builder = CreditorBuilder.getBuilder();
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord());
    }

    static testMethod void testSaveMethodSavesRecord(){
        Test.startTest();
            CreditorBuilder builder = CreditorBuilder.getBuilder().save();
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord().Id);
    }

}