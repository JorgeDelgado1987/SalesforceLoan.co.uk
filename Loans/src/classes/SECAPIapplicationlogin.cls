@RestResource(urlMapping='/sec/userlogin')
//////////////////////////////////////////////////
//
//   Created by Simon Parker
//   13/10/2014
//
/////////////////////////////////////////////////

// 26/01/2015 - SEC-248 - modified to work with UserProfile - SRP
// 11/02/2015 - SEC-308 - CreatedDate added to returned ApplicationIDs - SRP
// 22/05/2015 - SEC-516 - ApplicationSummary added and returned in response - SRP

// Takes a POST with a Parameter of Username and Password for a User Profile  and returns List of related Application IDs


global class SECAPIapplicationlogin {

	public static list<string> lstErrors;
    public static list<string> lstResponse;
    public static String appResponse;
    public static User_Profile__c up;
    public static boolean appDataSent;
    public static string username;
    public static string password;

    @HttpPost 
	global static AppResponse login(){

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
       
        if(mapParamData.containsKey('USERNAME') && mapParamData.get('USERNAME') != null && mapParamData.get('USERNAME') != ''){
            username = String.ValueOf(mapParamData.get('USERNAME'));
        }
        if(mapParamData.containsKey('PASSWORD') && mapParamData.get('PASSWORD') != null && mapParamData.get('PASSWORD') != ''){
            password = String.ValueOf(mapParamData.get('PASSWORD'));
        }

        if (username!='' && username!= null && password!='' && password != null){
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


        //26/01/2015 - changed to work from user profile
        List <User_profile__c> matchUPs = [Select id , password__c, username__c, mobile__c from User_Profile__c WHERE username__c = :username];
        if (matchUPs.size() <1){
            //no such User Profile so refuse
            appRes.status = 'Rejected';
            appRes.detail.add('No such User Profile record.');
            RestContext.response.statusCode = 400;
        }
        else {
            //found matching app so check password
            up = matchUPs[0];
            if (up.password__c == password){
            	appRes.status = 'Success';
            	RestContext.response.statusCode = 200;
        	}
        	else {
        		appRes.status = 'Rejected';
            	appRes.detail.add('Incorrect username/password combination');
            	RestContext.response.statusCode = 400;	
        	}
        }

    	if (appRes.status == 'Success'){
            List<Application__c> userApps = [Select id, CreatedDate, Loan_Amount__c, Loan_Term_Months__c, Loan_Purpose__c from Application__c WHERE User_Profile__c = :up.id];
            // 22/05/2015 - SEC-516 - ApplicaitonSummary added
            List<String> userAppIDs = new List<String>();
            //Map<String, Datetime> userAppIDs = new Map<String,Datetime>();
            List<ApplicationSummary> applicationsummaries = new List<ApplicationSummary>();
            for (Application__c myapp : userApps){
                //userAppIDs.put(myapp.id, myapp.CreatedDate);
                applicationsummaries.add( new ApplicationSummary(myapp.Id, myapp.CreatedDate, myapp.Loan_Amount__c, integer.valueOf(myapp.Loan_Term_Months__c), myapp.Loan_Purpose__c ));
            }
            //appRes.ApplicationIDs = userAppIDs;
            appRes.User_name = up.Username__c;
            appRes.Mobile = up.Mobile__c;
            appRes.ApplicationSummaries = applicationsummaries;
            //string loginhistID = Login_util.createLoginHistory(up.id, UserInfo.getUserId(), 'Success');
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

        public String Status;
        public List<string> Detail;
        //public List<string> ApplicationIDs;
        //public Map<String,Datetime> ApplicationIDs;
        public List<ApplicationSummary> ApplicationSummaries;
        public String User_name;
        public String Mobile;
    }

    global class ApplicationSummary{

        global ApplicationSummary(String applicationID, Datetime createdDate, Decimal loanamount, Integer loanterm, String purposeofloan){
            this.ApplicationID = applicationID;
            this.CreateDate = createdDate;
            this.LoanAmount = loanamount;
            this.LoanTerm = loanterm;
            this.PurposeofLoan = purposeofloan;
        }

        public String ApplicationID;
        public Datetime CreateDate;
        public Decimal LoanAmount;
        public Integer LoanTerm;
        public String PurposeofLoan;

    }
	
}