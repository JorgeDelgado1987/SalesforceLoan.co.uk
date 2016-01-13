@isTest
private class SECAPICreditors_test {

	// 22/09/2014 - Simon Parker
	
	@isTest static void getno_creditors() {

	RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    req.requestURI = 'https://dev-loanco.cs10.force.com//services/apexrest/sec/creditors';
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;

    SECAPICreditors.CreditorsResponse results = SECAPICreditors.Creditors();

    system.assertEquals(results.Detail[0], 'No Creditors available.');

	}
	
	
@isTest static void getwith_creditors() {

	Creditor__c c = new Creditor__c();
	c.Name = 'A Creditor';
	
	insert c;

	RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    req.requestURI = 'https://dev-loanco.cs10.force.com//services/apexrest/sec/creditors';
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;

    SECAPICreditors.CreditorsResponse results = SECAPICreditors.Creditors();

    system.assertEquals(results.creditors.get('A Creditor'), c.id);

	}

	@isTest static void getwith_crecitors() {

	Creditor__c c = new Creditor__c();
	c.Name = 'B Creditor';
	

	insert c;

	RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    req.requestURI = 'https://dev-loanco.cs10.force.com//services/apexrest/sec/creditors';
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;

    SECAPICreditors.CreditorsResponse results = SECAPICreditors.Creditors();

    system.assertEquals(results.Status, 'Error');
	}

	
	
}