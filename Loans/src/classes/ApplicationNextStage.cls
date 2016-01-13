global class ApplicationNextStage {

    // 19/12/2014 - Simon Parker
    // webservice to run headless flow from SKUID button


    webservice static String runFlow(Id application_id, string selected_outcome_id, String application_type){

        Map<String, Object> params = new Map<String, Object>();
        params.put('AppID', application_id);
        params.put('varCurrentUserID', UserInfo.getUserId());
        params.put('selOutcomeID', selected_outcome_id);
        params.put('ApplicationType', application_type);
        Flow.Interview.NextApplicationStatus myFlow = new Flow.Interview.NextApplicationStatus(params);
        myFlow.start();
        return '';
    }
}