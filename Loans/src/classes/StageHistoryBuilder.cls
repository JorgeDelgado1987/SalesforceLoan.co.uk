public with sharing class StageHistoryBuilder {

    private Stage_History__c record;

    private StageHistoryBuilder(Application__c application) {
        this.record = new Stage_History__c();
        record.Application__c = application.Id;
        record.Application__r = application;
    }

    public static StageHistoryBuilder getBuilder(Application__c application){
        return new StageHistoryBuilder(application);
    }

    public StageHistoryBuilder setApplicationStage(Application_Stage__c application_stage){
        record.Application_Stage_lkup__c = application_stage.Id;
        record.Application_Stage_lkup__r = application_stage;
        return this;
    }

    public Stage_History__c getRecord(){
        return record;
    }

    public StageHistoryBuilder save(){
        upsert record;
        return this;
    }

}