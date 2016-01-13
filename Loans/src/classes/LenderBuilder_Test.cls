@isTest
public class LenderBuilder_Test {

    static testMethod void testGetBuilderInstantiatesRecordAndNameIsSet(){
        Test.startTest();
            LenderBuilder builder = Lenderbuilder.getBuilder('Test');
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord());
        System.assertEquals('Test', builder.getRecord().Name);
    }

    static testMethod void testSaveMethodSavesRecord(){
        Test.startTest();
            Lenderbuilder builder = Lenderbuilder.getBuilder('Test')
                                                    .save();
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord().Id);
    }

    static testMethod void testSetMethodsSetAppropriateValues(){
        Boolean is_integrated = true;
        Test.startTest();
            Lenderbuilder builder = Lenderbuilder.getBuilder('Test')
                                                    .setIsIntegrated(is_integrated)
                                                    .save();
        Test.stopTest();
        System.assertEquals(is_integrated, builder.getRecord().Is_Integrated__c);
    }
}