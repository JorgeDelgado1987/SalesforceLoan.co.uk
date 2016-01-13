@RestResource(urlMapping='/sec/getcrsreport')

//////////////////////////////////////////////////
//
//   Created by Simon Parker
//   06/02/2015
//
/////////////////////////////////////////////////

// Takes an Application ID returns existing CRS report or generates one
global class SECAPIgetCRSReport {

    public static List<String> ErrorsList;

    private static Application__c thisapplication;

    @HttpPost
    global static CRSResponse getCRSReport(){
        RestRequest req = RestContext.request;
        Map<String,Object> tempmapparamdata = RestContext.request.params;
        Map<String,Object> mapparamdata = new Map<String,Object>();

        for(String mkey : tempmapparamdata.keyset()){
            mapparamdata.put(mkey.toUpperCase(), tempmapparamdata.get(mkey));
        }
        ErrorsList = new List<String>();

        string applicationid = getValuefromParameters(mapparamdata,'ID');
        if(applicationid ==''){
            ErrorsList.add('No valid input parameter data sent');
            CRSResponse crsresponse1 = new CRSResponse('Error', ErrorsList);
            String JSONRes = JSON.serialize(crsresponse1);
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf(JSONRes);
            return crsresponse1;
        }

        CRSResponse crsresponse = new CRSResponse();
        thisapplication = getRequestedApplication(applicationid);
        if (thisapplication == null){
            //no such applicant so refuse
            crsresponse.status = 'Rejected';
            crsresponse.detail.add('No such Application record.');
            RestContext.response.statusCode = 400;
        }
        else {
            //found matching app so accept
            CRSIntegration.report crs_report = CRSIntegration.getCreditReport(thisapplication);

            if(crs_report.hasError()){
                crsresponse.Status = 'Failed';
                crsresponse.detail.add(crs_report.Error);
                RestContext.response.statusCode = 400;
            }
            else{
                crsresponse.status = 'Success';
                RestContext.response.statusCode = 200;
                crsresponse.Report = crs_report;
                updateApplicationWithCRSIds(crs_report);
            }
        }

        String JSONRes = JSON.serialize(crsresponse);
        RestContext.response.responseBody = Blob.valueOf(JSONRes);
        return crsresponse;
    }

    private static String getValuefromParameters(Map<String,Object> map_parameters , String required_key){
        if(map_parameters.containsKey(required_key) && map_parameters.get(required_key) != null && map_parameters.get(required_key) != ''){
            return String.ValueOf(map_parameters.get(required_key));
        }
        return '';
    }

    private static Application__c getRequestedApplication(String requested_ID){
        List <Application__c> matchapplications = [Select id, CRS_Report_Id__c, CRS_Originating_Report_Id__c from Application__c WHERE id = :requested_ID ];
        if (matchapplications.size() == 1){
            return matchapplications[0];
        }
        return null;
    }

    private static void updateApplicationWithCRSIds(CRSIntegration.Report credit_report){
        if(String.isBlank(thisapplication.CRS_Report_Id__c) && credit_report.isSuccess()){
            thisapplication.CRS_Report_Id__c = credit_report.Id;
            thisapplication.CRS_Originating_Report_Id__c = credit_report.OriginatingReportId;
            update thisapplication;
        }
    }

    global class CRSResponse{
            public String Status;
            public List<String> Detail;
            public CRSIntegration.report Report;

            global CRSResponse(String in_Status, List<String> in_Detail){
                this.Status = in_Status;
                this.Detail = in_Detail;
            }

            global CRSResponse(){
                Detail = new List<String>();
            }
        }
}