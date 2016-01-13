@RestResource(urlMapping='/sec/createMortgageCompany')
//////////////////////////////////////////////////
//   Created by Pavel Kashko
//   18/11/2015
//////////////////////////////////////////////////

global class SECAPIcreateMortgageCompany{
    @HttpPost
    global static CompanyResponse createCompany(){
        CompanyResponse company_response = new CompanyResponse();
        company_response.Status = 'Success';
        Map<String, Object> parameters_map = new Map<String, Object>();
        for(String key:RestContext.request.params.keyset()){
            parameters_map.put(key.toUpperCase(), RestContext.request.params.get(key));
        }
        try{
            Mortgage_Company__c new_company = new Mortgage_Company__c();
            if(parameters_map.get('NAME') != null)
                new_company.Name = String.valueOf(parameters_map.get('NAME'));
            if(parameters_map.get('EMAIL') != null)
                new_company.Email__c = String.valueOf(parameters_map.get('EMAIL'));
            if(parameters_map.get('NOTES') != null)
                new_company.Notes__c = String.valueOf(parameters_map.get('NOTES'));
            if(parameters_map.get('POSTCODE') != null)
                new_company.Postcode__c = String.valueOf(parameters_map.get('POSTCODE'));
            if(parameters_map.get('PHONE') != null)
                new_company.Telephone_Number__c = String.valueOf(parameters_map.get('PHONE'));
            if(parameters_map.get('FAX') != null)
                new_company.Fax_Number__c = String.valueOf(parameters_map.get('FAX'));
            if(parameters_map.get('ADDRESS') != null)
                new_company.Address__c = String.valueOf(parameters_map.get('ADDRESS'));
            if(parameters_map.get('BSQCOST') != null)
                new_company.BSQ_Cost__c = Decimal.valueOf(String.valueOf(parameters_map.get('BSQCOST')));
            if(parameters_map.get('CONSENTCOST') != null)
                new_company.Consent_Cost__c = Decimal.valueOf(String.valueOf(parameters_map.get('CONSENTCOST')));
            insert new_company;
            company_response.MortgageCompanyId = new_company.Id;
        } catch (Exception e) {
            company_response.Status = 'Failed';
            company_response.Detail = e.getMessage();
        }

        String JSONRes = JSON.serialize(company_response);
        RestContext.response.responseBody = blob.valueOf(JSONRes);
        return company_response;
    }

    global class CompanyResponse{
        public String Status;
        public String Detail;
        public String MortgageCompanyId;
    }
}