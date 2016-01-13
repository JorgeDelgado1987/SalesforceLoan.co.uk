public with sharing class ApplicationStageBuilder {

    private Application_Stage__c record;

    private ApplicationStageBuilder(String stage_name) {
        this.record = new Application_Stage__c();
        record.Stage__c = stage_name;
    }

    public static ApplicationStageBuilder getBuilder(String stage_name){
        return new ApplicationStageBuilder(stage_name);
    }

    public Application_Stage__c getRecord(){
        return record;
    }

    public ApplicationStageBuilder save(){
        upsert record;
        return this;
    }

}