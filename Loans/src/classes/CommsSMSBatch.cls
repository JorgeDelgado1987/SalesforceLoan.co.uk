global class CommsSMSBatch implements Database.Batchable<sObject> ,Database.AllowsCallouts, Database.Stateful{

    private List<Customer_Comms_Queue_Item__c> ItemsToUpdate;
    private List<Customer_Comms_Queue_Item__c> ItemsToInsert;
    private Datetime Now = System.now();
    private Datetime SomeTimeAgo;
    String query = 'SELECT Id, Applicant__c, Mobile_Number__c, First_Name__c, Application_Stage__c, Application_Stage_to_Handle__c, '
    + 'Error_Has_Occurred__c, Error_Details__c, Loan_Amount__c, Remote_Template_Name__c, Application_Name__c, Resend_after_hours__c, '
    + 'Applicant__r.Last_Name__c, Applicant__r.Application__r.Name, Applicant__r.Application__r.Loan_Amount__c, '
    + 'Applicant__r.Application__r.Case_Manager__c, Applicant__r.Application__r.Case_Manager__r.FirstName,'
    + 'Send_Date_Time__c, Sent__c, Type__c, Application_Term__c, Applicant__r.Id FROM Customer_Comms_Queue_Item__c '
    + 'WHERE Sent__c = false '
    + 'AND Type__c = \'SMS\' '
    + 'AND Cancelled__c = false '
    + 'AND Send_Date_Time__c != null '
    + 'AND Send_Date_Time__c <= :Now '
    + 'AND Send_Date_Time__c > :SomeTimeAgo '
    + 'AND Manually_Processed__c = false '
    + 'AND Mobile_Number__c != null';

    global CommsSMSBatch() {
        this(2);
    }

    global CommsSMSBatch(Integer hours_to_look_back) {
        SomeTimeAgo = System.now().addHours(-hours_to_look_back);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        ItemsToUpdate = new List<Customer_Comms_Queue_Item__c>();
        ItemsToInsert = new List<Customer_Comms_Queue_Item__c>();
        for(Customer_Comms_Queue_Item__c current_comms_item:(List<Customer_Comms_Queue_Item__c>)scope){
            processSMS(current_comms_item);
        }
        update ItemsToUpdate;
        insert ItemsToInsert;
    }

    public void sendSingleSMS(Id comms_item_id){
        ItemsToUpdate = new List<Customer_Comms_Queue_Item__c>();
        ItemsToInsert = new List<Customer_Comms_Queue_Item__c>();
        Customer_Comms_Queue_Item__c current_comms_item = [SELECT Id, Applicant__c, Mobile_Number__c, First_Name__c,
            Application_Stage__c, Application_Stage_to_Handle__c, Error_Has_Occurred__c, Error_Details__c,
            Loan_Amount__c, Remote_Template_Name__c, Application_Name__c, Resend_after_hours__c, Send_Date_Time__c,
            Sent__c, Type__c, Application_Term__c, Applicant__r.Last_Name__c, Applicant__r.Application__r.Name,
            Applicant__r.Application__r.Loan_Amount__c, Applicant__r.Application__r.Case_Manager__c,
            Applicant__r.Application__r.Case_Manager__r.FirstName,
            Applicant__r.Id FROM Customer_Comms_Queue_Item__c
            WHERE Id = :comms_item_id];
        processSMS(current_comms_item);
        update ItemsToUpdate;
        insert ItemsToInsert;
    }

    private void processSMS(Customer_Comms_Queue_Item__c current_comms_item){
        String response_result;
        current_comms_item.Error_Has_Occurred__c = false;
        current_comms_item.Error_Details__c = null;
        if(current_comms_item.Application_Stage__c == current_comms_item.Application_Stage_to_Handle__c){
            response_result = executeHTTPRequestForSMS(current_comms_item);
        }else{
            response_result = 'Current Application Stage doesn\'t match the Stage to handle';
        }
        handleResponseResult(current_comms_item, response_result);
    }

    private String executeHTTPRequestForSMS(Customer_Comms_Queue_Item__c item){
        List<String> response_body = new List<String>();
        String mobile_phone_number = SMSMessageUtil.formatMobileNumber(item);
        if(mobile_phone_number != null) {
            List<SMS_Template__c> sms_templates = [SELECT Message_Content__c, Sender_ID__c FROM SMS_Template__c WHERE Name =:item.Remote_Template_Name__c];
            if(!sms_templates.isEmpty()){
                try{
                    if(!Test.isRunningTest()) {
                        //Response returned example:
                        //error code|error text|submission reference 0|sms submitted|9d9d779bebc5da7237ba4cfdb0c4b403-3
                        HttpResponse http_response = SMSMessageUtil.processSMS(item, sms_templates, mobile_phone_number);
                        response_body = http_response.getBody().split('\\|');
                    }else{
                        response_body = 'error code|error text|submission reference 0|sms submitted|9d9d779bebc5da7237ba4cfdb0c4b403-3'.split('\\|');
                    }
                }catch(System.CalloutException ex){
                    System.debug(LoggingLevel.ERROR, 'ERROR: Not able Send SMS: ' + ex);
                    item.Error_Has_Occurred__c = true;
                    item.Error_Details__c = ex.getMessage() + ' ' + ex.getCause();
                    //ItemsToUpdate.add(item);
                }
            }else{
                return 'SMS template "' + item.Remote_Template_Name__c + '" not found';
            }
        }else{
            return 'Mobile number is invalid';
        }
        return getResponseResult(response_body);
    }

    private String getResponseResult(List<String> response_body){
        if(response_body != null && response_body.size() > 3){
            return response_body.get(3);
        }else{
            return 'bad response';
        }
    }

    private void scheduleResendIfNeeded(Customer_Comms_Queue_Item__c item){
        if(item.Resend_after_hours__c != null){
            Customer_Comms_Queue_Item__c next_queue_item = CustomerCommsQueueItemBuilder.getBuilder(CustomerCommsQueueItemBuilder.ItemType.SMS, item.Applicant__r)
                .setRemoteTemplateName(item.Remote_Template_Name__c)
                .setSendDateTime(item.Send_Date_Time__c.addHours((Integer)item.Resend_after_hours__c))
                .setResendAfterHours((Integer)item.Resend_after_hours__c)
                .setApplicationStageToHandle(item.Application_Stage_to_Handle__c)
                .getRecord();
            ItemsToInsert.add(next_queue_item);
        }
    }

    private void handleResponseResult(Customer_Comms_Queue_Item__c current_comms_item, String response_result){
        if(response_result == 'sms submitted'){
            current_comms_item.Sent__c = true;
            scheduleResendIfNeeded(current_comms_item);
        }else if(String.isBlank(current_comms_item.Error_Details__c)){
            current_comms_item.Error_Has_Occurred__c = true;
            current_comms_item.Error_Details__c = response_result;
            current_comms_item.Cancelled__c = true;
        }
        ItemsToUpdate.add(current_comms_item);
    }

    global void finish(Database.BatchableContext BC) {
    }
}