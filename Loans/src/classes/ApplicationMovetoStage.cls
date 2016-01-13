global class ApplicationMovetoStage {

    // 02/01/2015 - Simon Parker
    // webservice to run headless flow from SKUID button


    webservice static String runFlow(Id application_id, Integer selected_stage, String application_type){

        Map<String, Object> params = new Map<String, Object>();
        params.put('AppID', application_id);
        params.put('varCurrentUserID', UserInfo.getUserId());
        params.put('selectedStage', selected_stage);
        params.put('ApplicationType', application_type);
        Flow.Interview.MovetoStage myFlow = new Flow.Interview.MovetoStage(params);
        myFlow.start();
        return '';
    }
}