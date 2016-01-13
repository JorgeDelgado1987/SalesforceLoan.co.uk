@RestResource(urlMapping='/sec/addapplication')
global without sharing class SECAddApplication {
    @HttpPost
    global static SignUpResponse doPost() {
        
        Map<String, Object> requestParams = ParseRequest();
                                                
        SignUpResponse response;
        String status = 'success';
        String errorStr = '';
        String successStr = '';

        Application__c appl = new Application__c();

        Account acc = AssertAffIdValid((string)requestParams.get('affId'));

        if (acc == null) {
            status = 'error';
            errorStr = 'Invalid affId';
        }               
        else {   
            Savepoint sp = Database.setSavepoint();                  
               
            appl = new Application__c(Account__c = acc.Id, Status__c = 'White', Sub_Status__c = 'Application', Loan_Amount__c = Decimal.valueOf(Integer.valueOf(requestParams.get('loanAmount'))), Business__c = acc.Business__c,
                                                     Lead_Applicant_Name__c = (String)requestParams.get('firstName'), Application_Type__c = 'Secured Loan', Loan_Purpose__c = (String)requestParams.get('loanPurpose'),
                                                     Loan_Term_Months__c = Decimal.valueOf(Integer.valueOf(requestParams.get('loanTerm'))));
            
            

            try {                            
                insert appl;
                
                Date dob = Date.newInstance(Integer.valueOf(requestParams.get('yearOfBirth')), Integer.valueOf(requestParams.get('monthOfBirth')), Integer.valueOf(requestParams.get('dayOfBirth')));
                
                Applicant__c app = new Applicant__c(Application__c = appl.Id, First_Name__c = (String)requestParams.get('firstName'), Last_Name__c = (String)requestParams.get('lastName'), 
                                                    Marital_Status__c = (String)requestParams.get('maritalStatus'), Date_of_Birth__c = dob, Email_Address__c = (String)requestParams.get('email'), 
                                                    Home_Phone__c = (String)requestParams.get('homePhone'), Mobile_Phone__c = (String)requestParams.get('mobilePhone'), 
                                                    Employment_Status__c = (String)requestParams.get('employmentStatus'), Gross_Monthly_Income__c = Decimal.valueOf((String)requestParams.get('monthlyIncome')));
                insert app;
                
                Property__c prop = new Property__c(Application__c = appl.Id, Current_Address__c = true, Security_Address__c = true, Estimated_Value__c = Decimal.valueOf(Integer.valueOf(requestParams.get('estimatedValue'))), 
                                                   House_Name_Number__c = (String)requestParams.get('houseName'), Street_Name__c = (String)requestParams.get('streetName'), Town__c = (String)requestParams.get('town'), 
                                                   County__c = (String)requestParams.get('county'), Postcode__c = (String)requestParams.get('postCode'));    
                insert prop;
                
                Mortgage__c morg = new Mortgage__c(Application__c = appl.Id, Property__c = prop.Id, Balance__c = Decimal.valueOf(Integer.valueOf(requestParams.get('mortgage'))));
                insert morg;
            }
            catch (Exception ex) {
                status = 'error';
                errorStr = ex.getMessage();
                appl = new Application__c();
                Database.rollback(sp);
            }
        }
        
        response = new SignUpResponse(status, successStr, errorStr, appl.Id);

        return response;
    }
    
    private static Account AssertAffIdValid(string affId) {
        List<Account> a = [SELECT Id, Business__c, Affiliate_ID__c FROM Account WHERE Affiliate_ID__c = :affId];
        
        if (a.size() > 0) {
            return a[0];
        }
        else {
            return null;
        }
    }
    
    private static Map<String, Object> ParseRequest() {
        Map<String, Object> retVal = new Map<String, Object>();
        RestRequest req = RestContext.request;
        
        if (RestContext.request.requestBody != null && RestContext.request.requestBody.ToString() != '') {
            retVal = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.ToString());
        }
        else {
            retVal = RestContext.request.params;
        }
        
        System.debug(retVal);
        
        return retVal;
    }
    
    global class SignUpResponse {

        public String status;
        public String successMessage;
        public String errorMessage;
        public String appId;

            global SignUpResponse(String status, String successMessage, String errorMessage, String appId) {
                this.status = status;
                this.successMessage = successMessage;
                this.errorMessage = errorMessage;
                this.appId = appId;
            }
    }
}