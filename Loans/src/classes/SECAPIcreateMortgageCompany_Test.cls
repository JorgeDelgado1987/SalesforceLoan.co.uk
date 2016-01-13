@isTest
private class SECAPIcreateMortgageCompany_Test {

    static testMethod void testCreateMortgageCompany() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();
        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/createMortgageCompany';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
            SECAPIcreateMortgageCompany.CompanyResponse resp = SECAPIcreateMortgageCompany.createCompany();
        Test.stopTest();
        System.assertEquals('Success', resp.Status);
        System.assertEquals(1, [SELECT COUNT() FROM Mortgage_Company__c WHERE Id=:resp.MortgageCompanyId]);
    }
}