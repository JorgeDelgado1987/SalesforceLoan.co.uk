global class ApplicationRollbackStage {

    // 07/01/2015 - Simon Parker
    // webservice to run headless flow from SKUID button
    // ROLLBACK TO PREVIOUS STAGE


    webservice static String runFlow(ID ApplicationID, String ApplicationType){

        Map<String, Object> params = new Map<String, Object>();
        params.put('AppID', ApplicationID);
        params.put('ApplicationType', ApplicationType);
        params.put('varCurrentUserID', UserInfo.getUserId());
        Flow.Interview.Roll_back_stage myFlow = new Flow.Interview.Roll_back_stage(params);
        myFlow.start();
        return '';
    }
}