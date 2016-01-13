@isTest
private class SECAPIcreateLenderDocs_test {
	
	@isTest static void testNoDataSent() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();
       
        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIcreateLenderDocs';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SECAPIcreateLenderDocs.DocsResponse DocResponse = SECAPIcreateLenderDocs.createDocs();
        Test.stopTest();

   		System.assertEquals('No valid input parameter data sent',DocResponse.Detail[0]);

	}

	@isTest static void testNoSuchQuote() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();
       
        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIcreateLenderDocs';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;



        req.addParameter('QUOTEID', 'fffffff');

        Test.startTest();
        SECAPIcreateLenderDocs.DocsResponse DocResponse = SECAPIcreateLenderDocs.createDocs();
        Test.stopTest();

   		System.assertEquals('No such Quote record.',DocResponse.Detail[0]);
   		System.assertEquals('Rejected',DocResponse.Status);
	}

	@isTest static void testNoDocumentMapping() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();
       
        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIcreateLenderDocs';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

         String documentname = 'Application Form';

        //Create Account
        Account oAccount = new Account();
		oAccount.Name = 'Loans & Mortgages';
		oAccount.Business__c = 'Loan.co.uk';
		oAccount.Affiliate_ID__c = 'SAMLOAN';
		
		insert oAccount;

		webm__Webmerge_Mapping__c webmergemapping = new webm__Webmerge_Mapping__c();
        webmergemapping.webm__Test_Mode__c = true;
        webmergemapping.webm__Salesforce_Object_Name__c = 'Application__c';

        insert webmergemapping;
		
		//Create Lender
		Lender__c oLender = new Lender__c();
		oLender.Active__c = true;
		oLender.Name = 'Test Lender';
		//oLender.Webmerge_Document_Batch__c = webmergemapping.id;
		
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


		req.addParameter('QUOTEID', oQuote.id);

        Test.startTest();
        SECAPIcreateLenderDocs.DocsResponse DocResponse = SECAPIcreateLenderDocs.createDocs();
        Test.stopTest();

   		System.assertEquals('There is no document merge mapping defined for this Lender.',DocResponse.Detail[0]);
   		System.assertEquals('Rejected',DocResponse.Status);
	}


	

	@isTest static void testcreateDocs() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String sfdcInstance = System.URL.getSalesforceBaseUrl().getHost();
       
        req.requestURI = 'https://' + sfdcInstance + '/services/apexrest/sec/SECAPIcreateLenderDocs';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        String documentname = 'Application Form';
		
		//Create Account
        Account oAccount = new Account();
		oAccount.Name = 'Loans & Mortgages';
		oAccount.Business__c = 'Loan.co.uk';
		oAccount.Affiliate_ID__c = 'SAMLOAN';
		
		insert oAccount;

		webm__Webmerge_Mapping__c webmergemapping = new webm__Webmerge_Mapping__c();
        webmergemapping.webm__Test_Mode__c = true;
        webmergemapping.webm__Salesforce_Object_Name__c = 'Application__c';

        insert webmergemapping;
		
		//Create Lender
		Lender__c oLender = new Lender__c();
		oLender.Active__c = true;
		oLender.Name = 'Test Lender';
		oLender.Webmerge_Document_Batch__c = webmergemapping.id;
		
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


		req.addParameter('QUOTEID', oQuote.id);

        Test.startTest();
        SECAPIcreateLenderDocs.DocsResponse DocResponse = SECAPIcreateLenderDocs.createDocs();
        Test.stopTest();        

  
   		System.assertEquals('Success',DocResponse.Status);
	}
	

	
}