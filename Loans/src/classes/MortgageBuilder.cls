public with sharing class MortgageBuilder {

    private Mortgage__c record;

    private MortgageBuilder(Application__c application) {
        this.record = new Mortgage__c();
        record.Application__c = application.Id;
        record.Application__r = application;
    }

    public static MortgageBuilder getBuilder(Application__c application){
        return new MortgageBuilder(application);
    }

    public Mortgage__c getRecord(){
        return record;
    }

    public MortgageBuilder save(){
        upsert record;
        return this;
    }

    public MortgageBuilder setOnSecurityAddress(Boolean on_security_address){
        record.On_Security_Address__c = on_security_address;
        return this;
    }

    public MortgageBuilder setProperty(Property__c property){
        record.Property__c = property.Id;
        record.Property__r = property;
        return this;
    }

    public MortgageBuilder setMortgageStartDate(Date mortgage_start_date){
        record.Mortgage_Start_Date__C = mortgage_start_date;
        return this;
    }

}