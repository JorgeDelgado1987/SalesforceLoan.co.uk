@isTest
private class UnderwritingWizardController_Test {

    @isTest static void test_Constructor_UnderwritingWizardcontroller_SetsPropertiesUp() {
        Test.setCurrentPage(Page.UnderwritingWizard);
        Test.startTest();
            UnderwritingWizardController controller = new UnderwritingWizardController(new ApexPages.StandardController(getTestApp().getRecord()));
        Test.stopTest();
        System.assertEquals(null, controller.DownSellPlans);
        System.assertEquals(null, controller.PassedPlans);
        System.assertEquals(null, controller.ManualReferralPlans);
        System.assertEquals(null, controller.FailedPlans);
        System.assertEquals(null, controller.Summary);
        System.assertEquals(false, controller.getHasActiveQuote(), 'No quote attached to application so should be false');
        System.assertEquals(null, controller.getExistingActiveQuote(), 'No active quote was created so should be null');
        System.assertEquals(false, controller.getShowResults(), 'Show results should be false as not submitted to DE yet');
    }

    @isTest static void test_method_UnderwritingWizardcontroller_submitToDecisionEngine_vaidationFailsWhenLoanAmountis0() {
        HttpMockHandler.addSuccessfulMock(DecisionEngineIntegration.getBaseDecisionMock());
        Test.setCurrentPage(Page.UnderwritingWizard);
        UnderwritingWizardController controller = new UnderwritingWizardController(new ApexPages.StandardController(getTestApp().getRecord()));
        Test.startTest();
            controller.submitToDecisionEngine();
        Test.stopTest();
        System.assert(ApexPages.hasMessages(Apexpages.Severity.ERROR), 'An Error should be present as no ammount was set');
    }

    @isTest static void test_method_UnderwritingWizardcontroller_submitToDecisionEngine_vaidationFailsWhenLoanAmountSetButPropertyValueIs0() {
        HttpMockHandler.addSuccessfulMock(DecisionEngineIntegration.getBaseDecisionMock());
        Application__c test_app = getTestApp().setLoanAmount(10000).save().getRecord();
        Test.setCurrentPage(Page.UnderwritingWizard);
        UnderwritingWizardController controller = new UnderwritingWizardController(new ApexPages.StandardController(test_app));
        Test.startTest();
            controller.submitToDecisionEngine();
        Test.stopTest();
        System.assert(ApexPages.hasMessages(Apexpages.Severity.ERROR), 'An Error should be present no property is included');
    }

    @isTest static void test_method_UnderwritingWizardcontroller_submitToDecisionEngine_shouldSubmitWithValidValues() {
        HttpMockHandler.addSuccessfulMock(DecisionEngineIntegration.getBaseDecisionMock());
        Application__c test_app = getTestApp().setLoanAmount(10000).save().getRecord();
        PropertyBuilder.getBuilder(test_app).setEstimatedValue(123000).save();
        Test.setCurrentPage(Page.UnderwritingWizard);
        UnderwritingWizardController controller = new UnderwritingWizardController(new ApexPages.StandardController(test_app));
        Test.startTest();
            controller.submitToDecisionEngine();
        Test.stopTest();
        System.assertNotEquals(null, controller.DownSellPlans);
        System.assertNotEquals(null, controller.PassedPlans);
        System.assertNotEquals(null, controller.ManualReferralPlans);
        System.assertNotEquals(null, controller.FailedPlans);
        System.assertNotEquals(null, controller.Summary);
        System.assertEquals(true, controller.getShowResults(), 'Show results should be false as not submitted to DE yet');
    }

    @isTest static void test_Constructor_PlanRow_NullPointersDontHappenInPlanRowWithNullBasePlan(){
        DecisionEngineIntegration.Plan plan = new DecisionEngineIntegration.Plan();
        Test.startTest();
            UnderwritingWizardController.PlanRow row = new UnderwritingWizardController.PlanRow(plan);
        Test.stopTest();
        System.assertEquals(null,row.getLenderId());
        System.assertEquals(null,row.getPlanId());
        System.assertEquals('Unknown Lender',row.getLenderName());
        System.assertEquals('Plan Name Not Provided',row.getPlanName());
        System.assertEquals(0,row.getPlanCommission());
        System.assertEquals(null,row.getPlanRateId());
        System.assertEquals(0,row.getRate());
        System.assertEquals('Not Provided',row.getRateType());
        System.assertEquals(0,row.getLenderFee());
        System.assertEquals(0,row.getMaxLtv());
        System.assertEquals(0,row.getLtv());
        System.assertEquals(0,row.getMonthlyRate());
        System.assertEquals(0,row.getAnnualEquivalentRate());
        System.assertEquals(0,row.getDailyRate());
        System.assertEquals('Not Provided',row.getPaymentType());
        System.assertEquals(0,row.getMonthlyPaymentEstimate());
        System.assertEquals(0,row.getDti());
        System.assertEquals(0,row.getApr());
        System.assertEquals(0,row.getOneFourthRedemption());
        System.assertEquals(0,row.getTwoFourthRedemption());
        System.assertEquals(0,row.getThreeFourthRedemption());
        System.assertEquals(0,row.getTotalRepayable());
        System.assertEquals(0,row.getTotalInterest());
        System.assertEquals(0,row.getMaxAvailableLoanAmount());
        System.assertEquals('',row.getFormattedFailures());
    }

    @isTest static void test_Constructor_PlanRow_methodsReturnCorrectValuesFromResponseObject(){
        DecisionEngineIntegration.RepaymentOption repay_option = getRepayOption();
        DecisionEngineIntegration.PlanRate plan_rate = getPlanRate(repay_option);
        DecisionEngineIntegration.PlanSummary summary = getPlanSummary();
        DecisionEngineIntegration.Plan plan = getPlan(plan_rate, summary);
        Test.startTest();
            UnderwritingWizardController.PlanRow row = new UnderwritingWizardController.PlanRow(plan);
        Test.stopTest();
        System.assertEquals('a0GJ000000G3aSM',row.getLenderId());
        System.assertEquals('a0gU00000095SR6IAM',row.getPlanId());
        System.assertEquals('lender',row.getLenderName());
        System.assertEquals('plan_name',row.getPlanName());
        System.assertEquals(2,row.getPlanCommission());
        System.assertEquals('a0gU00000095SR6IAM',row.getPlanRateId());
        System.assertEquals(24.5,row.getRate());
        System.assertEquals('Variable',row.getRateType());
        System.assertEquals(4500,row.getLenderFee());
        System.assertEquals(65,row.getMaxLtv());
        System.assertEquals(12.3,row.getLtv());
        System.assertEquals(22.4,row.getMonthlyRate());
        System.assertEquals(3000,row.getAnnualEquivalentRate());
        System.assertEquals(12.3,row.getDailyRate());
        System.assertEquals('Principle',row.getPaymentType());
        System.assertEquals(230.50,row.getMonthlyPaymentEstimate());
        System.assertEquals(2.34,row.getDti());
        System.assertEquals(5.76,row.getApr());
        System.assertEquals(1400,row.getOneFourthRedemption());
        System.assertEquals(2400,row.getTwoFourthRedemption());
        System.assertEquals(3400,row.getThreeFourthRedemption());
        System.assertEquals(5500,row.getTotalRepayable());
        System.assertEquals(2000,row.getTotalInterest());
        System.assertEquals(10000,row.getMaxAvailableLoanAmount());
        System.assertEquals('',row.getFormattedFailures());
    }

    @isTest static void test_Constructor_PlanDisplay_methodsReturnCorrectValuesFromResponseObject(){
        DecisionEngineIntegration.RepaymentOption repay_option = getRepayOption();
        DecisionEngineIntegration.PlanRate plan_rate = getPlanRate(repay_option);
        DecisionEngineIntegration.PlanSummary summary = getPlanSummary();
        DecisionEngineIntegration.Plan plan = getPlan(plan_rate, summary);
        List<DecisionEngineIntegration.BasePlan> plans_list = new List<DecisionEngineIntegration.BasePlan>();
        plans_list.add(plan);
        Test.startTest();
            UnderwritingWizardController.PlanDisplay plan_display = new UnderwritingWizardController.PlanDisplay(plans_list);
        Test.stopTest();
        System.assertEquals(2,plan_display.LenderOptions.size());
        System.assertEquals(1,plan_display.Plans.size());
        System.assertEquals(null,plan_display.SelectedLender);
    }

    @isTest static void test_method_PlanDisplay_filterRows_methodFiltersPlanRowsToCorrectLenders(){
        DecisionEngineIntegration.RepaymentOption repay_option = getRepayOption();
        DecisionEngineIntegration.PlanRate plan_rate = getPlanRate(repay_option);
        DecisionEngineIntegration.PlanSummary summary = getPlanSummary();
        DecisionEngineIntegration.Plan plan = getPlan(plan_rate, summary);
        DecisionEngineIntegration.Plan plan_lender_2 = getPlan(plan_rate, summary);
        plan_lender_2.LenderName = 'Lender_2';
        List<DecisionEngineIntegration.BasePlan> plans_list = new List<DecisionEngineIntegration.BasePlan>();
        plans_list.add(plan);
        plans_list.add(plan_lender_2);
        UnderwritingWizardController.PlanDisplay plan_display = new UnderwritingWizardController.PlanDisplay(plans_list);
        Test.startTest();
            plan_display.SelectedLender = 'Lender_2';
            plan_display.filterRows();
        Test.stopTest();
        System.assertEquals(3,plan_display.LenderOptions.size());
        System.assertEquals(1,plan_display.Plans.size());
        System.assertEquals('Lender_2', plan_display.Plans.get(0).getLenderName());
    }

    static testMethod void testBestPlanOnlyIsDisplayedByDefault(){
        DecisionEngineIntegration.PlanRate plan_rate = getPlanRate(getRepayOption());
        DecisionEngineIntegration.PlanSummary summary = getPlanSummary();
        List<DecisionEngineIntegration.BasePlan> plans_list = new List<DecisionEngineIntegration.BasePlan>();
        for(Integer i=0; i<10; i++){
            plans_list.add(getPlan(plan_rate, summary));
        }
        UnderwritingWizardController.PlanDisplay plan_display = new UnderwritingWizardController.PlanDisplay(plans_list, true);
        Test.startTest();
            plan_display.filterRows();
        Test.stopTest();
        System.assertEquals(1, plan_display.Plans.size());
    }


    public static DecisionEngineIntegration.Plan getPlan(DecisionEngineIntegration.PlanRate plan_rate, DecisionEngineIntegration.PlanSummary summary){
        DecisionEngineIntegration.Plan plan = new DecisionEngineIntegration.Plan();
        plan.BestRate = plan_rate;
        plan.PlanCommission = 2;
        plan.SfLenderId = 'a0GJ000000G3aSM';
        plan.SfPlanId = 'a0gU00000095SR6IAM';
        plan.LenderName = 'lender';
        plan.PlanName = 'plan_name';
        plan.Summary = summary;
        return plan;
    }

    private static DecisionEngineIntegration.PlanSummary getPlanSummary(){
        DecisionEngineIntegration.PlanSummary summary = new DecisionEngineIntegration.PlanSummary();
        summary.TotalRatesCount = 10;
        summary.PassedRatesCount = 1;
        summary.ManualReferralCount = 1;
        summary.DownSellCount = 1;
        summary.FailedCount = 7;
        return summary;
    }

    private static DecisionEngineIntegration.RepaymentOption getRepayOption(){
        DecisionEngineIntegration.RepaymentOption repay_option = new DecisionEngineIntegration.RepaymentOption();
        repay_option.RepaymentType = 'Principle';
        repay_option.MonthlyPaymentEstimate = 230.50;
        repay_option.Dti = 2.34;
        repay_option.Apr = 5.76;
        repay_option.OneFourthRedemption = 1400;
        repay_option.TwoFourthRedemption = 2400;
        repay_option.ThreeFourthRedemption = 3400;
        repay_option.TotalRepayable = 5500;
        repay_option.TotalInterest = 2000;
        repay_option.MaxAvailableLoanAmount = 10000;
        return repay_option;
    }

    private static DecisionEngineIntegration.PlanRate getPlanRate(DecisionEngineIntegration.RepaymentOption repay_option){
        DecisionEngineIntegration.PlanRate plan_rate = new DecisionEngineIntegration.PlanRate();
        plan_rate.SfPlanRateId = 'a0gU00000095SR6IAM';
        plan_rate.RateType = 'Variable';
        plan_rate.Rate = 24.5;
        plan_rate.LenderFee = 4500;
        plan_rate.MaxLtv = 65;
        plan_rate.Ltv = 12.3;
        plan_rate.MonthlyRate = 22.4;
        plan_rate.AnnualEquivalentRate = 3000;
        plan_rate.DailyRate = 12.3;
        plan_rate.BestRepaymentOption = repay_option;
        return plan_rate;
    }

    private static ApplicationBuilder getTestApp(){
        return ApplicationBuilder.getBuilder(
                    AccountBuilder.getBuilder('BobsLoans')
                    .save()
                    .getRecord())
                        .save();
    }

}