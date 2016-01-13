///////////////////////////////////
// Copied from Moneywise Org
// 08/09/2014 - Simon Parker
////////////////////////////////////

/**
 * @description     Abstract trigger handler.
 * @author          Will Goulding (william.goulding@comol.co.uk)
 */
public abstract class TriggerHandler {
    /**
     * @description When set to true will prevent the trigger handler being executed more than once
     */
    private static Integer preventRecursiveTrigger_Before=999;
    private static Integer preventRecursiveTrigger_After =999;

    /**
     * @description Used to prevent the trigger handler from being executed more than once
     */
    private static Integer hasExecuted_Before = 0;
    private static Integer hasExecuted_After = 0;


    /**
     * @description This will be called in the trigger before insert event
     * @param newObjects List of new sObjects to be inserted
     */
    public virtual void beforeInsert(List<SObject> newObjects) {}

    /**
     * @description This will be called in the trigger before update event
     * @param oldObjects List of the sObjects being updated with their original values
     * @param newObjects List of the sObjects being updated with their new values
     * @param oldMap Map of the sObjects being updated with their original values
     * @param newMap Map of the sObjects being updated with their new values
     */
    public virtual void beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {}

    /**
     * @description This will be called in the trigger before delete event
     * @param objects List of the sObjects being deleted
     * @param objectsMap Map of the sObjects being deleted
     */
    public virtual void beforeDelete(List<SObject> objects, Map<Id, SObject> objectsMap) {}

    /**
     * @description This will be called in the trigger after insert event
     * @param newObjects List of the sObjects being inserted
     * @param newObjectsMap Map of the sObjects being inserted
     */
    public virtual void afterInsert(List<SObject> newObjects, Map<Id, SObject> newObjectsMap) {}

    /**
     * @description This will be called in the trigger after update event
     * @param oldObjects List of the sObjects being updated with their original values
     * @param newObjects List of the sObjects being updated with their new values
     * @param oldObjectsMap Map of the sObjects being updated with their original values
     * @param newObjectsMap Map of the sObjects being updated with their new values
     */
    public virtual void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldObjectsMap, Map<Id, SObject> newObjectsMap) {}

    /**
     * @description This will be called in the trigger after delete event
     * @param objects List of objects to be deleted
     * @param objectsMap Map of objects to be deleted
     */
    public virtual void afterDelete(List<SObject> objects, Map<Id, SObject> objectsMap) {}

    /**
     * @description This will be called in the trigger after undelete event
     * @param objects List of objects which have been undeleted
     * @param objectsMap Map of objects which have been undeleted
     */
    public virtual void afterUndelete(List<SObject> objects, Map<Id, SObject> objectsMap) {}

    /**
     * @description This will call the relevant method in the trigger handler for the current trigger event
     */
    public void execute()
    {
	    //system.debug('trigger execute ' + hasExecuted_Before + preventRecursiveTrigger_Before +  '   isbefore=' + trigger.isbefore );
        //system.debug('trigger execute ' + hasExecuted_After + preventRecursiveTrigger_After +  '   isafter=' + trigger.isbefore );

        // Control recursive triggers, if required
        if (Trigger.isBefore && hasExecuted_Before >  preventRecursiveTrigger_Before && !Test.isRunningTest()) return;
        if (Trigger.isAfter && hasExecuted_After > preventRecursiveTrigger_After && !Test.isRunningTest()) return;


        if (Trigger.isBefore) hasExecuted_Before ++;
        if (Trigger.isAfter) hasExecuted_After ++;

        //system.debug('Now set to true');
        // Call the relevant trigger event method
        if (Trigger.isBefore) {
            if (Trigger.isDelete) {
                beforeDelete(Trigger.old, Trigger.oldMap);
            }
            else if (Trigger.isInsert) {
                beforeInsert(Trigger.new);
            }
            else if (Trigger.isUpdate) {
                beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
        }
        if(Trigger.IsAfter)
        {
            if (Trigger.isDelete) {
                afterDelete(Trigger.old, Trigger.oldMap);
            }
            else if (Trigger.isInsert) {
                afterInsert(Trigger.new, Trigger.newMap);
            }
            else if (Trigger.isUpdate) {
                afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            else if (Trigger.isUndelete) {
                afterUndelete(Trigger.new, Trigger.newMap);
            }
        }
    }

    /**
     * @description This is called by the child class to prevent the trigger handler being
     *              executed recursively.
     * @param prevent Controls whether the trigger handler can be called recursively
     */
    public void preventRecursiveTrigger_Before(Integer HowManyToAllow)
    {
        HowManyToAllow = (HowManyToAllow != null) ? HowManyToAllow : 999;
        preventRecursiveTrigger_Before = HowManyToAllow;
    }
    public void preventRecursiveTrigger_After(Integer HowManyToAllow)
    {
        HowManyToAllow = (HowManyToAllow != null) ? HowManyToAllow : 999;
        preventRecursiveTrigger_After = HowManyToAllow;
    }

    public Integer getCurrentBeforeTriggerCount(){
        return hasExecuted_Before;
    }

}