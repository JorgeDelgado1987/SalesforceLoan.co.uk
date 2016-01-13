@isTest
// 13/10/2014 Simon Parker
// 26/01/2015 - SEC-248 - modified to work with UserProfile - SRP
private class SECAPIapplicationpasswordreset_test {
	
	@isTest static void restpasswordtest() {
		
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

        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIapplicationpasswordreset';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        SECAPIapplicationpasswordreset.reset();

        req.addParameter('username', 'fffffff');

        SECAPIapplicationpasswordreset.reset();

        system.assertEquals(400,res.statusCode);

        req.addParameter('username', 'xxxx');

        SECAPIapplicationpasswordreset.reset();

         system.assertEquals(201,res.statusCode);
	}
	
	
	
}