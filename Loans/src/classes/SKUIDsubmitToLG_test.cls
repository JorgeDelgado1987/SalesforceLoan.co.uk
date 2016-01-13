@isTest
private class SKUIDsubmitToLG_test {
	
	@isTest static void successresponse_test() {
		HttpMockHandler.addMock(LgIntegration_Test.getMockResponse());
        Application__c application = setupBaseData();
        Lender__c lender = setLenderToTest();

        
        Test.startTest();
            
        String result = SKUIDsubmitToLG.submit(application.id, lender.Integration_Name__c);

        Test.stopTest();

        System.assertEquals('Success: New Quote created.',result,'Expecting success message');
        
	}

	@isTest static void failureresponse_test() {
		HttpMockHandler.addMock(LgIntegration_Test.getSuccessWithErrorMockResponse());
        Application__c application = setupBaseData();
        Lender__c lender = setLenderToTest();

        
        Test.startTest();
            
        String result = SKUIDsubmitToLG.submit(application.id, lender.Integration_Name__c);

        Test.stopTest();

        System.assertEquals('The following Errors Occurred',result.substring(0,29),'Expecting error message');
        
	}

	
	

	private static Lender__c setLenderToTest(){
        Lender__c lender = LenderBuilder.getBuilder('Test')
                                            .setIntegrationName('Test')
                                            .setIsIntegrated(true)
                                            .save()
                                            .getRecord();

        

        return lender;
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