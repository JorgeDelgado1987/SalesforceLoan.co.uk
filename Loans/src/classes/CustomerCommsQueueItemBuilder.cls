public class CustomerCommsQueueItemBuilder {

    public enum ItemType{SMS, EMAIL}
    private Customer_Comms_Queue_Item__c Record;

    private CustomerCommsQueueItemBuilder(ItemType type, Applicant__c applicant) {
        Record = new Customer_Comms_Queue_Item__c();
        Record.Type__c = type.name();
        Record.Applicant__c = applicant.Id;
        Record.Applicant__r = applicant;
    }

    public static CustomerCommsQueueItemBuilder getBuilder(ItemType type, Applicant__c applicant){
        return new CustomerCommsQueueItemBuilder(type, applicant);
    }

    public CustomerCommsQueueItemBuilder setRemoteTemplateName(String name){
        Record.Remote_Template_Name__c = name;
        return this;
    }

    public CustomerCommsQueueItemBuilder setSendDateTime(DateTime send_date_time){
        Record.Send_Date_Time__c = send_date_time;
        return this;
    }

    public CustomerCommsQueueItemBuilder setResendAfterHours(Integer hours){
        Record.Resend_after_hours__c = hours;
        return this;
    }

    public CustomerCommsQueueItemBuilder setApplicationStageToHandle(String stage_name){
        Record.Application_Stage_to_Handle__c = stage_name;
        return this;
    }

    public CustomerCommsQueueItemBuilder setManuallyProcessed(Boolean manually_processed){
        Record.Manually_Processed__c = manually_processed;
        return this;
    }

    public CustomerCommsQueueItemBuilder save(){
        upsert Record;
        return this;
    }

    public Customer_Comms_Queue_Item__c getRecord(){
        return Record;
    }

}