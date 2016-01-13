// *******************************************
// Developer:   Eddie Bates
// Name:        GetOutstandingItems
// Created:     04/09/2014
// Description: JIRA SEC-2. getOutstandingItems webservice is called from a Custom Button on the Quote page. 
//              It gets a List of Lender Required Documents on the Lender Object
//              and creates an Outstanding Item for each, and attaches these to
//              the Application related to the Quote
// *******************************************
/* +-----------------------------------------------------------------------------------------------------------------------------+
   | Updates                                                                                                 					 |
   |-----------------------------------------------------------------------------------------------------------------------------|
   | Developer    	Date    	Description                                               										 |
   +-----------------------------------------------------------------------------------------------------------------------------+
	 Eddie Bates  	30/09/2014	JIRA SEC-69. getOutstandingItemRequestType Webservice is called from Skuid Application page under Secured Borrowing Tab.
   								It gets the Request type and creates the related Outstanding
	 							Item(s) and upldates the Application.
    Simon Parker    01/10/2014  JIRA SEC-67. on BSQ/Consent/Mortgage - insert ledger item with fees from Mortgage company record
   |-----------------------------------------------------------------------------------------------------------------------------|
*/
   
global with sharing class GetOutstandingItems{
      
    webService static String getOutstandingItems(String QuoteId)
    {
        //Declare variables
        String LenderFee = [Select Lender_Fee__c from Quote__c WHERE Id = : QuoteId].Lender_Fee__c;
        String ApplicationRef = [Select Application__c from Quote__c WHERE Id = : QuoteId].Application__c;
        String LenderId = [Select Id from Lender__c WHERE Id = : LenderFee].Id;
		String ApplicationStatus = [Select Status__c from Application__c WHERE Id = : ApplicationRef].Status__c;
        
        
        //Grab Lender_Required_Documents details based on Lender__c
        List <Lender_Required_Documents__c> LenderRequiredDocuments = [Select Days_before_Due__c, Days_Before_Requested__c, Item_Name__c, Item_Type__c, Name, Id from Lender_Required_Documents__c 
            WHERE Lender__c =: LenderId];
        
        List<Outstanding_Items__c> outstandingItems = new List<Outstanding_Items__c>();
        
        // Loop through the list and grab the data to create each Outstanding Item
        for(Lender_Required_Documents__c lrd : LenderRequiredDocuments){
            
            Date scheduledDate;
            Date dueDate;
            //Convert decimals to int
            //These will be used to calculate the Scheduled and Due Date later
			
			if(lrd.Days_Before_Requested__c != null){
				Decimal decimalDBR = lrd.Days_Before_Requested__c;
	            Integer intDBR = decimalDBR.intValue();
	            //Get Scheduled Date
				scheduledDate = date.today();
	            scheduledDate = scheduledDate.addDays(intDBR);
			}
	            
			if(lrd.Days_before_Due__c != null){	
	            Decimal decimalDBD = lrd.Days_before_Due__c;
	            Integer intDBD = decimalDBD.intValue();
	            //Get Due Date
	            dueDate = scheduledDate.addDays(intDBD);
			}                                            
            
            Outstanding_Items__c getDocsData = new Outstanding_Items__c();
            
            getDocsData.Item_Name__c = lrd.Item_Name__c;
            getDocsData.Item_Type__c = lrd.Item_Type__c;
            getDocsData.Application__c = ApplicationRef;
        	getDocsData.Scheduled_Date__c = scheduledDate;
			getDocsData.Due_Date__c = dueDate;           
            
            outstandingItems.add(getDocsData);
        }
		
		// Create a savepoint to Rollback on Error
		Savepoint sp = Database.setSavepoint();
		
        try 
        {
            insert outstandingItems;  
			
			//If the Application Status is not equal to Amber set it to Red
			if (ApplicationStatus != 'Amber'){
				Application__c getAppData = [SELECT Id, Status__c FROM Application__c WHERE Id = : ApplicationRef];
				getAppData.Status__c = 'Red';
				
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
            //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record Created Successfully.Thank you!'));
        } 
        catch (System.DmlException e)
        {
            //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Record creation failed: ' + e.getMessage()));
            System.debug('ERROR: Not able to create Outstanding Item: ' + e);
			// Rollback
			Database.rollback(sp);
            return 'error';
        }
        
        //return new ApexPages.Action('{!list}').invoke();      
        return 'complete';
    }

	
	webService static String getOutstandingItemRequestType(String MortgageId, String ApplicationId, String RequestType)
    {	
		//Declare a List to hold Item Names
		List<String> itemNames = new List<String>();
		
		//Get Due Date
		Date dueDate = date.today();
        dueDate = dueDate.addDays(7);
		
		//Get Item Name based on Request Type
		if(RequestType == 'Both'){
			itemNames.add('BSQ');
			itemNames.add('Consent to 2nd Charge');
		}
		else if(RequestType == 'BSQ'){
			itemNames.add('BSQ');
		}
		else if(RequestType == 'Consent'){
			itemNames.add('Consent to 2nd Charge');
		}
		
		// Create a savepoint to Rollback on Error
		Savepoint sp = Database.setSavepoint();
		
		//Create New Outstanding Item
		List<Outstanding_Items__c> outstandingItems = new List<Outstanding_Items__c>();
		
            
		for (String itemName : itemNames) {
			Outstanding_Items__c getDocsData = new Outstanding_Items__c();
		    getDocsData.Item_Name__c = itemName;
            getDocsData.Item_Type__c = 'Mortgage Reference';
            getDocsData.Application__c = ApplicationId;
            getDocsData.Due_Date__c = dueDate;
            
            outstandingItems.add(getDocsData);						
		}
		
		try 
	        {
	            insert outstandingItems;  											
				
				//Update Mortgage Object
				try 
			        {					
						Mortgage__c getMortgageData = [SELECT Id, Request_Type__c, Get_Outstanding_Items__c, Mortgage_Company__r.BSQ_Cost__c, Mortgage_Company__r.Consent_Cost__c FROM Mortgage__c WHERE Id = : MortgageId];
						getMortgageData.Request_Type__c = RequestType;
						getMortgageData.Get_Outstanding_Items__c = true;
								
			            update getMortgageData;  										
			            
						
						//01/10/2014 - create and insert ledger items
			            Decimal ledgerfee1 = 0;
			            Decimal ledgerfee2 = 0;
			            String ledgedesc1 = '';
			            String ledgedesc2 = '';			            
			                        

			            If(RequestType == 'BSQ'){
			                If(getMortgageData.Mortgage_Company__r.BSQ_Cost__c != null){
			                    ledgerfee1 = getMortgageData.Mortgage_Company__r.BSQ_Cost__c;
			                }
			                ledgedesc1 = 'BSQ cost on Application';
			            }

			            If(RequestType == 'Consent'){
			                If(getMortgageData.Mortgage_Company__r.Consent_Cost__c != null){
			                    ledgerfee1 = getMortgageData.Mortgage_Company__r.Consent_Cost__c;
			                }
			                ledgedesc1 = 'Consent cost on Application';
			            }
			            If(RequestType == 'Both'){
			                ledgerfee1 = getMortgageData.Mortgage_Company__r.BSQ_Cost__c;
			                ledgerfee2 = getMortgageData.Mortgage_Company__r.Consent_Cost__c;
			                ledgedesc1 = 'BSQ cost on Application';
			                ledgedesc2 = 'Consent cost on Application';
			            }

			            If (ledgedesc1 != ''){
			                Ledger__c newLedge1 = new Ledger__c();
			                newLedge1.Amount__c = -ledgerfee1;
			                newLedge1.Type__c = 'Mortgage Reference';
			                newLedge1.Application__c = ApplicationId;
			                newLedge1.Description__c = ledgedesc1;
			                newLedge1.Transaction_Date_Time__c = system.now();
							
							try{
								
								insert newLedge1;
							}
							catch (System.DmlException e)
					        {		            
					            System.debug('ERROR: Not able to Insert newLedge1: ' + e);
								// Rollback
								Database.rollback(sp);
					            return 'error';
					        }
			                
			            }

			             If (ledgedesc2 != ''){
			                Ledger__c newLedge2 = new Ledger__c();
			                newLedge2.Amount__c = -ledgerfee2;
			                newLedge2.Type__c = 'Mortgage Reference';
			                newLedge2.Application__c = ApplicationId;
			                newLedge2.Description__c = ledgedesc2;
			                newLedge2.Transaction_Date_Time__c = system.now();
							 
							try{
								
								insert newLedge2;
							}
							catch (System.DmlException e)
					        {		            
					            System.debug('ERROR: Not able to Insert newLedge2: ' + e);
								// Rollback
								Database.rollback(sp);
					            return 'error';
					        }
			                
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
	        catch (System.DmlException e)
	        {
	            //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Record creation failed: ' + e.getMessage()));
	            System.debug('ERROR: Not able to create Outstanding Item: ' + e);
				// Rollback
				Database.rollback(sp);
	            return 'error';
	        }

            
		    
        return 'complete';
    }
}