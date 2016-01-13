@isTest

//03/02/2015 Simon Parker
private class SECAPIsubmittoDE_test {

    @isTest static void testNoDataSent() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();

        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIsubmittoDE';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SECAPIsubmittoDE.DEResponse DEres = SECAPIsubmittoDE.getAcceptedPlanRates();
        Test.stopTest();

        System.assertEquals('No valid input parameter data sent',DEres.Detail[0]);

    }

    @isTest static void testNoSuchApplication() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();

        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIsubmittoDE';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        req.addParameter('ID', 'fffffff');

        Test.startTest();
        SECAPIsubmittoDE.DEResponse DEres = SECAPIsubmittoDE.getAcceptedPlanRates();
        Test.stopTest();

        System.assertEquals('No such Application record.', DEres.Detail[0]);
        System.assertEquals('Rejected', DEres.Status);
    }

    @isTest static void testwithApplication() {
        HttpMockHandler.addSuccessfulMock(DecisionEngineIntegration_Test.getMockBody());
        Application__c application = setupData();
        Lender_Plan_Rate__c lender_plan_rate = createLenderPlanRate();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();

        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIsubmittoDE';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        req.addParameter('ID', application.id);

        Test.startTest();
        SECAPIsubmittoDE.DEResponse DEres = SECAPIsubmittoDE.getAcceptedPlanRates();
        Test.stopTest();

        System.assertEquals('Success', DEres.Status);
        System.assertEquals(18, DEres.AcceptedCount);
        System.assertEquals(68, DEres.AcceptedPlans.size());
    }

    private static Lender_Plan_Rate__c createLenderPlanRate(){
        Lender__c lender = new Lender__c();
        lender.Active__c = true;
        insert lender;
        Lender_Plan__c lender_plan = new Lender_Plan__c();
        lender_plan.Active__c = true;
        lender_plan.Lender__c = lender.Id;
        insert lender_plan;
        Lender_Plan_Rate__c lender_plan_rate = new Lender_Plan_Rate__c();
        lender_plan_rate.Lender_Plan__c = lender_plan.Id;
        lender_plan_rate.Lender_Fee__c = 20;
        lender_plan_rate.Rate__c = 2.4;
        insert lender_plan_rate;
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

}