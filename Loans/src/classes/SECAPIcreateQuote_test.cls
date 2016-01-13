@isTest
private class SECAPIcreateQuote_test {
	
	@isTest static void testNoDataSent() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();
       
        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIcreateQuote';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SECAPIcreateQuote.QuoteResponse QuoteResponse = SECAPIcreateQuote.createQuote();
        Test.stopTest();

   		System.assertEquals('No valid input parameter data sent',QuoteResponse.Detail[0]);

	}
	
	@isTest static void testNoSuchApplication() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();
       
        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIcreateQuote';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Lender_Plan_Rate__c newlenderplanrate = createLenderPlanRate();
        req.addParameter('PLANRATEID', newlenderplanrate.id);
        req.addParameter('APR', '7.5');
        req.addParameter('MONTHLYREPAYMENT', '324.56');

        req.addParameter('APPLICATIONID', 'fffffff');

        Test.startTest();
        SECAPIcreateQuote.QuoteResponse QuoteResponse = SECAPIcreateQuote.createQuote();
        Test.stopTest();

   		System.assertEquals('No such Application record.',QuoteResponse.Detail[0]);
   		System.assertEquals('Rejected',QuoteResponse.Status);
	}

	@isTest static void testNoSuchLenderPlanRate() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();
       
        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIcreateQuote';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Application__c newapplication = setupData();
        req.addParameter('APPLICATIONID', newapplication.id);
        req.addParameter('PLANRATEID', 'gggggg');
        req.addParameter('APR', '7.5');
        req.addParameter('MONTHLYREPAYMENT', '324.56');

        Test.startTest();
        SECAPIcreateQuote.QuoteResponse QuoteResponse = SECAPIcreateQuote.createQuote();
        Test.stopTest();

   		System.assertEquals('No such Lender Plan Rate record.',QuoteResponse.Detail[0]);
   		System.assertEquals('Rejected',QuoteResponse.Status);
	}

	@isTest static void testcreateQuote() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();
       
        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIcreateQuote';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Application__c newapplication = setupData();
        Lender_Plan_Rate__c newlenderplanrate = createLenderPlanRate();
        req.addParameter('APPLICATIONID', newapplication.id);
        req.addParameter('PLANRATEID', newlenderplanrate.id);
        req.addParameter('APR', '7.5');
        req.addParameter('MONTHLYREPAYMENT', '324.56');

        Test.startTest();
        SECAPIcreateQuote.QuoteResponse QuoteResponse = SECAPIcreateQuote.createQuote();
        Test.stopTest();

  
   		System.assertEquals('Success',QuoteResponse.Status);
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