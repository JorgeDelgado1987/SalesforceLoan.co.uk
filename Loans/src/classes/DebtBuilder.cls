public with sharing class DebtBuilder {

    private Debt__c record;

    private DebtBuilder(Application__c application) {
        this.record = new Debt__c();
        record.Application__c = application.Id;
        record.Application__r = application;
    }

    public static DebtBuilder getBuilder(Application__c application){
        return new DebtBuilder(application);
    }

    public Debt__c getRecord(){
        return record;
    }

    public DebtBuilder save(){
        upsert record;
        return this;
    }

    public DebtBuilder setCreditor(Creditor__c creditor){
        record.Creditor__c = creditor.Id;
        record.Creditor__r = creditor;
        return this;
    }

    public DebtBuilder setDateAccountOpened(Date date_account_opened){
        record.Date_Account_Opened__c = date_account_opened;
        return this;
    }

    public DebtBuilder setDebtIndex(Integer debt_index){
        record.Debt_Index__c = debt_index;
        return this;
    }

    public DebtBuilder setApplicantIndex(Integer applicant_index){
        record.Applicant_Index__c = applicant_index;
        return this;
    }

    public DebtBuilder setAmountOutstanding(Decimal amount_outstanding){
        record.Amount_Outstanding__c = amount_outstanding;
        return this;
    }

}