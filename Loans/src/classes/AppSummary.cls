// *******************************************
// Developer:   Eddie Bates
// Name:        AppSummary
// Created:     19/09/2014
// Description: JIRA SEC-6. This webservice is called from a Custom Button on the App Summary Tab. 
//              It gets a List of Oustanding Items which has Docs Received and updates their Status and Date.
//              It also Updates the Status of the Application they belong to.
// *******************************************
/* +-----------------------------------------------------------------------------------------------------------------------------+
   | Updates                                                                                                                     |
   |-----------------------------------------------------------------------------------------------------------------------------|
   | Developer    Date          Description                                                                                      |
   +-----------------------------------------------------------------------------------------------------------------------------+
    Simon Parker  24/09/2014    Insert ledger entry on PaidOut
    Simon Parker  25/09/2014    Insert ledger entry on Valuation Request
    Simon Parker  29/09/2014    Check for Affiliate Commission and add ledger entry
    Eddie Bates   16/10/2014    Added methods sendSMS & createCCQItem. These create a Customer Comm Queue to send to a Customer
                                and the sendSMS, sends the text using iTagg. Has a dependency on CustomerCommsUtil & SMSMessageUtil
	Eddie Bates 01/11/2014		Added method newQuote. This is used for the Quote Wizard on Skuid Application View. It sets all
								current quotes to inactive and the new Quote remains active
   |-----------------------------------------------------------------------------------------------------------------------------|
*/
   
global with sharing class AppSummary{
      
    webService static String packReceivedButton(Id[] OutstandingItems)
    {

        //Grab OutstandingItems details based on Lender__c
        List <Outstanding_Items__c> OutstandingItemsList = [Select Id, Date_Received__c, Received__c, Application__c
            FROM Outstanding_Items__c WHERE Id IN : OutstandingItems];
                
        Date receivedDate = date.today();
        String applicationId;
        // Loop through the list and update the data for each Outstanding Item and Application
        for(Outstanding_Items__c OutstandingItem : OutstandingItemsList){
                                                
            OutstandingItem.Date_Received__c = receivedDate;
            OutstandingItem.Received__c = true;
            applicationId = OutstandingItem.Application__c;

        }
        
        // Create a savepoint to Rollback on Error
        Savepoint sp = Database.setSavepoint();
        
        try 
        {
            update OutstandingItemsList;
            
            
            //Update Status of Application to Amber if at least one Outstanding Item is receieved   
            Application__c getAppData = [SELECT Id, Status__c FROM Application__c WHERE Id = : applicationId];
            if (getAppData.Status__c != 'Green' && getAppData.Status__c != 'Paid Out'){
                getAppData.Status__c = 'Amber';
                try 
                {
                    update getAppData;                                                          
                } 
                catch (System.DmlException e)
                {                   
                    System.debug('ERROR: Not able to Update Application Status: ' + e);
                    // Rollback
                    Database.rollback(sp);
                    return 'error';
                }
            }
        } 
        catch (System.DmlException e)
        {                   
            System.debug('ERROR: Not able to Update OutstandingItems: ' + e);
            // Rollback
            Database.rollback(sp);
            return 'error';
        }
        
        
        
        //return new ApexPages.Action('{!list}').invoke();      
        return 'complete';
    }
    
    
    webService static String sentToBankButton(String applicationId, Id[] OutstandingItems)
    {        
        // Create a savepoint to Rollback on Error
        Savepoint sp = Database.setSavepoint();
        
        //Declare variables
        Date receivedDate = date.today();
        
        if(!OutstandingItems.isEmpty()) {

            //Grab OutstandingItems details
            List <Outstanding_Items__c> OutstandingItemsList = [Select Id, Date_Received__c, Received__c, Application__c
                FROM Outstanding_Items__c WHERE Id IN : OutstandingItems];
                    
            
            // Loop through the list and update the data for each Outstanding Item and Application
            for(Outstanding_Items__c OutstandingItem : OutstandingItemsList){
                                                    
                OutstandingItem.Date_Received__c = receivedDate;
                OutstandingItem.Received__c = true;             

            }                      
            
            try 
            {
                update OutstandingItemsList;                                               
            } 
            catch (System.DmlException e)
            {                   
                System.debug('ERROR: Not able to Update OutstandingItems: ' + e);
                // Rollback
                Database.rollback(sp);
                return 'error';
            }
        }
        
        //Update Status of Application to Amber if at least one Outstanding Item is receieved           
        Application__c getAppData = [SELECT Id, Status__c, Sent_to_Bank__c FROM Application__c WHERE Id = : applicationId];
        
        if (getAppData.Status__c != 'Paid Out'){
            getAppData.Status__c = 'Green';
            getAppData.Sent_to_Bank__c = receivedDate;
            try 
            {
                update getAppData;                                                          
            } 
            catch (System.DmlException e)
            {                   
                System.debug('ERROR: Not able to Update Application Status: ' + e);
                // Rollback
                Database.rollback(sp);
                return 'error';
            }
        }
        
        return 'complete';
    }
    
    webService static String paidOut(Id[] OutstandingItems)
    {        
        //Grab Application Id
        String applicationId = [Select Application__c
            FROM Outstanding_Items__c WHERE Id IN : OutstandingItems LIMIT 1].Application__c;
                        
        // Create a savepoint to Rollback on Error
        Savepoint sp = Database.setSavepoint();

        
            //Update Status of Application to Amber if at least one Outstanding Item is receieved   
            Application__c getAppData = [SELECT Id, Status__c, Loan_Amount__c,Campaign__r.id, Account__r.Commission_Type__c, Account__r.CPL_Amount__c, Campaign__r.Lead_Cost_Type__c, Campaign__r.CPL_Amount__c, Campaign__r.CPA_Amount_currency__c, Campaign__r.CPA_Amount__c, Campaign__r.Revenue_Share_Amount__c, Account__r.CPA_Amount_currency__c, Account__r.CPA_Amount__c, Account__r.Remuneration_Split__c, Total_Ledger__c FROM Application__c WHERE Id = : applicationId];
            getAppData.Status__c = 'Paid Out';
            Update getAppData;
            
            decimal updated_ledger = getAppData.Total_Ledger__c;
            try 
            {
                update getAppData;                                                          
                //24/09/2014 - code added to insert ledger entry   
                //What - Broker_Fee_c from the 'Quote' object where Active_c is True     
                Ledger__c newLedge = new Ledger__c();
                List<Quote__c> activequotes  = [Select id, Broker_Fee__c from Quote__c WHERE Active__c = true AND Application__c = :applicationId];             

                if (activequotes.size()>0){
                    newLedge.Amount__c = activequotes[0].Broker_Fee__c;
                    if (activequotes[0].Broker_Fee__c != null){
                         updated_ledger += activequotes[0].Broker_Fee__c;
                    }
                    newLedge.Type__c = 'Broker Fee';
                    newLedge.Application__c = applicationId;
                    newLedge.Description__c = 'From Paid Out on Application';
                    newLedge.Transaction_Date_Time__c = system.now();
                    insert newLedge;
                }

                //What - (Plan_Commission_c from row in 'Lender Plan' object that is related to the Quote where Activec is True) * Loan_Amount_c on Application object
                Ledger__c newLedge1 = new Ledger__c();
                List<Quote__c> activequotes1  = [Select id, Broker_Fee__c, Lender_Plan__r.Commission__c from Quote__c WHERE Active__c = true AND Application__c = :applicationId];             

                if (activequotes1.size()>0){
                    If(activequotes1[0].Lender_Plan__r.Commission__c != null){
                        newLedge1.Amount__c = (activequotes1[0].Lender_Plan__r.Commission__c * getAppData.Loan_Amount__c)/100;
                        updated_ledger += (activequotes1[0].Lender_Plan__r.Commission__c * getAppData.Loan_Amount__c)/100;
                    }
                    newLedge1.Type__c = 'Lender Commission';
                    newLedge1.Application__c = applicationId;
                    newLedge1.Description__c = 'From Paid Out on Application';
                    newLedge1.Transaction_Date_Time__c = system.now();
                    insert newLedge1;
                }

                //29/09/2014 - code added to check for Affiliate Commission and add ledger entry
                Decimal ledgeramount = 0;
                if(getAppData.Campaign__r.id == null){ // if no Campaign for the Application, values from the Account
                    if (getAppData.Account__r.Commission_Type__c == 'Cost Per Accept £'){ledgeramount = getAppData.Account__r.CPA_Amount_currency__c;}
                    else if (getAppData.Account__r.Commission_Type__c == 'Cost Per Accept %'){ledgeramount = (getAppData.Account__r.CPA_Amount__c * getAppData.Loan_Amount__c / 100);}
                    else if (getAppData.Account__r.Commission_Type__c == 'Revenue Share'){ledgeramount = (getAppData.Account__r.Remuneration_Split__c * updated_ledger / 100);}
                }

                if(getAppData.Campaign__r.id != null){ // if valid Campaign for the Application, values from the Campaign
                    if (getAppData.Campaign__r.Lead_Cost_Type__c == 'Cost Per Accept £'){ledgeramount = getAppData.Campaign__r.CPA_Amount_currency__c;}
                    else if (getAppData.Campaign__r.Lead_Cost_Type__c == 'Cost Per Accept %'){ledgeramount = (getAppData.Campaign__r.CPA_Amount__c * getAppData.Loan_Amount__c / 100);}
                    else if (getAppData.Campaign__r.Lead_Cost_Type__c == 'Revenue Share'){ledgeramount = (getAppData.Campaign__r.Revenue_Share_Amount__c * updated_ledger / 100);}
                }


                if (ledgeramount != 0){
                    Ledger__c newLedge2 = new Ledger__c();
                    newLedge2.Amount__c = -ledgeramount;
                    newLedge2.Type__c = 'Affiliate Cost';
                    newLedge2.Application__c = applicationId;
                    newLedge2.Description__c = 'Created on Paid Out button';
                    newLedge2.Transaction_Date_Time__c = system.now();
                    insert newLedge2;
                }
            } 
            catch (System.DmlException e)
            {                   
                System.debug('ERROR: Not able to Update Application Status: ' + e);
                // Rollback
                Database.rollback(sp);
                return 'error';
            }    
            
        return 'complete';
    }

    //25/09/2014 - insert ledger entry on Valuation request - Simon Parker
    webService static String payValuationFee(Id[] propertyIds)
    {             
          //Grab Property Id
        String propertyId = propertyIds[0];
        // Create a savepoint to Rollback on Error
        Savepoint sp = Database.setSavepoint();
        try {
                Property__c thisProp = [SELECT Application__r.id, Valuer__c, Valuation_Type__c, Estimated_Value__c FROM Property__c WHERE Id = : propertyId LIMIT 1];
                string applicationId = thisProp.Application__r.id;
                List<Valuation_Plan__c> valuePlans = [Select Name, Valuation_Fee__c from Valuation_Plan__c WHERE Valuer__c = :thisProp.Valuer__c AND Valuation_Type__c = :thisProp.Valuation_Type__c AND Value_Lower_Limit__c < :thisProp.Estimated_Value__c AND Value_Upper_Limit__c >= :thisProp.Estimated_Value__c];
                if (valuePlans.size()>0){
                    Ledger__c newLedge = new Ledger__c();
                    newLedge.Amount__c = -(valuePlans[0].Valuation_Fee__c);
                    newLedge.Type__c = 'Valuation';
                    newLedge.Application__c = applicationId;
                    newLedge.Description__c = 'From Request Valuation on Property';
                    newLedge.Transaction_Date_Time__c = system.now();
                    insert newLedge;

                    return 'complete';
                }
                else{
                    return 'noplan';
                }
            }
              catch (System.DmlException e)
            {                   
                System.debug('ERROR: Not able to Update Application Status: ' + e);
                // Rollback
                Database.rollback(sp);
                return 'error';
            }     

    }
    
	webService static String payValuationFeeUpdate(String property_id, String valuation_valuer, String valuation_type)
    {             
		String propertyValuer = valuation_valuer;
		String propertyValuationType = valuation_type;
		
        // Create a savepoint to Rollback on Error
        Savepoint sp = Database.setSavepoint();
		
		Property__c updateCurrentProperty = [SELECT Application__r.id, Valuer__c, Valuation_Type__c, Estimated_Value__c FROM Property__c WHERE Id = : property_id LIMIT 1];
        updateCurrentProperty.Valuation_Type__c = propertyValuationType;
		updateCurrentProperty.Valuer__c = propertyValuer;
        
        try 
        {
            update updateCurrentProperty;                                                          
        } 
        catch (System.DmlException e)
        {                   
            System.debug('ERROR: Not able to Update other Property Valuation plan: ' + e);
            // Rollback
            Database.rollback(sp);
            return 'error';
        }
					
        try {
                Property__c thisProp = [SELECT Application__r.id, Valuer__c, Valuation_Type__c, Estimated_Value__c FROM Property__c WHERE Id = : updateCurrentProperty.Id LIMIT 1];
                string applicationId = thisProp.Application__r.id;
                List<Valuation_Plan__c> valuePlans = [Select Name, Valuation_Fee__c from Valuation_Plan__c WHERE Valuer__c = :thisProp.Valuer__c AND Valuation_Type__c = :thisProp.Valuation_Type__c AND Value_Lower_Limit__c < :thisProp.Estimated_Value__c AND Value_Upper_Limit__c >= :thisProp.Estimated_Value__c];
                if (valuePlans.size()>0){
                    Ledger__c newLedge = new Ledger__c();
                    newLedge.Amount__c = -(valuePlans[0].Valuation_Fee__c);
                    newLedge.Type__c = 'Valuation';
                    newLedge.Application__c = applicationId;
                    newLedge.Description__c = 'From Request Valuation on Property';
                    newLedge.Transaction_Date_Time__c = system.now();
                    insert newLedge;

                    return 'complete';
                }
                else{
                    return 'noplan';
                }
            }
              catch (System.DmlException e)
            {                   
                System.debug('ERROR: Not able to insert Ledger: ' + e);
                // Rollback
                Database.rollback(sp);
                return 'error';
            }     

    }
    
    /*webService static String sendSMS(String CCQId)
    {                           

        //Get the Communication Details
        Customer_Comms_Queue_Item__c newCCQI = [Select First_Name__c, Mobile_Number__c, Loan_Amount__c from Customer_Comms_Queue_Item__c WHERE Id = : CCQId];           
        
        //Get the SMS Content to Send
        SMS_Template__c smsTemplate = [SELECT Message_Content__c, Sender_ID__c FROM SMS_Template__c WHERE Name = 'iTagg-SMS'];
        
        //Check for a valid Mobile Number from the Applicant
        String MobileNumber = SMSMessageUtil.formatMobileNumber(newCCQI);
        if (MobileNumber == null) {
            return 'invalid mobile number';
        }
        
        System.debug('before httpResponse');
        //Send the SMS Text
        String returnStatus;
        if(!Test.isRunningTest()) {
            try{
            
            HttpResponse httpResponse = SMSMessageUtil.processSMS(newCCQI, smsTemplate, MobileNumber);
            
            //Response returned example:
            //error code|error text|submission reference 0|sms submitted|9d9d779bebc5da7237ba4cfdb0c4b403-3
            
            //Check if the response contains sms submitted
            String[] returnBody = httpResponse.getBody().split('\\|');
            returnStatus = returnBody[3];
            System.debug('after httpResponse');
            System.debug(httpResponse);
                
            } 
            catch (System.CalloutException e){
            
            System.debug('ERROR: Not able Send SMS: ' + e);

            return 'error';
            }
        }
                    
        
        return returnStatus;
    }*/
    
    webService static String createCCQItem(String ApplicantId)
    {               
        //Here the Customer Comm Queue item is created, which will be used to extract the Mobile Number, Text to send etc...
        //Declare variables
        Date receivedDate = date.today();
        
        //Create a new Queue Item
        String CCQId = CustomerCommsUtil.createCCQItem(ApplicantId);
        
        if (CCQId == 'error'){
            return 'error';
        }
        else{
            return CCQId;
        }
                                    
        
    }
    
    webService static String newQuote(String applicationId, String quoteId)
    {                      
        
        List<Quote__c> currentActiveQuotes  = [Select Id from Quote__c WHERE Active__c = true AND Application__c = :applicationId AND Id != :quoteId];             

            if (currentActiveQuotes.size()>0){
				// Loop through the list and grab the data to Update each Quote Item
        		for(Quote__c currentActiveQuoteItem : currentActiveQuotes){
					
					Quote__c updateCurrentActiveQuote = [SELECT Id, Active__c FROM Quote__c WHERE Id = : currentActiveQuoteItem.Id];
	                updateCurrentActiveQuote.Active__c = false;
	                
	                // Create a savepoint to Rollback on Error
	                Savepoint sp = Database.setSavepoint();
	                try 
	                {
	                    update updateCurrentActiveQuote;                                                          
	                } 
	                catch (System.DmlException e)
	                {                   
	                    System.debug('ERROR: Not able to Update other Quotes to False: ' + e);
	                    // Rollback
	                    Database.rollback(sp);
	                    return 'error';
	                }
				}
            }
                    
        return 'complete';
                                    
        
    }
    
}