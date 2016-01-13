trigger ApplicationTrigger on Application__c (after insert, after update, before insert, before update) 
{
	ApplicationTriggerHandler triggerHandler = new ApplicationTriggerHandler();
    triggerHandler.execute();
}