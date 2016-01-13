global class SKUIDSendSingleSMS {
    webservice static void send(Id applicant_id, String template_name, String application_stage){
        Id new_sms_id = generateNewCommsItem(applicant_id, template_name, application_stage);
        sendSingleSMS(new_sms_id);
    }

    private static Id generateNewCommsItem(Id applicant_id, String template_name, String application_stage){
        Applicant__c selected_applicant = [SELECT Id, CreatedDate FROM Applicant__c WHERE Id=:applicant_id];
        Customer_Comms_Queue_Item__c new_sms = CustomerCommsQueueItemBuilder.getBuilder(CustomerCommsQueueItemBuilder.ItemType.SMS, selected_applicant)
            .setRemoteTemplateName(template_name)
            .setSendDateTime(System.now())
            .setApplicationStageToHandle(application_stage)
            .setManuallyProcessed(true)
            .getRecord();
        insert new_sms;
        System.debug(new_sms);
        return new_sms.Id;
    }

    @future(callout=true)
    private static void sendSingleSMS(Id sms_id){
        CommsSMSBatch sender = new CommsSMSBatch();
        sender.sendSingleSMS(sms_id);
    }
}