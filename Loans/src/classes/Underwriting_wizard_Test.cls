@isTest

private class Underwriting_wizard_Test {
    static Underwriting_wizard controller;

    @isTest static void testInitializationSetsUpAllValues() {
        Application__c application = setupData();
        PageReference pageRef = Page.Underwriting_wizard;
        pageRef.getParameters().put('id',application.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
            controller = new Underwriting_wizard(new ApexPages.StandardController(application));
        Test.stopTest();
        System.assertEquals(false, controller.getShowResults());
        System.assertEquals(false, controller.getHasActiveQuote());
        System.assertEquals(null, controller.getExistingActiveQuote());
    }

    @isTest static void testSubmitToDePopulatesDataCorrectly() {
        HttpMockHandler.addSuccessfulMock(DecisionEngineIntegration_Test.getMockBody());
        Application__c application = setupData();
        PageReference pageRef = Page.Underwriting_wizard;
        pageRef.getParameters().put('id',application.Id);
        Test.setCurrentPage(pageRef);
        controller = new Underwriting_wizard(new ApexPages.StandardController(application));
        Test.startTest();
            controller.submitToDecisionEngine();
        Test.stopTest();
        System.assertEquals(18, controller.Summary.PassedCount);
        System.assertEquals(0, controller.Summary.ManualReferralCount);
        System.assertEquals(23, controller.Summary.PlanLevelFailedCount);
        System.assertEquals(140, controller.Summary.RateLevelFailedCount);
        System.assertEquals(0, controller.Summary.RepaymentOptionLevelFailedCount);
    }

    @isTest static void testGoToCreditSearch() {
        Application__c application = setupData();
        PageReference pageRef = Page.Underwriting_wizard;
        pageRef.getParameters().put('id',application.Id);
        Test.setCurrentPage(pageRef);
        controller = new Underwriting_wizard(new ApexPages.StandardController(application));
        Test.startTest();
            PageReference page_ref = controller.goToCreditSearch();
        Test.stopTest();
        System.assert(page_ref.getUrl().toLowerCase().contains('creditsearch'));
    }

    @isTest static void testGoToLenderSubmission() {
        Application__c application = setupData();
        PageReference pageRef = Page.Underwriting_wizard;
        pageRef.getParameters().put('id',application.Id);
        Test.setCurrentPage(pageRef);
        controller = new Underwriting_wizard(new ApexPages.StandardController(application));
        Test.startTest();
            PageReference page_ref = controller.goToLenderSubmission();
        Test.stopTest();
        System.assert(page_ref.getUrl().toLowerCase().contains('lendersubmission'));
    }

    @isTest static void testHasActiveQuoteReturnsTrueForActiveQuote(){
        Application__c application = addQuoteToApplication(setupData());
        PageReference pageRef = Page.Underwriting_wizard;
        pageRef.getParameters().put('id',application.Id);
        Test.setCurrentPage(pageRef);
        controller = new Underwriting_wizard(new ApexPages.StandardController(application));
        Test.startTest();
            Boolean has_quote = controller.getHasActiveQuote();
        Test.stopTest();
        System.assertEquals(true, has_quote, 'Active quote should have been set to true');
    }

    private static Lender_Plan_Rate__c createLenderPlanRate(){
        Lender__c lender = LenderBuilder.getBuilder('Test')
                                            .setIsIntegrated(true)
                                            .setIntegrationName('Shawbrook')
                                            .save()
                                            .getRecord();

        Lender_Plan__c lender_plan = LenderPlanBuilder.getBuilder(lender)
                                                        .save()
                                                        .getRecord();

        Lender_Plan_Rate__c lender_plan_rate = LenderPlanRateBuilder.getBuilder(lender_plan)
                                                        .save()
                                                        .getRecord();
        return lender_plan_rate;
    }

    private static Application__c setupData(){
        Account account = AccountBuilder.getBuilder('Test')
                                            .save()
                                            .getRecord();
        Campaign campaign = CampaignBuilder.getBuilder('Campaign 1')
                                            .setAccount(account)
                                            .save()
                                            .getRecord();
        Application__c application  = ApplicationBuilder.getBuilder(account)
                                                            .setCampaign(campaign)
                                                            .setLoanAmount(150000)
                                                            .setApplicationType('Bridging Loan')
                                                            .setLoanTermMonths(60)
                                                            .save()
                                                            .getRecord();
        Applicant__c applicant = ApplicantBuilder.getBuilder(application)
                                                    .setFirstName('Bob')
                                                    .setLastName('Turwillicgar')
                                                    .setEmail('bob@example.com')
                                                    .setMobilePhone('0777775555')
                                                    .setDateOfBirth(Date.newInstance(1981,2,2))
                                                    .setTimeInEmploymentMonths(4)
                                                    .setTimeInEmploymentYears(5)
                                                    .setTimeWithPreviousEmployerMonths(2)
                                                    .setTimeWithPreviousEmployerYears(2)
                                                    .setIsPrimary(true)
                                                    .save()
                                                    .getRecord();

        Property__c property = PropertyBuilder.getBuilder(application)
                                                .setDateMovedIn(Date.newInstance(2011, 2, 22))
                                                .setDateMovedOut(Date.newInstance(2013, 2, 22))
                                                .setPurchaseDate(Date.newInstance(2013, 3, 22))
                                                .setSecurityAddress(true)
                                                .setEstimatedValue(200000)
                                                .save()
                                                .getRecord();

        Mortgage__c mortgage = MortgageBuilder.getBuilder(application)
                                                .setOnSecurityAddress(true)
                                                .setProperty(property)
                                                .setMortgageStartDate(Date.newInstance(2011, 2, 9))
                                                .save()
                                                .getRecord();


        CCJ__c ccj = CCJBuilder.getBuilder(application)
                                .setJudgementDate(Date.newInstance(1999, 2, 9))
                                .setApplicant(applicant)
                                .save()
                                .getRecord();

        Creditor__c creditor = CreditorBuilder.getBuilder().save().getRecord();

        Debt__c debt = DebtBuilder.getBuilder(application)
                                    .setCreditor(creditor)
                                    .setDateAccountOpened(Date.newInstance(2011, 5, 23))
                                    .save()
                                    .getRecord();

        return application;
    }

    private static Application__c addQuoteToApplication(Application__c application){
        Lender_Plan_Rate__c lender_plan_rate = createLenderPlanRate();
        Quote__c quote = QuoteBuilder.getBuilder(application)
                                .setBrokerFee(application.Broker_Fee__c)
                                .setLender(lender_plan_rate.Lender_Plan__r.Lender__c)
                                .setLenderPlan(lender_plan_rate.Lender_Plan__c)
                                .setLenderPlanRate(lender_plan_rate.Id)
                                .setMonthlyRepayment(200.54)
                                .setCommission(500)
                                .setApr(19.5)
                                .setLenderFee(2200)
                                .setTTFee(500)
                                .setSolicitorsCosts(800)
                                .setTitleInsurance(2200)
                                .setInterestRate(8.54)
                                .save()
                                .getRecord();
        return application;
    }
}