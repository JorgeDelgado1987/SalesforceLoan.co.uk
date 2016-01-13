public with sharing class CreditorBuilder {

    private Creditor__c record;

    private CreditorBuilder() {
        this.record = new Creditor__c();
    }

    public static CreditorBuilder getBuilder(){
        return new CreditorBuilder();
    }

    public Creditor__c getRecord(){
        return record;
    }

    public CreditorBuilder save(){
        upsert record;
        return this;
    }

}