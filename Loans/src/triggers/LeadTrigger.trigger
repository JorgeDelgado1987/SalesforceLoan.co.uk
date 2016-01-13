trigger LeadTrigger on Lead (after insert, after update, before insert, before update){
    LeadTriggerHandler handler = new LeadTriggerHandler();
    handler.execute();
}