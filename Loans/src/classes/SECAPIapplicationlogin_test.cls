@isTest
// 13/10/2014 - Simon Parker
// 26/01/2015 - SEC-248 - modified to work with UserProfile - SRP
private class SECAPIapplicationlogin_test {
	
	@isTest static void test_login() {
		// setup test data

		RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();
		Account account = new Account();
        account.Name = 'First';
        insert account;

        Campaign camp = new Campaign();
        camp.Account__c = account.id;
        camp.Name = 'Test';
        insert camp;

        User_Profile__c up = new User_Profile__c();
        up.username__c = 'xxxx';
        up.password__c = 'yyyy';
        insert up;


        Application__c appl = new Application__c();
        appl.Account__c = account.id;
        appl.Campaign__c = camp.id;
        appl.Loan_Amount__c = 150000;
        appl.Application_Type__c = 'Bridging Loan';
        appl.User_Profile__c = up.id;
        
        insert appl;

        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIapplicationlogin';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        SECAPIapplicationlogin.login();

        req.addParameter('username', 'fffffff');

        SECAPIapplicationlogin.login();

        req.addParameter('username', 'fffffff');
        req.addParameter('password', 'gggggg');

        SECAPIapplicationlogin.login();

        system.assertEquals(400, res.statusCode);

        req.addParameter('username', 'xxxx');
        req.addParameter('password', 'gggggg');

        SECAPIapplicationlogin.login();

         system.assertEquals(400, res.statusCode);

        req.addParameter('username', 'xxxx');
        req.addParameter('password', 'yyyy');

        SECAPIapplicationlogin.login();

         system.assertEquals(200, res.statusCode);
	}

    @isTest static void test_login_withApplicationSummaries() {
        // setup test data

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();
        Account account = new Account();
        account.Name = 'First';
        insert account;

        Campaign camp = new Campaign();
        camp.Account__c = account.id;
        camp.Name = 'Test';
        insert camp;

        User_Profile__c up = new User_Profile__c();
        up.username__c = 'xxxx';
        up.password__c = 'yyyy';
        insert up;


        Application__c appl = new Application__c();
        appl.Account__c = account.id;
        appl.Campaign__c = camp.id;
        appl.Loan_Amount__c = 150000;
        appl.Loan_Term_Months__c = 6;
        appl.Application_Type__c = 'Bridging Loan';
        appl.User_Profile__c = up.id;
        
        insert appl;

        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIapplicationlogin';
        req.httpMethod = 'POST';

        req.addParameter('username', 'xxxx');
        req.addParameter('password', 'yyyy');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        SECAPIapplicationlogin.APPResponse response =  SECAPIapplicationlogin.login();

        Test.stopTest();

        System.Debug(response);

        System.assertEquals(1, response.ApplicationSummaries.size(),'expecting one summary to be returned');
        System.assertEquals('Success', response.Status,'expecting Success');
        System.assertEquals(6, response.ApplicationSummaries[0].LoanTerm, 'expecting 6 from value saved');

    }
	

}