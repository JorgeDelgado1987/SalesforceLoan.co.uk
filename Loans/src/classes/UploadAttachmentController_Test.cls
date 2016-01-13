@isTest
// *******************************************
// Developer:   Eddie Bates
// Name:        UploadAttachmentController_Test
// Created:     12/09/2014
// Description: JIRA SEC-52. This is a Test Case for UploadAttachmentController
// *******************************************
/* +-----------------------------------------------------------------------------------------------------------------------------+
   | Updates                                                                                                                     |
   |-----------------------------------------------------------------------------------------------------------------------------|
   | Developer    Date    Description                                                                                            |
   +-----------------------------------------------------------------------------------------------------------------------------+
   
   |-----------------------------------------------------------------------------------------------------------------------------|
*/
   
private class UploadAttachmentController_Test {
    static testMethod void testProcessUploadandBackPass() {
        // Success Test
        
        //Create Account
        Account oAccount = new Account();
        oAccount.Name = 'Loans & Mortgages';
        oAccount.Business__c = 'Loan.co.uk';
        oAccount.Affiliate_ID__c = 'SAMLOAN';        
        insert oAccount;        
        
        //Create Lender
        Lender__c oLender = new Lender__c();
        oLender.Active__c = true;
        oLender.Name = 'Test Lender';        
        insert oLender;
                
        //Create New Lender Required Documents
        Lender_Required_Documents__c oLenderRequiredDocs = new Lender_Required_Documents__c();
        oLenderRequiredDocs.Item_Name__c = 'Application Form';
        oLenderRequiredDocs.Item_Type__c = 'Lender Document';
        oLenderRequiredDocs.Days_before_Due__c = 7.00;
        oLenderRequiredDocs.Days_Before_Requested__c = 0.00;
        oLenderRequiredDocs.Lender__c = oLender.Id;        
        insert oLenderRequiredDocs;             
        
        //Create Application
        Application__c oApplication = new Application__c();
        oApplication.Status__c = 'White';
        oApplication.Sub_Status__c = 'Application';
        oApplication.Loan_Amount__c = 100000.00;
        oApplication.Business__c = 'Loan.co.uk';
        oApplication.Account__c = oAccount.Id;
        oApplication.Application_Type__c = 'Secured Loan';
        oApplication.Loan_Purpose__c = 'Business';
        oApplication.Loan_Term_Months__c = 48.00;
        oApplication.Lead_Applicant_Name__c = 'Joe Bloggs';     
        //oApplication.Lender__c = oLender.Id;        
        insert oApplication;
                    
        //Create Applicant
        Applicant__c oApplicant = new Applicant__c();
        oApplicant.First_Name__c = 'Joe';
        oApplicant.Last_Name__c = 'Bloggs';
        oApplicant.Marital_Status__c = 'Married';
        oApplicant.Email_Address__c = 'joebloggs@hotmail.com';
        oApplicant.Home_Phone__c = '002890777888';
        oApplicant.Mobile_Phone__c = '07775558899';
        oApplicant.Employment_Status__c = 'Full Time Employment';
        oApplicant.Time_in_Employment_Months__c = '6';
        oApplicant.Time_in_Employment_Years__c = '3';
        oApplicant.Gross_Monthly_Income__c = 4000.00;
        oApplicant.Application__c = oApplication.Id;        
        insert oApplicant;                      
        
        //Create Quote
        Quote__c oQuote = new Quote__c();
        oQuote.Active__c = true;
        oQuote.Application__c = oApplication.Id;
        oQuote.Lender_Fee__c = oLender.Id;
        oQuote.Name = 'Quote 1';        
        insert oQuote;
        
        // *******************************************
        // Create Outstanding Items
        // *******************************************
        
        //Declare variables
        String LenderFee = oQuote.Lender_Fee__c;
        String ApplicationRef = oQuote.Application__c;
        String LenderId = oLender.Id;
        
        
        //Grab Lender_Required_Documents details based on Lender__c
        List <Lender_Required_Documents__c> LenderRequiredDocuments = [Select Days_before_Due__c, Days_Before_Requested__c, Item_Name__c, Item_Type__c, Name, Id from Lender_Required_Documents__c 
            WHERE Lender__c =: LenderId];
        
        List<Outstanding_Items__c> outstandingItems = new List<Outstanding_Items__c>();
        
        // Loop through the list and grab the data to create each Outstanding Item
        for(Lender_Required_Documents__c lrd : LenderRequiredDocuments){
            
            Date scheduledDate = date.today();
            
            //Convert decimals to int
            //These will be used to calculate the Scheduled and Due Date later
            Decimal decimalDBR = lrd.Days_Before_Requested__c;
            Integer intDBR = decimalDBR.intValue();
            
            Decimal decimalDBD = lrd.Days_before_Due__c;
            Integer intDBD = decimalDBD.intValue();
            
            
            //Get Scheduled Date
            scheduledDate = scheduledDate.addDays(intDBR);                      
            //Get Due Date
            Date dueDate = scheduledDate.addDays(intDBD);
            
            Outstanding_Items__c getDocsData = new Outstanding_Items__c();
            
            getDocsData.Item_Name__c = lrd.Item_Name__c;
            getDocsData.Item_Type__c = lrd.Item_Type__c;
            getDocsData.Application__c = ApplicationRef;
            getDocsData.Scheduled_Date__c = scheduledDate;
            getDocsData.Due_Date__c = dueDate;
            
            outstandingItems.add(getDocsData);
        }   
        
        insert outstandingItems;  
        
        Outstanding_Items__c oOutstandingItems = [SELECT Id From Outstanding_Items__c LIMIT 1];
        
        // *******************************************
        // Test processUpload method
        // *******************************************
        PageReference UploadAttachment= Page.UploadAttachment;
        UploadAttachment.getParameters().put('description','description');
        Test.setCurrentPage(UploadAttachment);
        
        ApexPAges.StandardController stdController = new ApexPages.StandardController(oOutstandingItems);  
        UploadAttachmentController controller = new UploadAttachmentController(stdController);
        
        controller.fileBody=Blob.valueof('Unit test blob');
        controller.fileName='UnitTest.txt';
        
        PageReference sResponseProcessUpload = controller.processUpload();
            
        System.assertNotEquals(null, sResponseProcessUpload);   
        System.assert(sResponseProcessUpload.getUrl().startsWithIgnoreCase('/'+ApplicationRef));
        
        // *******************************************
        // Test back method  
        // *******************************************
        PageReference sResponseBack = controller.back();
            
        System.assertNotEquals(null, sResponseBack);    
        System.assert(sResponseBack.getUrl().startsWithIgnoreCase('/'+ApplicationRef));
    }
        
    
    static testMethod void testProcessUploadFail() {
        // This is a fail test as the Attachment has no fileBody or fileName                
        
        //Create Account
        Account oAccount = new Account();
        oAccount.Name = 'Loans & Mortgages';
        oAccount.Business__c = 'Loan.co.uk';
        oAccount.Affiliate_ID__c = 'SAMLOAN';        
        insert oAccount;
        
        //Create Lender
        Lender__c oLender = new Lender__c();
        oLender.Active__c = true;
        oLender.Name = 'Test Lender';        
        insert oLender;
        
        //Create New Lender Required Documents
        Lender_Required_Documents__c oLenderRequiredDocs = new Lender_Required_Documents__c();
        oLenderRequiredDocs.Item_Name__c = 'Application Form';
        oLenderRequiredDocs.Item_Type__c = 'Lender Document';
        oLenderRequiredDocs.Days_before_Due__c = 7.00;
        oLenderRequiredDocs.Days_Before_Requested__c = 0.00;
        oLenderRequiredDocs.Lender__c = oLender.Id;        
        insert oLenderRequiredDocs;
        
        //Create Application
        Application__c oApplication = new Application__c();
        oApplication.Status__c = 'White';
        oApplication.Sub_Status__c = 'Application';
        oApplication.Loan_Amount__c = 100000.00;
        oApplication.Business__c = 'Loan.co.uk';
        oApplication.Account__c = oAccount.Id;
        oApplication.Application_Type__c = 'Secured Loan';
        oApplication.Loan_Purpose__c = 'Business';
        oApplication.Loan_Term_Months__c = 48.00;
        oApplication.Lead_Applicant_Name__c = 'Joe Bloggs';     
        //oApplication.Lender__c = oLender.Id;        
        insert oApplication;
        
        //Create Applicant
        Applicant__c oApplicant = new Applicant__c();
        oApplicant.First_Name__c = 'Joe';
        oApplicant.Last_Name__c = 'Bloggs';
        oApplicant.Marital_Status__c = 'Married';
        oApplicant.Email_Address__c = 'joebloggs@hotmail.com';
        oApplicant.Home_Phone__c = '002890777888';
        oApplicant.Mobile_Phone__c = '07775558899';
        oApplicant.Employment_Status__c = 'Full Time Employment';
        oApplicant.Time_in_Employment_Months__c = '6';
        oApplicant.Time_in_Employment_Years__c = '3';
        oApplicant.Gross_Monthly_Income__c = 4000.00;
        oApplicant.Application__c = oApplication.Id;        
        insert oApplicant;          
        
        //Create Quote
        Quote__c oQuote = new Quote__c();
        oQuote.Active__c = true;
        oQuote.Application__c = oApplication.Id;
        oQuote.Lender_Fee__c = oLender.Id;
        oQuote.Name = 'Quote 1';        
        insert oQuote;
        
        // *******************************************
        // Create Outstanding Items
        // *******************************************
        
        //Declare variables
        String LenderFee = oQuote.Lender_Fee__c;
        String ApplicationRef = oQuote.Application__c;
        String LenderId = oLender.Id;
        
        
        //Grab Lender_Required_Documents details based on Lender__c
        List <Lender_Required_Documents__c> LenderRequiredDocuments = [Select Days_before_Due__c, Days_Before_Requested__c, Item_Name__c, Item_Type__c, Name, Id from Lender_Required_Documents__c 
            WHERE Lender__c =: LenderId];
        
        List<Outstanding_Items__c> outstandingItems = new List<Outstanding_Items__c>();
        
        // Loop through the list and grab the data to create each Outstanding Item
        for(Lender_Required_Documents__c lrd : LenderRequiredDocuments){
            
            Date scheduledDate = date.today();
            
            //Convert decimals to int
            //These will be used to calculate the Scheduled and Due Date later
            Decimal decimalDBR = lrd.Days_Before_Requested__c;
            Integer intDBR = decimalDBR.intValue();
            
            Decimal decimalDBD = lrd.Days_before_Due__c;
            Integer intDBD = decimalDBD.intValue();
            
            
            //Get Scheduled Date
            scheduledDate = scheduledDate.addDays(intDBR);                      
            //Get Due Date
            Date dueDate = scheduledDate.addDays(intDBD);
            
            Outstanding_Items__c getDocsData = new Outstanding_Items__c();
            
            getDocsData.Item_Name__c = lrd.Item_Name__c;
            getDocsData.Item_Type__c = lrd.Item_Type__c;
            getDocsData.Application__c = ApplicationRef;
            getDocsData.Scheduled_Date__c = scheduledDate;
            getDocsData.Due_Date__c = dueDate;
            
            outstandingItems.add(getDocsData);
        }   
        
        insert outstandingItems;  
        
        Outstanding_Items__c oOutstandingItems = [SELECT Id From Outstanding_Items__c LIMIT 1];
        
        // *******************************************
        // Test processUpload method
        // *******************************************
        PageReference UploadAttachment= Page.UploadAttachment;
        UploadAttachment.getParameters().put('description','description');
        Test.setCurrentPage(UploadAttachment);
        
        ApexPAges.StandardController stdController = new ApexPages.StandardController(oOutstandingItems);  
        UploadAttachmentController controller = new UploadAttachmentController(stdController);
        //The below has been removed for the Test to fail
        //controller.fileBody=Blob.valueof('Unit test blob');
        //controller.fileName='UnitTest.txt';
        
        PageReference sResponseProcessUpload = controller.processUpload();          
        System.assertEquals(null, sResponseProcessUpload);  
        
    }
}