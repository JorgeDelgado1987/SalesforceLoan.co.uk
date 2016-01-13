@isTest
// 10/10/2014 Simon Parker
private class SECAPIbrokerlogin_Test {
	
	@isTest static void test_login() {
		// setup test data

		RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();
		Account account = new Account();
        account.Name = 'First';
        insert account;

        Contact contact = new Contact();
        contact.AccountId = account.id;
        contact.username__c = 'xxxx';
        contact.password__c = 'yyyy';
        contact.lastname = 'jones';
        insert contact;

        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIbrokerlogin';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        SECAPIbrokerlogin.login();

        req.addParameter('username', 'fffffff');

        SECAPIbrokerlogin.login();

        req.addParameter('username', 'fffffff');
        req.addParameter('password', 'gggggg');

        SECAPIbrokerlogin.login();

        system.assertEquals(res.statusCode,400);

        req.addParameter('username', 'xxxx');
        req.addParameter('password', 'gggggg');

        SECAPIbrokerlogin.login();

         system.assertEquals(res.statusCode,400);

        req.addParameter('username', 'xxxx');
        req.addParameter('password', 'yyyy');

        SECAPIbrokerlogin.login();

         system.assertEquals(res.statusCode,201);
	}
	
	
	
}