@isTest
private class SECAPIgetMortgageCompanies_Test {

    static testMethod void testGetMortgageCompanies() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();
        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/getMortgageCompanies';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        insert new Mortgage_Company__c();
        Test.startTest();
            SECAPIgetMortgageCompanies.CompaniesResponse resp = SECAPIgetMortgageCompanies.getCompanies();
        Test.stopTest();
        System.assertEquals(1, resp.MortgageCompanies.size());
    }
}