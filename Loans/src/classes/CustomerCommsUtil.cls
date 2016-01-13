public with sharing class CustomerCommsUtil{

    public static String createCCQItem(String ApplicantId) {
        // Create a savepoint to Rollback on Error
        Savepoint sp = Database.setSavepoint();

        //Declare variables
        Date receivedDate = date.today();

        System.debug('sendSMS');

        //Create a new Queue Item
        Customer_Comms_Queue_Item__c customer_comms_queue_item = new Customer_Comms_Queue_Item__c();
        customer_comms_queue_item.Applicant__c = ApplicantId;

        try
        {
            insert customer_comms_queue_item;
        }
          catch (System.DmlException e)
        {
            System.debug('ERROR: Not able to insert Customer_Comms_Queue_Item__c: ' + e);
            // Rollback
            Database.rollback(sp);
            return 'error';
        }

        return customer_comms_queue_item.Id;
    }

    public static String createScheduledCCQItem(String ApplicantId, Datetime scheduled_job_time, String template_name) {
        // Create a savepoint to Rollback on Error
        Savepoint sp = Database.setSavepoint();

        //Declare variables
        Date receivedDate = date.today();

        System.debug('sendSMS');

        //Create a new Queue Item
        Customer_Comms_Queue_Item__c customer_comms_queue_item = new Customer_Comms_Queue_Item__c();
        customer_comms_queue_item.Applicant__c = ApplicantId;
        customer_comms_queue_item.Send_Date_Time__c = scheduled_job_time;
        customer_comms_queue_item.Type__c = 'SMS';
        customer_comms_queue_item.Remote_Template_Name__c = template_name;

        try
        {
            insert customer_comms_queue_item;
        }
          catch (System.DmlException e)
        {
            System.debug('ERROR: Not able to insert Customer_Comms_Queue_Item__c: ' + e);
            // Rollback
            Database.rollback(sp);
            return 'error';
        }

        return customer_comms_queue_item.Id;
    }

}