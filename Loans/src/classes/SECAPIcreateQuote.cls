@RestResource(urlMapping='/sec/createquote')

//////////////////////////////////////////////////
//
//   Created by Simon Parker
//   04/02/2015
//
/////////////////////////////////////////////////

// Takes an Application ID, Lender_Plan_Rate ID, APR & monthly repayment estimate to create a Quote__c record

global class SECAPIcreateQuote {
	
	public static List<String> ErrorsList;

    private static Lender_PLan_Rate__c thislenderplanrate;
    private static Application__c thisapplication;
    private static String aprstring;
    private static String monthlyrepaymentstring;

    @HttpPost 
	global static QuoteResponse createQuote(){

		RestRequest req = RestContext.request;      
        Map<String,Object> tempmapparamdata = RestContext.request.params;
        Map<String,Object> mapparamdata = new Map<String,Object>(); 
        
        for(String mkey : tempmapparamdata.keyset()){
            mapparamdata.put(mkey.toUpperCase(), tempmapparamdata.get(mkey));
        }
        ErrorsList = new List<String>();

        string planrateid = getValuefromParameters(mapparamdata,'PLANRATEID');
        string applicationid = getValuefromParameters(mapparamdata,'APPLICATIONID');
        aprstring = getValuefromParameters(mapparamdata,'APR');
        monthlyrepaymentstring = getValuefromParameters(mapparamdata,'MONTHLYREPAYMENT');

        if(planrateid =='' || applicationid=='' || aprstring == '' || monthlyrepaymentstring == ''){
            ErrorsList.add('No valid input parameter data sent');            
            QuoteResponse failedresponse = new QuoteResponse('Error', ErrorsList);
            String JSONRes = JSON.serialize(failedresponse);
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf(JSONRes);
            return failedresponse;  
        }

        QuoteResponse quoteresponse = new QuoteResponse();
        quoteresponse.status = 'Success';

        thislenderplanrate = getRequestedLenderPlanRate(planrateid);
        thisapplication = getRequestedApplication(applicationid);
        if (thislenderplanrate == null){
            quoteresponse.status = 'Rejected';
            quoteresponse.detail.add('No such Lender Plan Rate record.');
            RestContext.response.statusCode = 400;
        }

        if (thisapplication == null){
            quoteresponse.status = 'Rejected';
            quoteresponse.detail.add('No such Application record.');
            RestContext.response.statusCode = 400;
        }

        if(quoteresponse.status == 'Success'){

        	String quoteid = insertQuote();

        	if (quoteid.contains('failed')){
        		quoteresponse.Status = 'Rejected';
            	quoteresponse.Detail.add('Error inserting new quote.');
                quoteresponse.Detail.add(quoteid);
            	RestContext.response.statusCode = 400;
        	}
        	else{
        		RestContext.response.statusCode = 201;
        		quoteresponse.QuoteID = quoteid;
        	}

        }

        String JSONRes = JSON.serialize(quoteresponse);
        
        RestContext.response.responseBody = Blob.valueOf(JSONRes);
        
        return quoteresponse;
	}

    private static String getValuefromParameters(Map<String,Object> map_parameters , String required_key){
        if(map_parameters.containsKey(required_key) && map_parameters.get(required_key) != null && map_parameters.get(required_key) != ''){
            return String.ValueOf(map_parameters.get(required_key));
        }
        return '';
    }

    private static Lender_Plan_Rate__c getRequestedLenderPlanRate(String requested_ID){
        List <Lender_Plan_Rate__c> matchlenderplanrates = [Select id, Lender_Fee__c, TT_Fee__c, Solicitors_Costs__c, Title_Insurance__c, Rate__c,
        		Lender_Plan__r.Id, Lender_Plan__r.Lender__r.Id, Lender_Plan__r.Commission__c from Lender_Plan_Rate__c WHERE id = :requested_ID ];
        if (matchlenderplanrates.size() == 1){
            return matchlenderplanrates[0];
        }
        return null;
    }

    private static Application__c getRequestedApplication(String requested_ID){
        List <Application__c> matchapplications = [Select id, Broker_Fee__c, Loan_Amount__c from Application__c WHERE id = :requested_ID ];
        if (matchapplications.size() == 1){
            return matchapplications[0];
        }
        return null;
    }

    private static String insertQuote(){
    	Quote__c quote = new Quote__c();
    	quote.Application__c = thisapplication.ID;
    	quote.Broker_Fee__c = thisapplication.Broker_Fee__c;
		quote.Lender_Fee__c = thislenderplanrate.Lender_Plan__r.Lender__r.Id ;
		quote.Lender_Plan__c = thislenderplanrate.Lender_Plan__r.Id;
		quote.Lender_plan_Rate__c = thislenderplanrate.Id;
		quote.Monthly_Repayment__c = Decimal.valueOf(monthlyrepaymentstring);
        if((thislenderplanrate.Lender_Plan__r.Commission__c != null) && (thisapplication.Loan_Amount__c != null)){
            quote.Commission__c = ((thislenderplanrate.Lender_Plan__r.Commission__c * thisapplication.Loan_Amount__c)/100);
        }
		quote.APR__c = Decimal.valueOf(aprstring);
		quote.Lender_Fee_Value__c = thislenderplanrate.Lender_Fee__c;
		quote.TT_Fee__c = thislenderplanrate.TT_Fee__c;
		quote.Solicitors_Costs__c = thislenderplanrate.Solicitors_Costs__c;
		quote.Title_Insurance__c = thislenderplanrate.Title_Insurance__c;
		quote.Interest_Rate__c = thislenderplanrate.Rate__c;
		quote.Active__c = true;
        quote.Name = 'Website Quote - '+ System.now();

		try{
            insert quote;
            return quote.id;
        } catch (Exception e) {
    		return 'Insert quote failed - '+ e.getMessage();
		}
    }

	global class QuoteResponse{
        
        global QuoteResponse(){
            Detail = new List<String>();
        }
        
        global QuoteResponse(String inStatus, List<String> inDetail){
            this.status = inStatus;
            this.Detail = inDetail;
        }

        public String Status;
        public List<String> Detail;
        public String QuoteID;
        
    }
}