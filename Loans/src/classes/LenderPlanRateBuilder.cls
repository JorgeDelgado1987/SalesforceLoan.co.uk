public with sharing class LenderPlanRateBuilder {

    private Lender_Plan_Rate__c record;

    private LenderPlanRateBuilder(Lender_Plan__c lender_plan) {
        this.record = new Lender_Plan_Rate__c();
        record.Lender_Plan__r = lender_plan;
        record.Lender_Plan__c = lender_plan.Id;
    }

    public static LenderPlanRateBuilder getBuilder(Lender_Plan__c lender_plan){
        return new LenderPlanRateBuilder(lender_plan);
    }

    public Lender_Plan_Rate__c getRecord(){
        return record;
    }

    public LenderPlanRateBuilder save(){
        upsert record;
        return this;
    }

}