public class LeadTriggerHandler extends TriggerHandler{

    public override void afterInsert(List<SObject> new_objects, Map<Id, SObject> new_objects_map){
        LeadCreateRelatedRecords.executeList((List<Lead>)new_objects);
    }
}