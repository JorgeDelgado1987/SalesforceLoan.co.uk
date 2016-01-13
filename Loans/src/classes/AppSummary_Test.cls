@isTest
private class AppSummary_Test {
    static testMethod void completeTest() {
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

        //Create Lender Plan
        Lender_Plan__c oLenderPlan = new Lender_Plan__c();
        oLenderPlan.Lender__c = oLender.id;
        oLenderPlan.Plan_Commission__c = 5;

        insert oLenderPlan;
        
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
        oQuote.Lender_Plan__c = oLenderPlan.id;
        
        insert oQuote;

        Valuer__c oValuer = new Valuer__c();
		oValuer.Name = 'Metropolis';
        insert oValuer;

        Valuation_Plan__c oValPlan = new Valuation_Plan__c();
        oValPlan.Valuer__c = oValuer.id;
        oValPlan.Valuation_Fee__c = 123;
        oValPlan.Valuation_Type__c = 'Full Valuation';
        oValPlan.Value_Lower_Limit__c = 200000;
        oValPlan.Value_Upper_Limit__c = 300000;

        insert oValPlan;


        Property__c oProp = new Property__c();
        oProp.Application__c = oApplication.id;
        oProp.Estimated_Value__c = 250000;
        oProp.Valuer__c = oValuer.id;
        oProp.Valuation_Type__c = 'Full Valuation';

        insert oProp;
        
        //Verify the method passed
        String sResponse = GetOutstandingItems.getOutstandingItems(oQuote.Id);
        System.assertEquals('complete', sResponse);
        
        //verify that 1 Outstanding Item was created        
        System.assertEquals(1,[Select COUNT() from Outstanding_Items__c WHERE Application__c =: oApplication.Id]);
        
        //Get Outstanding Item Id
        
		List<ID> OutstandingItemsIdList = new List<ID>();
        String OutstandingItemsIds = [Select Id 
            FROM Outstanding_Items__c WHERE Application__c =: oApplication.Id].Id;
        
        OutstandingItemsIdList.add(OutstandingItemsIds);
        
        //Verify the method passed
        String sResponse2 = AppSummary.packReceivedButton(OutstandingItemsIdList);
        System.assertEquals('complete', sResponse2);
		
		String sResponse3 = AppSummary.sentToBankButton(oApplication.Id, OutstandingItemsIdList);
        System.assertEquals('complete', sResponse3);
		
		String sResponse4 = AppSummary.paidOut(OutstandingItemsIdList);
        System.assertEquals('complete', sResponse4);

        // Get Property ID

        List<ID> props = new List<ID>();
        props.add(oProp.id);

        String sResponse5 = AppSummary.payValuationFee(props);
        System.assertEquals('complete', sResponse5);
		
		String sResponseComplete = AppSummary.payValuationFeeUpdate(oProp.Id, oProp.Valuer__c, oProp.Valuation_Type__c);
        System.assertEquals('complete', sResponseComplete);
		
        oProp.Estimated_Value__c = 350000;
        update oProp;
		
		String sResponseNoPlan = AppSummary.payValuationFeeUpdate(oProp.Id, oProp.Valuer__c, oProp.Valuation_Type__c);
        System.assertEquals('noplan', sResponseNoPlan);
		
        String sResponse6 = AppSummary.payValuationFee(props);
        System.assertEquals('noplan', sResponse6);

        Campaign oCamp = new Campaign();
        oCamp.Name = 'test';

        insert oCamp;

        oApplication.Campaign__c = oCamp.id;
        update oApplication;

        String sResponse7 = AppSummary.paidOut(OutstandingItemsIdList);

        oCamp.Lead_Cost_Type__c = 'Cost Per Accept £';
        oCamp.CPA_Amount_currency__c = 123.34;
        update oCamp;

		//Test Paid Out method
        String sResponse8 = AppSummary.paidOut(OutstandingItemsIdList);
        System.assertEquals('complete', sResponse8);

		//Test newQuote method
		//Insert an active Quote, this will be set as inactive for test purposes when calling newQuote method
		Quote__c oQuote2 = new Quote__c();
        oQuote2.Active__c = true;
        oQuote2.Application__c = oApplication.Id;
        oQuote2.Lender_Fee__c = oLender.Id;
        oQuote2.Name = 'Quote 2';
        oQuote2.Lender_Plan__c = oLenderPlan.id;
        
        insert oQuote2;
		
		String sResponse9 = AppSummary.newQuote(oApplication.Id, oQuote.Id);
        System.assertEquals('complete', sResponse9);
		
		
		//Test createCCQItem method, the result will be used for testing sendSMS method below
		String sResponse10 = AppSummary.createCCQItem(oApplicant.Id);
        System.assertNotEquals('error', sResponse10);
		
		//Insert new SMS Template
		SMS_Template__c oSMSTemplate = new SMS_Template__c();
        oSMSTemplate.Message_Content__c = 'This is a Test SMS Message text';
        oSMSTemplate.Sender_ID__c = 'Loans.co.uk';
        oSMSTemplate.Name = 'iTagg-SMS';
        
        insert oSMSTemplate;
		
		/*//Test sendSMS Method with Applicant that has a mobile number
		String sResponse11 = AppSummary.sendSMS(sResponse10);
        System.assertNotEquals('', sResponse11);
		
		//Create Applicant with no Mobile Number
        Applicant__c oApplicant2 = new Applicant__c();
        oApplicant2.First_Name__c = 'Joe';
        oApplicant2.Last_Name__c = 'Bloggs';
        oApplicant2.Marital_Status__c = 'Married';
        oApplicant2.Email_Address__c = 'joebloggs@hotmail.com';
        oApplicant2.Home_Phone__c = '002890777888';
        oApplicant2.Employment_Status__c = 'Full Time Employment';
        oApplicant2.Time_in_Employment_Months__c = '6';
        oApplicant2.Time_in_Employment_Years__c = '3';
        oApplicant2.Gross_Monthly_Income__c = 4000.00;
        oApplicant2.Application__c = oApplication.Id;
		
		insert oApplicant2;
		
		//Create CCQ Item for above Applicant
		String sResponse12 = AppSummary.createCCQItem(oApplicant2.Id);
        System.assertNotEquals('error', sResponse12);
		
		//Test sendSMS Method with Applicant that does not have a mobile number
		String sResponse13 = AppSummary.sendSMS(sResponse12);
        System.assertEquals('invalid mobile number', sResponse13);*/
    }
	
	
    
}