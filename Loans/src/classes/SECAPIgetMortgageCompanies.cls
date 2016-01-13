@RestResource(urlMapping='/sec/getMortgageCompanies')
//////////////////////////////////////////////////
//   Created by Pavel Kashko
//   18/11/2015
//////////////////////////////////////////////////

global class SECAPIgetMortgageCompanies{
    @HttpPost
    global static CompaniesResponse getCompanies(){
        CompaniesResponse companies_response = new CompaniesResponse();
        companies_response.Status = 'Success';

        companies_response.MortgageCompanies =
            [SELECT Id, Name, CreatedDate, Address__c, BSQ_Cost__c, Consent_Cost__c,
                    Email__c, Fax_Number__c, Notes__c, Postcode__c, Telephone_Number__c
             FROM Mortgage_Company__c];

        String JSONRes = JSON.serialize(companies_response);
        RestContext.response.responseBody = blob.valueOf(JSONRes);
        return companies_response;
    }

    global class CompaniesResponse{
        public String Status;
        public List<Mortgage_Company__c> MortgageCompanies;
    }
}