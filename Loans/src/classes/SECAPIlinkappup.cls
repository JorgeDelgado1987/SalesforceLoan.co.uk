@RestResource(urlMapping='/sec/linkapp')
//////////////////////////////////////////////////
//
//   Created by Simon Parker
//   29/01/2015
//   SEC-287
//
/////////////////////////////////////////////////

// Takes a POST with a Parameter of Username and Password for a User Profile along with Application ID
// If a match found links the Application to that UP, 
//  and returns List of related Application IDs
global class SECAPIlinkappup {
	
	public static list<string> lstErrors;
    public static list<string> lstResponse;
    public static String appResponse;
    public static User_Profile__c up;
    public static boolean appDataSent;
    public static string username;
    public static string password;
    public static string applicationID;

    @HttpPost 
	global static AppResponse linkapp(){

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
         if(mapParamData.containsKey('APPLICATIONID') && mapParamData.get('APPLICATIONID') != null && mapParamData.get('APPLICATIONID') != ''){
            applicationID = String.ValueOf(mapParamData.get('APPLICATIONID'));
        }


        if (username!='' && username!= null && password!='' && password != null && applicationID !='' && applicationID != null){
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
            	RestContext.response.statusCode = 201;
        	}
        	else {
        		appRes.status = 'Rejected';
            	appRes.detail.add('Incorrect username/password combination');
            	RestContext.response.statusCode = 400;	
        	}
        }

        List<Application__c> apps = [Select id, User_Profile__c from Application__c WHERE id=:APPLICATIONID];
        if (apps.size() <1){
        	//no such Application so refuse
            appRes.status = 'Rejected';
            appRes.detail.add('No such Application record.');
            RestContext.response.statusCode = 400;
        }

        else{
        	Application__c thisapp = apps[0];
        	thisapp.User_Profile__c = up.id;
        	update thisapp;

            List<Application__c> userApps = [Select id from Application__c WHERE User_Profile__c = :up.id];
            List<String> userAppIDs = new List<String>();
            for (Application__c myapp : userApps){
                userAppIDs.add(myapp.id);
            }
            appRes.ApplicationIDs = userAppIDs;
            appRes.User_name = up.Username__c;
            appRes.Mobile = up.Mobile__c;
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
        public list<string> ApplicationIDs;
        public string User_name;
        public string Mobile;
    }

}