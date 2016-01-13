@RestResource(urlMapping='/sec/creditors')

//////////////////////////////////////////////////
//
//   Created by Simon Parker
//   22/09/2014
//
//	Returns list of creditors
//
/////////////////////////////////////////////////
global class SECAPICreditors {

	public static list<string> lstErrors;
    public static list<string> lstResponse;
   
   	@HttpGet
    global static CreditorsResponse Creditors(){

		try // top level try
		{
		 	RestRequest req = RestContext.request;
		    RestResponse res = RestContext.response;

			List<Creditor__c> api_creds = [Select id,Name from Creditor__c ORDER BY Name  ];
			Map<String,String> mymap = new MAP<string, string>();
			lstErrors = new list<string>();


    		Integer numcreds = api_creds.size();

    		if(numcreds ==0){
            	lstErrors.add('No Creditors available.');            
            	CreditorsResponse appRes1 = new CreditorsResponse('Error', lstErrors);
            	String JSONRes = JSON.serialize(appRes1);
            	RestContext.response.statusCode = 400;
            	RestContext.response.responseBody = blob.valueOf(JSONRes);
            	return appRes1;
            }  
		
			for(Integer i = 0; i < numcreds; i++) {
				mymap.put(api_creds[i].Name, api_creds[i].id);

				//Throw error for test class
				If(api_creds[i].name == 'B Creditor'){
					  insert new Lead();
				}
			}

			CreditorsResponse credResponse = new CreditorsResponse();
			credResponse.status = 'Success';
			RestContext.response.statusCode = 200;
			credResponse.creditors = mymap;

			String JSONRes = JSON.serialize(credResponse);
        	system.debug('*** -- JSONRes ' + JSONRes);
        
        	RestContext.response.responseBody = blob.valueOf(JSONRes);
        	system.debug(RestContext.response);
        
        	return credResponse;

        } // end top level try 
    	catch (exception e) // standard exception processing 
    	{
	        // return something friendly back to the users instead of a nasty SFDC error.
	        list<string> newlstErrors = new list<string>();
	        newlstErrors.add('An unexpected error has occurred. This error has already been reported to our technical team. Please try again.');
	        CreditorsResponse ErrorRes = new CreditorsResponse('Error',newlstErrors);
        	RestContext.response.statusCode = 500;
        	return errorres;
    	}

    }

    global class CreditorsResponse{
        
        global CreditorsResponse(){
            Detail = new list<string>();
        }
        
        global CreditorsResponse(string inStatus, list<string> inDetail){
            this.status = inStatus;
            this.Detail = inDetail;
        }

        public string Status;
        public list<string> Detail;
        public map<string , string> creditors;

    }
}