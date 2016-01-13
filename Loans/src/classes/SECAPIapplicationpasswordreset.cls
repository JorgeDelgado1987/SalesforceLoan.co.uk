@RestResource(urlMapping='/sec/userpasswordreset')
//////////////////////////////////////////////////
//
//   Created by Simon Parker
//   13/10/2014
//
/////////////////////////////////////////////////

// 26/01/2015 - SEC-248 - modified to work with UserProfile - SRP

// Takes a POST with a Parameter of Username and if exists returns a new password
global class SECAPIapplicationpasswordreset {

	public static list<string> lstErrors;
    public static list<string> lstResponse;
    public static String appResponse;
    public static User_Profile__c up;
    public static boolean appDataSent;
    public static string username;

    @HttpPost 
	global static AppResponse reset(){

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

        if (username!='' && username!= null ){
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
        List <User_profile__c> matchUPs = [Select id , password__c from User_Profile__c WHERE username__c = :username];
        if (matchUPs.size() <1){
            //no such applicant so refuse
            appRes.status = 'Rejected';
            appRes.detail.add('No such User record.');
            RestContext.response.statusCode = 400;
        }
        else {
            //found matching contact so check password
            up = matchUPs[0];
            appRes.status = 'Success';
            RestContext.response.statusCode = 201;
        }

    	if (appRes.status == 'Success'){
    		up.password__c = Utility.generatePassword();
    		update up;
            appRes.password = up.password__c;
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
        public string password;
    }
}