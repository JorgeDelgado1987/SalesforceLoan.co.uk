public class ApplicationBuilder {

    private Application__c Record;

    private ApplicationBuilder(Account account) {
        Record = new Application__c();
        Record.Account__c = account.Id;
        Record.Account__r = account;
    }

    public static ApplicationBuilder getBuilder(Account account){
        return new ApplicationBuilder(account);
    }

    public ApplicationBuilder setCRSReportId(String report_id){
        Record.CRS_Report_Id__c = report_id;
        return this;
    }

    public ApplicationBuilder setCampaign(Campaign campaign){
        Record.Campaign__r = campaign;
        Record.Campaign__c = campaign.Id;
        return this;
    }

    public ApplicationBuilder setLoanAmount(Decimal loan_amount){
        Record.Loan_Amount__c = loan_amount;
        return this;
    }

    public ApplicationBuilder setApplicationType(String application_type){
        Record.Application_Type__c = application_type;
        return this;
    }

    public ApplicationBuilder setLoanTermMonths(Integer loan_term){
        Record.Loan_Term_Months__c = loan_term;
        return this;
    }

    public ApplicationBuilder setBrokerFee(Decimal broker_fee){
        Record.Broker_Fee__c = broker_fee;
        return this;
    }

    public ApplicationBuilder setKeyword(String keyword){
        Record.Keyword__c = keyword;
        return this;
    }

    public ApplicationBuilder setMatchType(String match_type){
        Record.Match_Type__c = match_type;
        return this;
    }

    public ApplicationBuilder setPPCCampaign(String campaign_id){
        Record.PPC_Campaign__c = campaign_id;
        return this;
    }

    public ApplicationBuilder setApplicationValue(Decimal value){
        Record.Application_Value__c = value;
        return this;
    }

    public ApplicationBuilder setBusiness(String business){
        Record.Business__c = business;
        return this;
    }

    public ApplicationBuilder save(){
        upsert Record;
        return this;
    }

    public Application__c getRecord(){
        return Record;
    }
}