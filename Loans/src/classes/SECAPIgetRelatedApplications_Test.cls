@isTest
// 09/10/2014 - Simon Parker
private class SECAPIgetRelatedApplications_Test {
	
	@isTest static void test_get1() {
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

        Application__c appl = new Application__c();
        appl.Account__c = account.id;
        appl.Campaign__c = camp.id;
        appl.Loan_Amount__c = 150000;
        appl.Application_Type__c = 'Bridging Loan';

        insert appl;

        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIgetRelatedApplications';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        SECAPIgetRelatedApplications.AppDetails();

        req.addParameter('ID', 'fffffff');

        SECAPIgetRelatedApplications.AppDetails();

        req.addParameter('ID', account.id);

        SECAPIgetRelatedApplications.AppDetails();
	}
@isTest static void test_get2() {
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

        Application__c appl = new Application__c();
        appl.Account__c = account.id;
        appl.Campaign__c = camp.id;
        appl.Loan_Amount__c = 150000;
        appl.Application_Type__c = 'Bridging Loan';

        insert appl;

        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIgetRelatedApplications';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        req.addParameter('ID', account.id);

        SECAPIgetRelatedApplications.AppDetails();
	}

}