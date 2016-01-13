global class CommsEmailBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    private final DateTime MINS_IN_FUTURE_30 = DateTime.now().addMinutes(30);
    private final DateTime MINS_IN_PAST_30 = DateTime.now().addMinutes(-30);
    String type = 'Email';
    String query = 'Select Id, Applicant__c, Email__c, First_Name__c, Application_Stage__c, '
    + 'Error_Has_Occurred__c, Loan_Amount__c, Remote_Template_Name__c, Application_Name__c, '
    + 'Send_Date_Time__c, Sent__c, Type__c, Application_Term__c from Customer_Comms_Queue_Item__c '
    + 'Where Sent__c = false '
    + 'AND Type__c = :type';

    global CommsEmailBatch() {}

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Customer_Comms_Queue_Item__c> items_to_update = new List<Customer_Comms_Queue_Item__c>();
        for(Customer_Comms_Queue_Item__c item:(List<Customer_Comms_Queue_Item__c>)scope){
            if(String.isNotBlank(item.Email__c) && item.Application_Stage__c == 'Call for full app'
                && item.Send_Date_Time__c < MINS_IN_FUTURE_30 && item.Send_Date_Time__c > MINS_IN_PAST_30) {
                try{
                    CommsEmailService.Recipient recipient = new CommsEmailService.Recipient(item.Email__c).setName(item.First_Name__c);
                    recipient.setMergeData('FirstName',item.First_Name__c);
                    recipient.setMergeData('ApplicationName',item.Application_Name__c);
                    recipient.setMergeData('ApplicationLoanAmount',item.Loan_Amount__c.setScale(0));
                    recipient.setMergeData('ApplicationLoanTermMonths',item.Application_Term__c.setScale(0));
                    CommsEmailService.Template template = new CommsEmailService.Template(item.Remote_Template_Name__c, false);

                    CommsEmailService.SendResult emailSendResult = CommsEmailService.sendEmailNow(recipient, template);
                    if(emailSendResult.IsSuccess()){
                        item.Sent__c = true;
                        items_to_update.add(item);
                    } else {
                        item.Error_Has_Occurred__c = true;
                        String error_string = '';
                        for(String s:emailsendResult.getErrors()){
                            item.Error_Details__c += s;
                        }
                        items_to_update.add(item);
                    }
                }
                catch (Exception ex) {
                    item.Error_Has_Occurred__c = true;
                    item.Error_Details__c = ex.getMessage() + ' ' + ex.getCause();
                    items_to_update.add(item);
                }
            }
        }
        if(!items_to_update.isEmpty()){
            try{
                update items_to_update;
            } catch (Exception ex){
                System.debug('Error: ' + ex.getMessage() + ex.getCause());
            }
        }
    }

    global void finish(Database.BatchableContext BC) {

    }

}