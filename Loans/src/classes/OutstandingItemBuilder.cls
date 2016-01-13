public with sharing class OutstandingItemBuilder {
	 
	private Outstanding_Items__c record;

    private OutstandingItemBuilder(Application__c application) {
        this.record = new Outstanding_Items__c();
        record.Application__c = application.Id;
        record.Application__r = application;
    }

    public static OutstandingItemBuilder getBuilder(Application__c application){
        return new OutstandingItemBuilder(application);
    }

    public Outstanding_Items__c getRecord(){
        return record;
    }

    public OutstandingItemBuilder save(){
        upsert record;
        return this;
    }
}