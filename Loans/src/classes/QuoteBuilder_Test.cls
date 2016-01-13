@isTest
public class QuoteBuilder_Test {

    static testMethod void testGetBuilderInstantiatesRecordAndParentIsSet(){
        Test.startTest();
            QuoteBuilder builder = QuoteBuilder.getBuilder(ApplicationBuilder.getBuilder(
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
            QuoteBuilder builder = QuoteBuilder.getBuilder(ApplicationBuilder.getBuilder(
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
        Integer broker_fee = 500;
        Lender__c lender = LenderBuilder.getBuilder('Test').save().getRecord();
        Lender_Plan__c lender_plan = LenderPlanBuilder.getBuilder(lender).save().getRecord();
        Lender_Plan_Rate__c lender_plan_rate = LenderPlanRateBuilder.getBuilder(lender_plan).save().getRecord();
        Double monthly_repayment = 202.55;
        Double commission = 222.22;
        Double apr = 14.67;
        Double lender_fee = 400;
        Double tt_fee = 2.34;
        Double solicitors_costs = 254.66;
        Double title_insurance = 500;
        Double interest_rate = 23.2;
        Test.startTest();
            QuoteBuilder builder = QuoteBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                            AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord())
                                                                .setBrokerFee(broker_fee)
                                                                .setLender(lender)
                                                                .setLenderPlan(lender_plan)
                                                                .setLenderPlanRate(lender_plan_rate)
                                                                .setMonthlyRepayment(monthly_repayment)
                                                                .setCommission(commission)
                                                                .setApr(apr)
                                                                .setLenderFee(lender_fee)
                                                                .setTTFee(tt_fee)
                                                                .setSolicitorsCosts(solicitors_costs)
                                                                .setTitleInsurance(title_insurance)
                                                                .setInterestRate(interest_rate)
                                                                .save();
        Test.stopTest();
        System.assertEquals(broker_fee, builder.getRecord().Broker_Fee__c);
        System.assertEquals(lender, builder.getRecord().Lender_Fee__r);
        System.assertEquals(lender_plan, builder.getRecord().Lender_Plan__r);
        System.assertEquals(lender_plan_rate, builder.getRecord().Lender_Plan_Rate__r);
        System.assertEquals(202.55, builder.getRecord().Monthly_Repayment__c);
        System.assertEquals(222.22, builder.getRecord().Commission__c);
        System.assertEquals(14.67, builder.getRecord().Apr__c);
        System.assertEquals(400, builder.getRecord().Lender_Fee_Value__c);
        System.assertEquals(2.34, builder.getRecord().TT_Fee__c);
        System.assertEquals(254.66, builder.getRecord().Solicitors_Costs__c);
        System.assertEquals(500, builder.getRecord().Title_Insurance__c);
        System.assertEquals(23.2, builder.getRecord().Interest_Rate__c);

    }

}