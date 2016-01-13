@RestResource(urlMapping='/sec/submittoDE')

//////////////////////////////////////////////////
//
//   Created by Simon Parker
//   02/02/2015
//
/////////////////////////////////////////////////

// Takes a POST with a Parameter of Application ID
// Returns list of accepted lender plan/rates

global class SECAPIsubmittoDE {

	public static List<String> ErrorsList;
    public static Integer PassedCount {get; private set;}
    public static List<PassedPlan> PassedPlans;

    private static DEData de_data;
    private static Application__c thisapplication;

    @HttpPost
	global static DEResponse getAcceptedPlanRates(){

		RestRequest req = RestContext.request;
        //Builds MAP of URL Parameters
        Map<String,Object> tempmapparamdata = RestContext.request.params;
        Map<String,Object> mapparamdata = new Map<String,Object>();

        //Loops through inbound params and assigns the keys in the map to upper case
        for(String mkey : tempmapparamdata.keyset()){
            mapparamdata.put(mkey.toUpperCase(), tempmapparamdata.get(mkey));
        }
        ErrorsList = new List<String>();

        string applicationid = getValuefromParameters(mapparamdata,'ID');

        if(applicationid ==''){
            ErrorsList.add('No valid input parameter data sent');
            DEResponse deresponse1 = new DEResponse('Error', ErrorsList);
            String JSONRes = JSON.serialize(deresponse1);
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf(JSONRes);
            return deresponse1;
        }

        DEResponse DERes = new DEResponse();

        thisapplication = getRequestedApplication(applicationid);
        if (thisapplication == null){
            //no such applicant so refuse
            DERes.status = 'Rejected';
            DERes.detail.add('No such Application record.');
            RestContext.response.statusCode = 400;
        }
        else {
            //found matching app so accept
            DERes.status = 'Success';
            RestContext.response.statusCode = 200;
            DecisionEngineIntegration.Response decison_response = DecisionEngineIntegration.getDecision(SecuredLoansIntegrationModels.getAllApplicationData(applicationId));
            de_data = setDEDataObjectsfromDecisionResponse(decison_response);
 	        PassedPlans = de_data.getPassedPlans();
	        PassedCount = de_data.getPassedCount();

            DEres.AcceptedPlans = PassedPlans;
            DEres.AcceptedCount = PassedCount;

        }

        String JSONRes = JSON.serialize(DERes);

        RestContext.response.responseBody = Blob.valueOf(JSONRes);

        return DERes;
	}

    private static DEData setDEDataObjectsfromDecisionResponse(DecisionEngineIntegration.Response decison_response){
        return new DEData(decison_response, thisapplication);
    }

    private static String getValuefromParameters(Map<String,Object> map_parameters , String required_key){
        if(map_parameters.containsKey(required_key) && map_parameters.get(required_key) != null && map_parameters.get(required_key) != ''){
            return String.ValueOf(map_parameters.get(required_key));
        }
        return '';
    }

    private static Application__c getRequestedApplication(String requested_ID){
        List<Application__c> matchapplications = [Select id, Loan_Term_Months__c from Application__c WHERE id = :requested_ID ];
        if (matchapplications.size() == 1){
            return matchapplications[0];
        }
        return null;
    }

	global class DEResponse{
        public String Status;
        public List<String> Detail;
        public Integer AcceptedCount;
        public List<PassedPlan> AcceptedPlans;

        global DEResponse(String inStatus, List<String> inDetail){
            this.status = inStatus;
            this.Detail = inDetail;
        }

        global DEResponse(){
            Detail = new List<String>();
        }
    }

    public class DEData{
        private DecisionEngineIntegration.Response decison_response;
        private Application__c application;

        public DEData(DecisionEngineIntegration.Response response, Application__c application_record){
            decison_response = response;
            application = application_record;
            //system.debug(decison_response);
        }

        public Integer getPassedCount(){
            if(decison_response.Summary != null && decison_response.Summary.PassedCount != null){
                return decison_response.Summary.PassedCount;
            }
            return 0;
        }

        public List<PassedPlan> getPassedPlans(){
            List<PassedPlan> passed_plans = new List<PassedPlan>();
            if(decison_response.Passed != null){
                for(DecisionEngineIntegration.PlanEvaluationResponse passed_plan:decison_response.Passed){
                    for(DecisionEngineIntegration.PlanRateEvaluationResponse passed_rate: passed_plan.PlanRateEvaluationResponses){
                        for(DecisionEngineIntegration.RepaymentOptionEvaluationResponse repayment_type_result: passed_rate.RepaymentOptionEvaluationResponses){
                            passed_plans.add(new PassedPlan(passed_plan,passed_rate, repayment_type_result, application));
                        }
                    }
                }
            }
            return passed_plans;
        }

    }

    public class PassedPlan{
        private Double monthlyrepaymentestimate;
        private Double totalrepayable;
        private Double lenderfees;
        private Double apr;
        private String lendername;
        private String planname;
        private Double interestrate;
        private String planrateid;

        public PassedPlan(DecisionEngineIntegration.PlanEvaluationResponse result, DecisionEngineIntegration.PlanRateEvaluationResponse passed_rate, DecisionEngineIntegration.RepaymentOptionEvaluationResponse repayment_type_result, Application__c application){
            lendername = 'Unknown Lender';
            if(result.LenderName != null){ lendername = result.LenderName;}
            if(result.PlanName != null){planname = result.PlanName;}
            interestrate = 0;
            if(passed_rate.Rate != null){interestrate = passed_rate.Rate;}
            if(passed_rate.SfPlanRateId != null){planrateid =  passed_rate.SfPlanRateId;}
            apr = 0;
            if(repayment_type_result.Apr != null){ apr = repayment_type_result.Apr;}
            monthlyrepaymentestimate = 0;
            if(repayment_type_result.MonthlyPaymentEstimate != null){monthlyrepaymentestimate = repayment_type_result.MonthlyPaymentEstimate;}
            lenderfees = 0;
            if(passed_rate.LenderFee != null){lenderfees = passed_rate.LenderFee;}
            totalrepayable = monthlyrepaymentestimate * application.Loan_Term_Months__c;
        }

    }

}