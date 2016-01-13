@isTest
private class SECAddApplication_Test {  
  
    private static void setUp() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.addParameter('affId', 'SAMLOAN');
        req.addParameter('loanAmount', '100000');
        req.addParameter('loanPurpose', 'xxx');
        req.addParameter('loanTerm', '48');
        req.addParameter('term', 'xxx');
        req.addParameter('firstName', 'xxx');
        req.addParameter('lastName', 'xxx');
        req.addParameter('dayOfBirth', '1');
        req.addParameter('monthOfBirth', '1');
        req.addParameter('yearOfBirth', '1985');
        req.addParameter('email', 'test@test.com');
        req.addParameter('mobilePhone', 'xxx');
        req.addParameter('homePhone', 'xxx');
        req.addParameter('monthlyIncome', '7500');
        req.addParameter('employmentStatus', 'xxx');
        req.addParameter('maritalStatus', 'xxx');
        req.addParameter('houseName', 'xxx');
        req.addParameter('streetName', 'xxx');
        req.addParameter('town', 'xxx');
        req.addParameter('county', 'xxx');
        req.addParameter('postCode', 'xxx');
        req.addParameter('estimatedValue', '400000');
        req.addParameter('mortgage', '250000');
 
        string url = System.URL.getSalesforceBaseUrl().toExternalForm() +
                     '/services/apexrest/sec/addapplication?' +
                     'affId=SAMLOAN' +
                     '&loanAmount=100000' +
                     '&loanPurpose=xxx' +
                     '&loanTerm=48' +
                     '&term=xxx' +
                     '&firstName=xxx' +
                     '&lastName=xxx' +
                     '&dayOfBirth=1' +
                     '&monthOfBirth=1' +
                     '&yearOfBirth=1985' +
                     '&email=test@test.com' +
                     '&mobilePhone=xxx' +
                     '&homePhone=xxx' +
                     '&monthlyIncome=7500' +
                     '&employmentStatus=xxx' +
                     '&maritalStatus=xxx' +
                     '&houseName=xxx' +
                     '&streetName=xxx' +
                     '&town=xxx' +
                     '&county=xxx' +
                     '&postCode=xxx' +
                     '&estimatedValue=400000' +
                     '&mortgage=250000';

        System.debug(url);                     

        req.requestURI = url;
                          
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
    }
    
    static testMethod void doPost_invalidAffId() {    
        setUp();
        
        SECAddApplication.SignUpResponse response = SECAddApplication.doPost();               
    }
    
    static testMethod void doPost_validAffId() {        
        setUp();
        
        Account acc = new Account(Name = 'Test', Affiliate_ID__c = 'SAMLOAN');
        insert acc;
        
        SECAddApplication.SignUpResponse response = SECAddApplication.doPost();        
    }
}