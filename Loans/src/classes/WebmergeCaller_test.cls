@isTest
// 18/02/2015 - Simon Parker
private class WebmergeCaller_test {
	
	@isTest static void test_callWebmergeimmediate() {

		String documentname = 'Application Form';
		
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
		oLenderRequiredDocs.Item_Name__c = documentname;
		oLenderRequiredDocs.Item_Type__c = 'Lender Document';
		oLenderRequiredDocs.Days_before_Due__c = 7.00;
		oLenderRequiredDocs.Days_Before_Requested__c = 0.00;
		oLenderRequiredDocs.Lender__c = oLender.Id;
		oLenderRequiredDocs.Webmerge_Document_Name__c = documentname;
		
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

        webm__Webmerge_Mapping__c webmergemapping = new webm__Webmerge_Mapping__c();
        webmergemapping.webm__Test_Mode__c = true;
        webmergemapping.webm__Salesforce_Object_Name__c = 'Application__c';

        insert webmergemapping;

        Attachment oAttachment = new Attachment();
        oAttachment.parentID = oApplication.id;
        oAttachment.Name = documentname;
        oAttachment.Body = Blob.valueOf('This is the body');

        insert oAttachment;

        //Verify the method passed

        Test.startTest();
		List<Attachment> sResponse = WebmergeCaller.callWebmerge(webmergemapping.id, oApplication.id, 'Application__c', oLender.id, true, true, true);
		Test.stopTest();
		//Check Lender Required Doc created as Outstanding Item
		List<Outstanding_Items__c> newoutstandingitems = [Select id, Item_Name__c from Outstanding_Items__c WHERE Application__c=:oApplication.id];

		System.assertEquals(documentname, newoutstandingitems[0].Item_Name__c);

	}

	@isTest static void test_callWebmergefuture() {

		String documentname = 'Application Form';
		
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
		oLenderRequiredDocs.Item_Name__c = documentname;
		oLenderRequiredDocs.Item_Type__c = 'Lender Document';
		oLenderRequiredDocs.Days_before_Due__c = 7.00;
		oLenderRequiredDocs.Days_Before_Requested__c = 0.00;
		oLenderRequiredDocs.Lender__c = oLender.Id;
		oLenderRequiredDocs.Webmerge_Document_Name__c = documentname;
		
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

        webm__Webmerge_Mapping__c webmergemapping = new webm__Webmerge_Mapping__c();
        webmergemapping.webm__Test_Mode__c = true;
        webmergemapping.webm__Salesforce_Object_Name__c = 'Application__c';

        insert webmergemapping;

        Attachment oAttachment = new Attachment();
        oAttachment.parentID = oApplication.id;
        oAttachment.Name = documentname;
        oAttachment.Body = Blob.valueOf('This is the body');

        insert oAttachment;

        //Verify the method passed
        Test.startTest();
		List<Attachment> sResponse = WebmergeCaller.callWebmerge(webmergemapping.id, oApplication.id, 'Application__c', oLender.id, false, true, true);
		Test.stopTest();
		//Check Lender Required Doc created as Outstanding Item
		List<Outstanding_Items__c> newoutstandingitems = [Select id, Item_Name__c from Outstanding_Items__c WHERE Application__c=:oApplication.id];

		System.assertEquals(documentname, newoutstandingitems[0].Item_Name__c);

	}
}