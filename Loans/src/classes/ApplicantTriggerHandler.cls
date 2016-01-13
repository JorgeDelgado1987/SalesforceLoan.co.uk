public without sharing  class ApplicantTriggerHandler extends TriggerHandler{

    /////////////////////////////////////////////////////
    // Copied from Moneywise Org
    // 08/09/2014 - Simon Parker
    ////////////////////////////////////////////////////

    public static Boolean IsRecursiveUpdate = false;

    public ApplicantTriggerHandler(){
        // Allow both before and after triggers
        preventRecursiveTrigger_after(999);
        preventRecursiveTrigger_Before(999);
    }

    public override void beforeInsert(List<SObject> newObjects){
        List<Applicant__c> newApplicants = (List<Applicant__c>)newObjects;
        setIsPrimaryApplicantForNewApplicant(newApplicants);

    }

    public override void afterInsert(List<SObject> newObjects, Map<Id, SObject> newObjectsMap){
        List<Applicant__c> newApplicants = (List<Applicant__c>)newObjects;
        //CopySurnametoApplication(newApplicants);
        List<Applicant__c> apps = [Select id, Date_of_Birth__c,Mobile_Phone__c, Home_phone__c,Last_Name__c,First_Name__c, Email_address__c, PostCode__c from Applicant__c WHERE id IN :newObjectsMap.keySet()];
        neworexistingCustomer(apps);
        sendWelcomeEmail(newObjectsMap.keySet());
        sendWelcomeSMS(newObjectsMap.keySet());
        sendLoanCoUKChase1(newObjects);
    }

    /// *************************************************************************************************************************************************
    /// ************************************* Sub Methods Below Here ************************************************************************************
    /// *************************************************************************************************************************************************

    private void setIsPrimaryApplicantForNewApplicant(List<Applicant__c> new_applicant_list){
        Map<Id,List<Applicant__c>> application_id_to_applicant = new Map<Id,List<Applicant__c>>();
        for(Applicant__c applicant:new_applicant_list){
            if(!application_id_to_applicant.containsKey(applicant.Application__c)){
                application_id_to_applicant.put(applicant.Application__c, new List<Applicant__c>());
            }
            application_id_to_applicant.get(applicant.Application__c).add(applicant);
        }

        List<Application__c> applications_for_update = new List<Application__c>();

        for(Application__c application:[Select Id, Lead_Applicant_Name__c, (Select Id, Last_Name__c, Is_Primary__c, CreatedDate from Applicants__r ORDER By CreatedDate ASC) from Application__c Where Id IN:application_id_to_applicant.keySet()]){
            if(application.Applicants__r.isEmpty()){
                if(application_id_to_applicant.containsKey(application.Id)){
                    if(!application_id_to_applicant.get(application.Id).IsEmpty()){
                        application_id_to_applicant.get(application.Id).get(0).Is_Primary__c = true;
                        application.Lead_Applicant_Name__c = application_id_to_applicant.get(application.Id).get(0).Last_Name__c;
                        application.Lead_Applicant_Email__c = application_id_to_applicant.get(application.Id).get(0).Email_Address__c;
                        applications_for_update.add(application);
                    }
                }
            }
        }

        update applications_for_update;
    }

    /*private void CopySurnametoApplication(List<Applicant__c> newApplicants){
        // modified from original stand-alone trigger for handler and bulkified
        Map<Id, String> mapApplicanttoLastName = new Map<Id, String>();
        Map<Id, Id> mapApplicationtoApplicant = new Map<Id, Id>();
        Set<Id> newApplicantsIds = (new Map<Id,SObject>(newApplicants)).keySet();
        List<Applicant__c> theApplicants = [Select id, Last_Name__c, Application__r.id from Applicant__c WHERE id in:newApplicantsIds];

        for (Applicant__c newapp : theApplicants){
            mapApplicanttoLastName.put(newapp.Id, newapp.Last_Name__c);
            mapApplicationtoApplicant.put(newapp.Application__r.Id, newapp.Id);
        }

        Set<Id> relatedApplicationsIDs = mapApplicationtoApplicant.keySet();

        List<Application__c> relatedApplications = [Select id,Lead_Applicant_Name__c from Application__c WHERE id IN :relatedApplicationsIDs];

        for (Application__c appl : relatedApplications){
            if (appl.Lead_Applicant_Name__c != '' && appl.Lead_Applicant_Name__c != null){
                continue;
            }
            else{
                appl.Lead_Applicant_Name__c = mapApplicanttoLastName.get(mapApplicationtoApplicant.get(appl.id));
            }
        }
        update relatedApplications;
    }*/

    // Sets either matching or new customer Id for new List of Applicant
    public Void neworexistingCustomer (List<Applicant__c> newapps){
        for (Applicant__c a : newapps){
            Id customerid = findMatchingCustomerID(a);
            if (customerid ==null){
                Customer__c c = new Customer__c();
                c.Last_Name__c = a.Last_Name__c;
                c.First_Name__c = a.First_Name__c;
                c.Date_of_Birth__c = a.Date_of_Birth__c;
                c.Email_Address__c = a.Email_address__c;
                c.Home_Phone__c = a.Home_phone__c;
                c.Mobile_Number__c = a.Mobile_Phone__c;
                c.PostCode__c = a.PostCode__c;
                insert c;
                customerid = c.id;
            }
        a.Customer__c = customerid;
        }
        update newapps;
    }


    // Customer Check - looks for matching Customer from an Applicant and returns relevant Customer id
    public static Id findMatchingCustomerID(Applicant__c applicant) {
        //  Clean up some data
        String cleanMobilePhone = null;
        if (String.isNotBlank(applicant.Mobile_Phone__c)) {
            cleanMobilePhone = applicant.Mobile_Phone__c.trim();
            cleanMobilePhone = cleanMobilePhone.deleteWhitespace();
        }

        String cleanHomePhone = null;
        if (String.isNotBlank(applicant.Home_Phone__c)) {
            cleanHomePhone = applicant.Home_Phone__c.trim();
            cleanHomePhone = cleanHomePhone.deleteWhitespace();
        }


        //   Step 1 - Check for Email matches
        List<Customer__c> matchingEmailCustomers = [
            SELECT id
            FROM Customer__c
            WHERE (Email_Address__c != null AND Email_Address__c = :applicant.Email_Address__c)
            ORDER BY LastModifiedDate DESC
            LIMIT :Limits.getLimitQueryRows()];

        if (matchingEmailCustomers.size() > 0) {
            Customer__c matchingCustomer = matchingEmailCustomers.get(0);


            return matchingCustomer.id;
        }

        //  Step 2 - Check for Mobile Phone matches
        List<Customer__c> matchingMobilePhoneCustomers = [
            SELECT id
            FROM Customer__c
            WHERE (Mobile_Number__c != null AND Mobile_Number__c = :cleanMobilePhone)
            ORDER BY LastModifiedDate DESC
            LIMIT :Limits.getLimitQueryRows()
        ];

        if (matchingMobilePhoneCustomers.size() > 0) {
            Customer__c matchingCustomer = matchingMobilePhoneCustomers.get(0);
            return matchingCustomer.id;
        }

        //  Step 3 - Check for Home Phone matches
        List<Customer__c> matchingHomePhoneCustomers = [
            SELECT id
            FROM Customer__c
            WHERE (
                    (Home_Phone__c != null AND Home_Phone__c = :cleanHomePhone)
                    AND (Last_Name__c != null AND Last_Name__c = :applicant.Last_Name__c)
                    AND (Date_of_Birth__c != null AND Date_of_Birth__c = :applicant.Date_of_Birth__c)
                )
            ORDER BY LastModifiedDate DESC
            LIMIT :Limits.getLimitQueryRows()
        ];

        if (matchingHomePhoneCustomers.size() > 0) {
            Customer__c matchingCustomer = matchingHomePhoneCustomers.get(0);
            return matchingCustomer.id;
        }

        //  Step 4 - Check for other matches
        List<Customer__c> matchingOtherCustomers = [
            SELECT id
            FROM Customer__c
            WHERE (Last_Name__c != null AND Last_Name__c = :applicant.Last_Name__c)
                AND (PostCode__c != null AND PostCode__c = :applicant.PostCode__c)
                AND (Date_of_Birth__c != null AND Date_of_Birth__c = :applicant.Date_of_Birth__c)
            ORDER BY LastModifiedDate DESC
            LIMIT :Limits.getLimitQueryRows()
        ];

        if (matchingOtherCustomers.size() > 0) {
            Customer__c matchingCustomer = matchingOtherCustomers.get(0);
            return matchingCustomer.id;
        }

        return null;

    }

    @future (callout=true)
    public static void sendWelcomeEmail(Set<Id> newApplicantIds){
        for(Applicant__c theApplicant : [Select Id, Applicant_Index__c, Application__r.Receive_Loan_co_uk_Welcome_Email__c, Application__r.Name, Application__r.Loan_Amount__c, Application__r.Loan_Term_Months__c, Email_Address__c, First_Name__c, Last_Name__c from Applicant__c where Id IN:newApplicantIds]){
            if(theApplicant.Email_Address__c != null && theApplicant.Application__r.Receive_Loan_co_uk_Welcome_Email__c == true && theApplicant.Applicant_Index__c ==1){
                try{
                    CommsEmailService.Recipient recipient = new CommsEmailService.Recipient(theApplicant.Email_Address__c).setName(theApplicant.First_Name__c + ' ' + theApplicant.Last_Name__c);
                    recipient.setMergeData('FirstName',theApplicant.First_Name__c);
                    recipient.setMergeData('ApplicationName',theApplicant.Application__r.Name);
                    recipient.setMergeData('ApplicationLoanAmount',theApplicant.Application__r.Loan_Amount__c);
                    recipient.setMergeData('ApplicationLoanTermMonths',theApplicant.Application__r.Loan_Term_Months__c);
                    CommsEmailService.Template template = new CommsEmailService.Template('loan-co-uk-welcome-email', false);

                    CommsEmailService.SendResult emailSendResult = CommsEmailService.sendEmailNow(recipient, template);
                    if(!emailSendResult.IsSuccess()){
                        System.debug('Error: Unable to send Email the Following Errors Occurred');
                        for(String s:emailsendResult.getErrors()){
                            System.debug('Error: ' + s);
                        }
                    }
                }
                catch (Exception ex) {
                    System.debug('ERROR: Not able to sendWelcomeEmail: ' + ex);
                }
            }
        }
    }

    public static void sendWelcomeSMS(Set<Id> new_applicant_ids){
        List<Applicant__c> new_applicants = [SELECT Id, CreatedDate FROM Applicant__c WHERE Id IN :new_applicant_ids
            AND Mobile_Phone__c != null AND Application__r.Business__c = 'Loan.co.uk' AND Is_Primary__c = true
            AND Application__r.Account__r.Receive_Chase_SMS__c = true];
        List<Customer_Comms_Queue_Item__c> new_welcome_sms_items = new List<Customer_Comms_Queue_Item__c>();
        List<Customer_Comms_Queue_Item__c> new_repeating_sms_items = new List<Customer_Comms_Queue_Item__c>();
        for(Applicant__c applicant:new_applicants){
            Customer_Comms_Queue_Item__c welcome_sms_1 = CustomerCommsQueueItemBuilder.getBuilder(CustomerCommsQueueItemBuilder.ItemType.SMS, applicant)
                .setRemoteTemplateName('loan-co-uk-welcome-sms-1')
                .setSendDateTime(System.now())
                .setApplicationStageToHandle('Call for full app')
                .setManuallyProcessed(true)
                .getRecord();
            new_welcome_sms_items.add(welcome_sms_1);

            Customer_Comms_Queue_Item__c fullapp_repeating_sms = CustomerCommsQueueItemBuilder.getBuilder(CustomerCommsQueueItemBuilder.ItemType.SMS, applicant)
                .setRemoteTemplateName('loan-co-uk-fullapp-repeating')
                .setSendDateTime(applicant.CreatedDate.addDays(1))
                .setResendAfterHours(24)
                .setApplicationStageToHandle('Call for full app')
                .getRecord();
            new_repeating_sms_items.add(fullapp_repeating_sms);
        }
        insert new_welcome_sms_items;
        insert new_repeating_sms_items;

        for(Customer_Comms_Queue_Item__c welcome_sms:new_welcome_sms_items){
            processSingleWelcomeSMS(welcome_sms.Id);
        }
    }

    @future(callout=true)
    private static void processSingleWelcomeSMS(Id sms_id){
        CommsSMSBatch sender = new CommsSMSBatch();
        sender.sendSingleSMS(sms_id);
    }

    public void sendLoanCoUKChase1(List<SObject> applicants){
         for(Applicant__c theApplicant:(List<Applicant__c>)applicants){
            try{
                CommsEmailService.Recipient recipient = new CommsEmailService.Recipient(theApplicant);
                CommsEmailService.Template template = new CommsEmailService.Template('loan-co-uk-application-chase-1', false);
                CommsEmailService.Schedule schedule = new CommsEmailService.Schedule(DateTime.now().addDays(6));
                CommsEmailService.SendResult emailSendResult = CommsEmailService.sendEmailLater(recipient, template, schedule);
                if(!emailSendResult.IsSuccess()){
                    System.debug('Error: Unable to send Email the Following Errors Occurred');
                    for(String s:emailsendResult.getErrors()){
                        System.debug('Error: ' + s);
                    }
                }
            }
            catch (Exception ex) {
                System.debug('ERROR: Not able to sendWelcomeEmail: ' + ex);
            }
        }
    }

}