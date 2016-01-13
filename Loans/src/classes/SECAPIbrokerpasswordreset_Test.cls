@isTest
// 10/10/2014 Simon Parker
private class SECAPIbrokerpasswordreset_Test {
	@isTest static void test_reset() {
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

        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIbrokerpasswordreset';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        SECAPIbrokerpasswordreset.reset();

        req.addParameter('username', 'fffffff');

        SECAPIbrokerpasswordreset.reset();

        system.assertEquals(res.statusCode,400);

        req.addParameter('username', 'xxxx');

        SECAPIbrokerpasswordreset.reset();

         system.assertEquals(res.statusCode,201);

    }
}