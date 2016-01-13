@RestResource(urlMapping='/sec/getRelatedApplications')
//////////////////////////////////////////////////
//
//   Created by Simon Parker
//   08/10/2014
//
/////////////////////////////////////////////////

// 04/11/2014 - Application_stage__c added SRP
// 16/12/2014 - Additonal fields added as per SEC-170 - SRP

// Takes a POST with a Parameter of Account ID summary fields of related Applications


global class SECAPIgetRelatedApplications {


    public static list<string> lstErrors;
    public static list<string> lstResponse;
    public static String appResponse;
    public static Account acc;
    public static boolean appDataSent;
    public static string accid;

    @HttpPost 
    global static AppResponse AppDetails(){

        RestRequest req = RestContext.request;      
        system.debug('*** -- req.requestURI : ' + req.requestURI);
        system.debug('*** -- RestContext.request.params: ' + RestContext.request.params);
        
        //Builds MAP of URL Parameters
        map<String,Object> tempMapParamData = RestContext.request.params;
        map<String,Object> mapParamData = new map<String,Object>(); 
        
        system.debug('*** -- tempMapParamData: ' + tempMapParamData);
        
        //Loops through inbound params and assigns the keys in the map to upper case
        list<string> paramsALPHA = new list<string>();
        for(string mkey : tempMapParamData.keyset()){
            mapParamData.put(mKey.toUpperCase(), tempMapParamData.get(mkey));
            paramsALPHA.add(mkey);
        }

        paramsALPHA.sort();
        
        appDataSent = false;
        //Assigns MAP Values to variables to be used and checks their formatting
        lstErrors = new list<string>();
       
        if(mapParamData.containsKey('ID') && mapParamData.get('ID') != null && mapParamData.get('ID') != ''){
            accid = String.ValueOf(mapParamData.get('ID'));
        }
       
        if (accid!='' && accid!= null ){
            appDataSent = true;
        }

        AppResponse appRes = new AppResponse();
        
        if(!appDataSent){
            lstErrors.add('No valid input parameter data sent');            
            AppResponse appRes1 = new AppResponse('Error', lstErrors);
            String JSONRes = JSON.serialize(appRes1);
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = blob.valueOf(JSONRes);
            return appRes1;  
        }



        List<Account> accs = [Select id from Account WHERE id = :accid];
        if (accs.size() <1){
            //no such applicant so refuse
            appRes.status = 'Rejected';
            appRes.detail.add('No such Contact record.');
            RestContext.response.statusCode = 400;
        }
        else {
            //found matching app 
            acc = accs[0];
            appRes.status = 'Success';
            RestContext.response.statusCode = 201;
        }

        if (appRes.status == 'Success'){

            // 04/11/2014 - Application_stage__c added SRP
            List<Application__c> apps = [SELECT id, name, Completed_Date__c, CreatedDate, Status__c, Application_Stage__c, Lead_Applicant_Name__c,Affiliate_Commission__c ,Loan_Amount__c ,Loan_Term_Months__c ,Loan_purpose__c, Keyword__c,Stage__c, 
                                         (SELECT Id, First_Name__c, Last_Name__c, Title__c, Email_Address__c, Mobile_Phone__c, Gross_Annual_Income__c FROM Applicants__r)
                                         FROM Application__c WHERE account__r.id =:accid];
            appRes.Applications = apps;

        }

        String JSONRes = JSON.serialize(appRes);
        system.debug('*** -- JSONRes ' + JSONRes);
        
        RestContext.response.responseBody = blob.valueOf(JSONRes);
        system.debug(RestContext.response);
        
        return appRes;
    }

    global class APPResponse{
        
        global AppResponse(){
            Detail = new list<string>();
        }
        
        global AppResponse(string inStatus, list<string> inDetail){
            this.status = inStatus;
            this.Detail = inDetail;
        }

        public string Status;
        public list<string> Detail;
        public List<Application__c> Applications;
    }
}