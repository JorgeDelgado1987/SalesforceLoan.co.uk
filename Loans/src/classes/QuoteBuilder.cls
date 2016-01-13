public with sharing class QuoteBuilder {

    private Quote__c record;

    private QuoteBuilder(Application__c application) {
        this.record = new Quote__c();
        record.Application__c = application.Id;
        record.Application__r = application;
        record.Quoted_by__c = UserInfo.getUserId();
        record.Active__c = true;
    }

    public static QuoteBuilder getBuilder(Application__c application){
        return new QuoteBuilder(application);
    }

    public Quote__c getRecord(){
        return record;
    }

    public QuoteBuilder save(){
        upsert record;
        return this;
    }

    public QuoteBuilder setBrokerFee(Decimal broker_fee){
        record.Broker_Fee__c = broker_fee;
        return this;
    }

    public QuoteBuilder setLender(Lender__c lender){
        record.Lender_Fee__c = lender.Id;
        record.Lender_Fee__r = lender;
        return this;
    }

    public QuoteBuilder setLender(Id lender_id){
        Lender__c lender = new Lender__c(Id=lender_id);
        return setLender(lender);
    }

    public QuoteBuilder setLenderPlan(Lender_Plan__c lender_plan){
        record.Lender_Plan__c = lender_plan.Id;
        record.Lender_Plan__r = lender_plan;
        return this;
    }

    public QuoteBuilder setLenderPlan(Id lender_Plan_id){
        Lender_Plan__c lender_plan = new Lender_Plan__c(Id=lender_Plan_id);
        return setLenderPlan(lender_plan);
    }

    public QuoteBuilder setLenderPlanRate(Lender_Plan_Rate__c lender_plan_plan){
        record.Lender_Plan_Rate__c = lender_plan_plan.Id;
        record.Lender_Plan_Rate__r = lender_plan_plan;
        return this;
    }

    public QuoteBuilder setLenderPlanRate(Id lender_plan_rate_id){
        Lender_Plan_Rate__c lender_plan_rate = new Lender_Plan_Rate__c(Id=lender_plan_rate_id);
        return setLenderPlanRate(lender_plan_rate);
    }

    public QuoteBuilder setMonthlyRepayment(Decimal monthly_repayment){
        record.Monthly_Repayment__c = monthly_repayment;
        return this;
    }

    public QuoteBuilder setCommission(Decimal commission){
        record.Commission__c = commission;
        return this;
    }

    public QuoteBuilder setApr(Decimal apr){
        record.Apr__c = apr;
        return this;
    }

    public QuoteBuilder setLenderFee(Decimal lender_fee){
        record.Lender_Fee_Value__c = lender_fee;
        return this;
    }

    public QuoteBuilder setTTFee(Decimal tt_fee){
        record.TT_Fee__c = tt_fee;
        return this;
    }

    public QuoteBuilder setSolicitorsCosts(Decimal solicitors_costs){
        record.Solicitors_Costs__c = solicitors_costs;
        return this;
    }

    public QuoteBuilder setTitleInsurance(Decimal title_insurance){
        record.Title_Insurance__c = title_insurance;
        return this;
    }

    public QuoteBuilder setInterestRate(Decimal interest_plan){
        record.Interest_Rate__c = interest_plan;
        return this;
    }

    public QuoteBuilder setMaxLtv(Decimal max_ltv){
        //record.Max_LTV__c = max_ltv;
        return this;
    }

    public QuoteBuilder setLtv(Decimal ltv){
        //record.LTV__c = ltv;
        return this;
    }

    public QuoteBuilder setMonthlyRate(Decimal monthly_rate){
        record.Monthly_Rate__c = monthly_rate;
        return this;
    }

    public QuoteBuilder setAnnualEquivalentRate(Decimal annual_equivalent_rate){
        record.Annual_Equivalent_Rate__c = annual_equivalent_rate;
        return this;
    }

    public QuoteBuilder setDailyRate(Decimal daily_rate){
        record.Daily_Rate__c = daily_rate;
        return this;
    }

    public QuoteBuilder setRepaymentType(String repayment_type){
        record.Repayment_Type__c = repayment_type;
        return this;
    }

    public QuoteBuilder setDti(Decimal dti){
        record.DTI__c = dti;
        return this;
    }

    public QuoteBuilder setOneFourthRedemption(Decimal one_fourth_redemption){
        record.X1_4_Redemption__c = one_fourth_redemption;
        return this;
    }

    public QuoteBuilder setTwoFourthRedemption(Decimal two_fourth_redemption){
        record.X2_4_Redemption__c = two_fourth_redemption;
        return this;
    }

    public QuoteBuilder setThreeFourthRedemption(Decimal three_fourth_redemption){
        record.X3_4_Redemption__c = three_fourth_redemption;
        return this;
    }

    public QuoteBuilder setTotalRepayable(Decimal total_repayable){
        record.Total_Repayable__c = total_repayable;
        return this;
    }

    public QuoteBuilder setTotalInterest(Decimal total_interest){
        record.Total_Interest__c = total_interest;
        return this;
    }
}