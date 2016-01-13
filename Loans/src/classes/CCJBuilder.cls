public with sharing class CCJBuilder {

    private CCJ__c record;

    private CCJBuilder(Application__c application) {
        this.record = new CCJ__c();
        record.Application__c = application.Id;
        record.Application__r = application;
    }

    public static CCJBuilder getBuilder(Application__c application){
        return new CCJBuilder(application);
    }

    public CCJ__c getRecord(){
        return record;
    }

    public CCJBuilder save(){
        upsert record;
        return this;
    }

    public CCJBuilder setApplicant(Applicant__c applicant){
        record.Applicant__c = applicant.Id;
        record.Applicant__r = applicant;
        return this;
    }

    public CCJBuilder setJudgementDate(Date judgement_date){
        record.Judgement_Date__c = judgement_date;
        return this;
    }

    public CCJBuilder setApplicantIndex(Integer applicant_index){
        record.Applicant_Index__c = applicant_index;
        return this;
    }

    public CCJBuilder setCCJIndex(Integer ccj_index){
        record.CCJ_Index__c = ccj_index;
        return this;
    }

    public CCJBuilder setValue(Decimal value){
        record.Value__c = value;
        return this;
    }

}