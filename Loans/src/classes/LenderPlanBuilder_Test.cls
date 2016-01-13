@isTest
public class LenderPlanBuilder_Test {

    static testMethod void testGetBuilderInstantiatesRecordAndParentIsSet(){
        Test.startTest();
            LenderPlanBuilder builder = LenderPlanbuilder.getBuilder(
                                            LenderBuilder.getBuilder('Test')
                                            .save()
                                            .getRecord());
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord());
        System.assertNotEquals(null, builder.getRecord().Lender__c);
    }

    static testMethod void testSaveMethodSavesRecord(){
        Test.startTest();
            LenderPlanBuilder builder = LenderPlanbuilder.getBuilder(
                                            LenderBuilder.getBuilder('Test')
                                            .save()
                                            .getRecord()).save();
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord().Id);
    }
}