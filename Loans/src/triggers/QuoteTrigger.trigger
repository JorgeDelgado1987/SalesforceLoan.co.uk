trigger QuoteTrigger on Quote__c (after insert, after update, before insert, before update) {
	QuoteTriggerHandler triggerHandler = new QuoteTriggerHandler();
    triggerHandler.execute();
}