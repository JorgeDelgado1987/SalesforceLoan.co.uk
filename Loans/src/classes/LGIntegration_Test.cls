@isTest
public class LGIntegration_Test {

    @isTest static void testInitializationWithGoodData() {
        HttpMockHandler.addMock(getMockResponse());
        Application__c application = setupData();
        Test.startTest();
            LGIntegration.LenderExchangeResult result = LGIntegration.executeLenderExchange(SecuredLoansIntegrationModels.getAllApplicationData(application.Id),'Mock');
        Test.stopTest();
        System.assertEquals(true, result.Errors.isEmpty());
        System.assertEquals(true, result.Messages.isEmpty());
        System.assertEquals(true, result.IsSuccessful);
        System.assertNotEquals(null, result.Documents);
        System.assertEquals(1, result.Documents.size());
        System.assertNotEquals(null, result.ProductsOffered);
        System.assertEquals(1, result.ProductsOffered.size());
    }

    @isTest static void testWithExceptionMessage(){
        HttpMockHandler.addMock(getExceptionResponse());
        Application__c application = setupData();
        Test.startTest();
            LGIntegration.LenderExchangeResult result = LGIntegration.executeLenderExchange(SecuredLoansIntegrationModels.getAllApplicationData(application.Id),'Mock');
        Test.stopTest();
        System.assertEquals(false, result.IsSuccessful);
        System.assertEquals(1, result.getMessages(LGIntegration.MessageType.ERROR).size());
    }

    @isTest static void testSuccessResultWithMessages(){
        HttpMockHandler.addMock(getSuccessWithErrorMockResponse());
        Application__c application = setupData();
        Test.startTest();
            LGIntegration.LenderExchangeResult result = LGIntegration.executeLenderExchange(SecuredLoansIntegrationModels.getAllApplicationData(application.Id),'Mock');
        Test.stopTest();
        System.assertEquals(true, result.IsSuccessful);
        System.assertEquals(6, result.Errors.size());
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

    public static HttpHandler.HttpHandlerResponse getMockResponse(){
        HttpResponse response = new HttpResponse();
        response.setBody(getMockBody());
        response.setStatusCode(200);
        return new HttpHandler.HttpHandlerResponse(response);
    }

    private static String getMockBody(){
        return '{\"RawResult\":\"RawResult\",\"IsSuccessful\":true,\"Documents\":[{\"Name\":\"Extra Papers to Sign\",\"IsRequired\":true,\"ReferenceCode\":\"DOC-2232\"}],\"ProductsOffered\":[{\"Name\":\"Big Bad Wolf Loan\",\"Code\":\"123\",\"InterestRate\":3.24,\"ReversionRate\":15.0,\"MonthlyRepayment\":850.0}],\"Errors\":null}';
    }

    public static HttpHandler.HttpHandlerResponse getSuccessWithErrorMockResponse(){
        HttpResponse response = new HttpResponse();
        response.setBody(getSuccessWithErrorMockBody());
        response.setStatusCode(200);
        return new HttpHandler.HttpHandlerResponse(response);
    }

    private static String getSuccessWithErrorMockBody(){
        return '{\"Type\": \"LenderExchangeResult\",\"ReferenceId\": \"a09U000000iUDUkIAO\",\"RawResult\": \"[truncated]\",\"IsSuccessful\": true,\"Documents\": [ ],\"ProductsOffered\": [ ],\"Errors\": [\"Income below plan minimum\",\"Property valuation below plan minimum\",\"Credit score below plan minimum\",\"CCJ/Defaults exceed plan maximum\",\"Mortgage history below plan minimum\",\"Arrangement on unsecured credit\"],\"LenderReferenceId\": \"30002735\",\"Id\": \"4dd21c5a-e03b-4cb6-8af3-b028d7a8c9be\"}';
    }

    public static HttpHandler.HttpHandlerResponse getExceptionResponse(){
        return new HttpHandler.HttpHandlerResponse(new TestException('A message'));
    }

    public class TestException extends Exception{}
}