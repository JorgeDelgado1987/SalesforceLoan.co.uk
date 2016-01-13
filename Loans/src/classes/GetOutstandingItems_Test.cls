@isTest
private class GetOutstandingItems_Test {
	static testMethod void getOutstandingItemsTest() {
		// TO DO: implement unit test
		
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
		
		
		//Verify the method passed
		String sResponse = GetOutstandingItems.getOutstandingItems(oQuote.Id);
		System.assertEquals('complete', sResponse);
		
		//verify that 1 Outstanding Item was created		
        System.assertEquals(1,[Select COUNT() from Outstanding_Items__c WHERE Application__c =: oApplication.Id]);
		
		//Test with blank days
		oLenderRequiredDocs.Days_before_Due__c = null;
		oLenderRequiredDocs.Days_Before_Requested__c = null;
		update oLenderRequiredDocs;
		
		String sResponse2 = GetOutstandingItems.getOutstandingItems(oQuote.Id);
		System.assertEquals('complete', sResponse2);

	}
	
	static testMethod void getOutstandingItemRequestType() {
		// TO DO: implement unit test
		
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
		
		
		//Create New Mortgage Company
		Mortgage_Company__c oMortgageCompany = new Mortgage_Company__c();
		oMortgageCompany.Name = 'The Big Lender';
		oMortgageCompany.Address__c = '7 Lender Street London';
		oMortgageCompany.Postcode__c = 'LD7 7NP';
		oMortgageCompany.Consent_Cost__c = 475.00;
		oMortgageCompany.BSQ_Cost__c = 325.00;
		
		insert oMortgageCompany;	
		
		
		//Create New Property
		Property__c oProperty = new Property__c();
		oProperty.Application__c = oApplication.Id;
		oProperty.Estimated_Value__c = 400000.00;
		oProperty.House_Name_Number__c = '7';
		oProperty.Street_Name__c = 'Hayfield Street';
		oProperty.Town__c = 'Belfast';
		oProperty.County__c = 'Antrim';
		oProperty.Postcode__c = 'BT9 5AN';
		oProperty.Current_Address__c = true;
		oProperty.Security_Address__c = true;
		
		insert oProperty;
		
		
		//Create New Mortgage
		Mortgage__c oMortgage = new Mortgage__c();
		oMortgage.Application__c = oApplication.Id;
		oMortgage.Balance__c = 250000.00;
		oMortgage.Monthly_Repayment__c = 10000.00;
		oMortgage.Mortgage_Company__c = oMortgageCompany.Id;
		oMortgage.Type__c = 'Mortgage';
		oMortgage.Property__c = oProperty.Id;
		oMortgage.Mortgage_Account_Number__c = '1234567';
		
		insert oMortgage;			
		
		//Create Test Variables
		String RequestType;
		String sResponse;
		
		
		//*********************
		//Create a Request Type
		//*********************
		RequestType = 'BSQ';		
		//Verify the method passed
		
		sResponse = GetOutstandingItems.getOutstandingItemRequestType(oMortgage.Id, oApplication.Id, RequestType);
		System.assertEquals('complete', sResponse);		
		
		//verify that 1 Outstanding Item was created		
        System.assertEquals(1,[Select COUNT() from Outstanding_Items__c WHERE Application__c =: oApplication.Id]);
		
		
		//*********************
		//Create a Request Type
		//*********************
		RequestType = 'Consent';
		
		//Verify the method passed
		sResponse = GetOutstandingItems.getOutstandingItemRequestType(oMortgage.Id, oApplication.Id, RequestType);
		System.assertEquals('complete', sResponse);	
		
		//verify that 1 Outstanding Item was created		
        System.assertEquals(2,[Select COUNT() from Outstanding_Items__c WHERE Application__c =: oApplication.Id]);
		
		
		//*********************
		//Create a Request Type
		//*********************
		RequestType = 'Both';	
		
		//Verify the method passed
		sResponse = GetOutstandingItems.getOutstandingItemRequestType(oMortgage.Id, oApplication.Id, RequestType);
		System.assertEquals('complete', sResponse);	
		
		//verify that 1 Outstanding Item was created		
        System.assertEquals(4,[Select COUNT() from Outstanding_Items__c WHERE Application__c =: oApplication.Id]);

	}
	
}