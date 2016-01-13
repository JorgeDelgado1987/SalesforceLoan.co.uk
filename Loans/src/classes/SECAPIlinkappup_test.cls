@isTest
// 29/01/2015 - SEC-287 - Simon PArker
private class SECAPIlinkappup_test {
	
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

        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIlinkappup';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        SECAPIlinkappup.linkapp();

        req.addParameter('username', 'fffffff');

        SECAPIlinkappup.linkapp();

        req.addParameter('username', 'fffffff');
        req.addParameter('password', 'gggggg');

        SECAPIlinkappup.linkapp();

        system.assertEquals(400, res.statusCode);

        req.addParameter('username', 'fffffff');
        req.addParameter('password', 'gggggg');
        req.addParameter('applicationid', 'asdfghjh');

        SECAPIlinkappup.linkapp();

        system.assertEquals(400, res.statusCode);

        req.addParameter('username', 'xxxx');
        req.addParameter('password', 'gggggg');
         req.addParameter('applicationid', 'asdfghjh');

        SECAPIlinkappup.linkapp();

        req.addParameter('username', 'xxxx');
        req.addParameter('password', 'yyyy');
        req.addParameter('applicationid', 'asdfghjh');

        SECAPIlinkappup.linkapp();

        system.assertEquals(400, res.statusCode);

        req.addParameter('username', 'xxxx');
        req.addParameter('password', 'yyyy');
        req.addParameter('applicationid', appl.id);

        SECAPIlinkappup.linkapp();

        system.assertEquals(201, res.statusCode);
	}
	
}