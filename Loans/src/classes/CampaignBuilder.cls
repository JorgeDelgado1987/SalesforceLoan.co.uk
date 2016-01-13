public class CampaignBuilder {

    private Campaign Record;

    private CampaignBuilder(String name) {
        Record = new Campaign();
        Record.Name = name;
    }

    public static CampaignBuilder getBuilder(String campaign_name){
        return new CampaignBuilder(campaign_name);
    }

    public CampaignBuilder setAccount(Account account){
        Record.Account__r = account;
        Record.Account__c = account.Id;
        return this;
    }

    public CampaignBuilder save(){
        upsert Record;
        return this;
    }

    public Campaign getRecord(){
        return Record;
    }
}