trigger ApplicantTrigger on Applicant__c (after insert, after update, before insert, before update) {
    ApplicantTriggerHandler triggerHandler = new ApplicantTriggerHandler();
    triggerHandler.execute();
}