@isTest
// 08/10/2014 Simon Parker
private class SECAPIgetApplication_Test {
	
	@isTest static void test_get_noapplication() {

        	RestRequest req = new RestRequest();
                RestResponse res = new RestResponse();
                
                String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();

                req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIgetApplication';
                req.httpMethod = 'POST';

                req.addParameter('ID', 'fffffff');

                RestContext.request = req;
                RestContext.response = res;

                Test.startTest();

                SECAPIgetApplication.APPResponse response = SECAPIgetApplication.AppDetails();

                Test.stopTest();

                System.assertEquals('Error',response.Status,'Expecting error response');

        }

        @isTest static void test_get_withALL() {
        
                RestRequest req = new RestRequest();
                RestResponse res = new RestResponse();
                
                String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();

                req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIgetApplication';
                req.httpMethod = 'POST';

                req.addParameter('ID', 'fffffff');
                req.addParameter('all', 'Y');

                RestContext.request = req;
                RestContext.response = res;

                Test.startTest();

                SECAPIgetApplication.APPResponse response = SECAPIgetApplication.AppDetails();

                Test.stopTest();

                System.assertEquals('Rejected',response.Status,'Expecting Rejected response');

        }

        @isTest static void test_get_withapplication() {
                // setup test data
                Application__c application = setupData();

                RestRequest req = new RestRequest();
                RestResponse res = new RestResponse();
                
                String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();

                req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIgetApplication';
                req.httpMethod = 'POST';
                req.addParameter('ID', application.id);
                req.addParameter('all', 'Y');

                RestContext.request = req;
                RestContext.response = res;

                Test.startTest();
               
                SECAPIgetApplication.APPResponse response = SECAPIgetApplication.AppDetails();

                Test.stopTest();

                System.assertEquals('Success',response.Status,'Expecting Success response');

        }

        @isTest static void test_get_withallparameters() {
                // setup test data

                Application__c application = setupData();

                RestRequest req = new RestRequest();
                RestResponse res = new RestResponse();
                
                String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();

                req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIgetApplication';
                req.httpMethod = 'POST';
                req.addParameter('ID', application.id);
                req.addParameter('APPLICANTS', 'Y');
                req.addParameter('PROPERTIES', 'Y');
                req.addParameter('MORTGAGES', 'Y');
                req.addParameter('CCJS', 'Y');
                req.addParameter('DEBTS', 'Y');
                req.addParameter('QUOTES', 'Y');
                req.addParameter('STAGEHISTORIES', 'Y');
                req.addParameter('OUTSTANDINGITEMS', 'Y');
                req.addParameter('APPLICANTINCOMES', 'Y');
                req.addParameter('DEPENDANTS', 'Y');

                RestContext.request = req;
                RestContext.response = res;

                Test.startTest();

                SECAPIgetApplication.APPResponse response = SECAPIgetApplication.AppDetails();

                Test.stopTest();

                System.assertEquals('Success',response.Status,'Expected success response');
        }

	
        private static Application__c setupData(){
                 Account account = AccountBuilder.getBuilder('Test Acc').save().getRecord();
        Campaign campaign = CampaignBuilder.getBuilder('Test')
                                .setAccount(account)
                                .save().getRecord();
        Application__c application = ApplicationBuilder.getBuilder(account)
                                .setCampaign(campaign)
                                .setLoanAmount(10000)
                                .setApplicationType('Bridging Loan')
                                .save().getRecord();

        Applicant__c applicant2 = ApplicantBuilder.getBuilder(application)
                                                 .setFirstName('Bob')
                                                 .setLastName('Turwilligar')
                                                 .setDateOfBirth(Date.newInstance(1984, 12, 1))
                                                 .setTitle('Mr')
                                                 .setPostCode('2AB 3CD')
                                                 .setMaidenName('Something')
                                                 .setEmail('bob@bob.com')
                                                 .setApplicantIndex(1)
                                                 .save().getRecord();

        Property__c property = PropertyBuilder.getBuilder(application).save().getRecord();

        Mortgage__c mortgage = MortgageBuilder.getBuilder(application).setProperty(property).save().getRecord();

        CCJ__c ccj = CCJBuilder.getBuilder(application).save().getRecord();

        Creditor__c creditor = CreditorBuilder.getBuilder().save().getRecord();

        Debt__c debt = DebtBuilder.getBuilder(application).setCreditor(creditor).save().getRecord();

        Application_Stage__c stage1 = ApplicationStageBuilder.getBuilder('Stage 1').save().getRecord();

        Stage_History__c appstage1 = StageHistoryBuilder.getBuilder(application).setApplicationStage(stage1).save().getRecord();

        Quote__c quote1 = QuoteBuilder.getBuilder(application).save().getRecord();

        Outstanding_Items__c out1 = OutstandingItemBuilder.getBuilder(application).save().getRecord();

        ApplicantIncomeBuilder applicantincome = ApplicantIncomeBuilder.getBuilder(applicant2)
                                                                        .save();

        DependantBuilder dependant = DependantBuilder.getBuilder(applicant2).save();

                return application;
        }
	
	
}