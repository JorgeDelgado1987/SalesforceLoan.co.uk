public with sharing class LenderPlanBuilder {

    private Lender_Plan__c record;

    private LenderPlanBuilder(Lender__c lender) {
        this.record = new Lender_Plan__c();
        record.Lender__c = lender.Id;
        record.Lender__r = lender;
    }

    public static LenderPlanBuilder getBuilder(Lender__c lender){
        return new LenderPlanBuilder(lender);
    }

    public Lender_Plan__c getRecord(){
        return record;
    }

    public LenderPlanBuilder save(){
        upsert record;
        return this;
    }

}