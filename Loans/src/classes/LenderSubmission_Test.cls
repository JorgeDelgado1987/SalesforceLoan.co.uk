@isTest
public class LenderSubmission_Test {

    @isTest static void testBasicHappyPathSubmitToLG() {
        HttpMockHandler.addMock(LgIntegration_Test.getMockResponse());
        Application__c application = setLenderToTest(setupBaseData());
        LenderSubmission controller = new LenderSubmission(new ApexPages.StandardController(application));
        PageReference current_page = Page.LenderSubmission;
        current_page.getParameters().put('id', application.Id);
        Test.setCurrentPage(current_page);
        Test.startTest();
            controller.SelectedLenderOptions = new List<SelectOption>{new SelectOption('Test', 'Test')};
            controller.submitToLenderGateway();
        Test.stopTest();
        System.assertEquals(1, controller.ActiveQuotes.size());
        System.assertEquals(1, controller.Documents.size());
        System.assertEquals(1, controller.ProductRows.size());
        System.assertEquals(true, controller.CanSubmitToLender);
        System.assertEquals(false, controller.ProductSelected);
        System.assertEquals(true, controller.getShowResults());
        System.assertEquals(true, controller.getHasQuote());
        System.assertEquals(false, ApexPages.hasMessages());
    }

    @isTest static void testBasicHappyPathSelectFirstProduct() {
        HttpMockHandler.addMock(LgIntegration_Test.getMockResponse());
        Application__c application = setLenderToTest(setupBaseData());
        LenderSubmission controller = new LenderSubmission(new ApexPages.StandardController(application));
        PageReference current_page = Page.LenderSubmission;
        current_page.getParameters().put('id', application.Id);
        Test.setCurrentPage(current_page);
        controller.SelectedLenderOptions = new List<SelectOption>{new SelectOption('Test', 'Test')};
        controller.submitToLenderGateway();
        Test.startTest();
            controller.ProductRows.get(0).selectProduct();
        Test.stopTest();
        System.assertEquals(1, controller.ActiveQuotes.size());
        System.assertEquals(1, controller.Documents.size());
        System.assertEquals(1, controller.ProductRows.size());
        System.assertEquals(true, controller.CanSubmitToLender);
        System.assertEquals(true, controller.ProductSelected);
        System.assertEquals(true, controller.getShowResults());
        System.assertEquals(true, controller.getHasQuote());
        System.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.CONFIRM));
    }

    @isTest static void testShawbrookHandling() {
        HttpMockHandler.addMock(getShawbrookMock());
        Application__c application = setLenderToShawbrook(setupBaseData());
        LenderSubmission controller = new LenderSubmission(new ApexPages.StandardController(application));
        PageReference current_page = Page.LenderSubmission;
        current_page.getParameters().put('id', application.Id);
        Test.setCurrentPage(current_page);
        Test.startTest();
            controller.SelectedLenderOptions = new List<SelectOption>{new SelectOption('Shawbrook', 'Shawbrook')};
            controller.submitToLenderGateway();
        Test.stopTest();
        System.assertEquals(1, controller.ActiveQuotes.size());
        System.assertEquals(0, controller.Documents.size());
        System.assertEquals(null, controller.ProductRows);
        System.assertEquals(true, controller.CanSubmitToLender);
        System.assertEquals(false, controller.ProductSelected);
        System.assertEquals(false, controller.getShowResults());
        System.assertEquals(true, controller.getHasQuote());
        System.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.INFO));
    }

    static testMethod void testLenderSubmissionLogRecordIsCreatedWithExpectedData() {
        HttpMockHandler.addMock(getShawbrookMock());
        Application__c application = setLenderToShawbrook(setupBaseData());
        LenderSubmission controller = new LenderSubmission(new ApexPages.StandardController(application));
        PageReference current_page = Page.LenderSubmission;
        current_page.getParameters().put('id', application.Id);
        Test.setCurrentPage(current_page);
        Test.startTest();
            controller.SelectedLenderOptions = new List<SelectOption>{new SelectOption('Shawbrook', 'Shawbrook')};
            controller.submitToLenderGateway();
        Test.stopTest();
        List<Lender_Submission_Log__c> logs = [SELECT Application__c, Quote__c, Lender__c, Is_Successful__c, Submission_Id__c, Lender_Response__c, Lender_Reference_Id__c FROM Lender_Submission_Log__c];
        System.assertEquals(1, logs.size());
        System.assertEquals(application.Id, logs.get(0).Application__c);
        System.assertEquals(controller.ActiveQuotes.get(0).Id, logs.get(0).Quote__c);
        System.assertEquals(controller.ActiveQuotes.get(0).Lender_Fee__c, logs.get(0).Lender__c);
        System.assertEquals(controller.LatestLenderExchangeResult.IsSuccessful, logs.get(0).Is_Successful__c);
        System.assertEquals(controller.LatestLenderExchangeResult.Id, logs.get(0).Submission_Id__c);
        System.assertEquals(controller.LatestLenderExchangeResult.LenderReferenceId, logs.get(0).Lender_Reference_Id__c);
        String formatted_messages = controller.formatPageMessages().replace('<br/>' + controller.LatestLenderExchangeResult.Id, '').replace('<br />', '<br>');
        System.assertEquals(formatted_messages, logs.get(0).Lender_Response__c);
    }

    private static Application__c setLenderToShawbrook(Application__c application){
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

        Quote__c quote = QuoteBuilder.getBuilder(application)
                                        .setBrokerFee(200)
                                        .setLender(lender)
                                        .setLenderPlan(lender_plan)
                                        .setLenderPlanRate(lender_plan_rate)
                                        .setMonthlyRepayment(522.63)
                                        .setCommission(123.5)
                                        .setApr(12.1)
                                        .setLenderFee(220)
                                        .setTTFee(99)
                                        .setSolicitorsCosts(2200)
                                        .setTitleInsurance(180)
                                        .setInterestRate(18.9)
                                        .save()
                                        .getRecord();

        return application;
    }

    private static Application__c setLenderToTest(Application__c application){
        Lender__c lender = LenderBuilder.getBuilder('Test')
                                            .setIntegrationName('Test')
                                            .setIsIntegrated(true)
                                            .save()
                                            .getRecord();

        Lender_Plan__c lender_plan = LenderPlanBuilder.getBuilder(lender)
                                                        .save()
                                                        .getRecord();

        Lender_Plan_Rate__c lender_plan_rate = LenderPlanRateBuilder.getBuilder(lender_plan)
                                                        .save()
                                                        .getRecord();

        Quote__c quote = QuoteBuilder.getBuilder(application)
                                        .setBrokerFee(200)
                                        .setLender(lender)
                                        .setLenderPlan(lender_plan)
                                        .setLenderPlanRate(lender_plan_rate)
                                        .setMonthlyRepayment(522.63)
                                        .setCommission(123.5)
                                        .setApr(12.1)
                                        .setLenderFee(220)
                                        .setTTFee(99)
                                        .setSolicitorsCosts(2200)
                                        .setTitleInsurance(180)
                                        .setInterestRate(18.9)
                                        .save()
                                        .getRecord();

        return application;
    }

    private static Application__c setupBaseData(){
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
                                                            .setBrokerFee(500)
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

        Creditor__c creditor = CreditorBuilder.getBuilder()
                                                .save()
                                                .getRecord();

        Debt__c debt = DebtBuilder.getBuilder(application)
                                    .setCreditor(creditor)
                                    .setDateAccountOpened(Date.newInstance(2011, 5, 23))
                                    .save()
                                    .getRecord();
        return application;
    }

    public static HttpHandler.HttpHandlerResponse getShawbrookMock(){
        HttpResponse response = new HttpResponse();
        response.setBody(getShawbrookMockBody());
        response.setStatusCode(200);
        return new HttpHandler.HttpHandlerResponse(response);
    }

    private static String getShawbrookMockBody(){
        return '{\"Type\":\"LenderExchangeResult\",\"ReferenceId\":\"a09J000000CsFp5IAF\",\"RawResult\":\"[truncated]\",\"IsSuccessful\":true,\"Documents\":[],\"ProductsOffered\":[],\"Errors\":[\"Secured arrears\",\"Income below plan minimum\",\"Property valuation below plan minimum\",\"Credit score below plan minimum\"],\"LenderReferenceId\":\"30002699\",\"Id\":\"a9631b1e-fcc0-4c38-b426-78db45cd6287\"}';
    }

}