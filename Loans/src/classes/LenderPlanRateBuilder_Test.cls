@isTest
public class LenderPlanRateBuilder_Test {

    static testMethod void testGetBuilderInstantiatesRecordAndParentIsSet(){
        Test.startTest();
            LenderPlanRateBuilder builder = LenderPlanRateBuilder.getBuilder(
                                                LenderPlanbuilder.getBuilder(
                                                    LenderBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord());
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord());
        System.assertNotEquals(null, builder.getRecord().Lender_Plan__c);
    }

    static testMethod void testSaveMethodSavesRecord(){
        Test.startTest();
            LenderPlanRateBuilder builder = LenderPlanRateBuilder.getBuilder(
                                                LenderPlanbuilder.getBuilder(
                                                    LenderBuilder.getBuilder('Test')
                                                    .save()
                                                    .getRecord())
                                                        .save()
                                                        .getRecord())
                                                            .save();
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord().Id);
    }
}