public with sharing class LenderBuilder {

    private Lender__c record;

    private LenderBuilder(String name) {
        this.record = new Lender__c();
        record.Name = name;
    }

    public static LenderBuilder getBuilder(String name){
        return new LenderBuilder(name);
    }

    public Lender__c getRecord(){
        return record;
    }

    public LenderBuilder save(){
        upsert record;
        return this;
    }

    public LenderBuilder setIsIntegrated(Boolean is_integrated){
        record.Is_Integrated__c = is_integrated;
        return this;
    }

    public LenderBuilder setIntegrationName(String integration_name){
        record.Integration_Name__c = integration_name;
        return this;
    }

}