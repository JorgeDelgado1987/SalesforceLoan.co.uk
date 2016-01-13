@isTest
public class AccountBuilder_Test {

    static testMethod void testGetBuilderInstantiatesRecordAndNameIsSet(){
        Test.startTest();
            AccountBuilder builder = Accountbuilder.getBuilder('Test');
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord());
        System.assertEquals('Test', builder.getRecord().Name);
    }

    static testMethod void testSaveMethodSavesRecord(){
        Test.startTest();
            Accountbuilder builder = Accountbuilder.getBuilder('Test')
                                                    .save();
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord().Id);
    }
}