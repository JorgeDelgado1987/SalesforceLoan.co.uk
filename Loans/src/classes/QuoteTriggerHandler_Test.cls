@isTest
/////////////////////////////////////////////////
// Simon Parker   06/10/2014
// Eddie Bates  23/01/2014    	JIRA SEC-246. Amended the Triggers adding Lender Plan and Lender Plan Rate
// Phillip Coles 10/02/2015		JIRA SEC-285 + SEC-302. Added method to add 2nd active quote to be made inactive on update of active quote
////////////////////////////////////////////////
private class QuoteTriggerHandler_Test {
	
	@isTest static void newQuoteSuccess() {
		 account ac = new account();
         ac.name = 'Test1';
         insert ac;

         Application__c a = new Application__c();
         a.Account__c = ac.id;
         a.Loan_Amount__c = 2000;
         a.Loan_Term_Months__c = 60;
         insert a;

         Lender__c l = new Lender__c();
		 l.Name = 'Test Lender 1';
         insert l;

         Lender_Plan__c lp = new Lender_Plan__c();
         lp.Lender__c = l.id;
         lp.Variable_Rate__c = 10;
		 lp.Max_Loan_Amount__c = 30000;
         insert lp;
		
		 Lender_Plan_Rate__c lpr = new Lender_Plan_Rate__c();
		 lpr.Active__c = true;
		 lpr.Rate_Max_Loan_Amount__c = 30000;
		 lpr.Rate_Max_Loan_Amount__c = 1;
		 lpr.Lender_Plan__c = lp.Id;
		 lpr.Rate_Max_LTV__c = 30000;
		 lpr.Rate_Min_LTV__c = 1;
		 insert lpr;
		 
		Test.startTest();
         Quote__c q = new Quote__c();
         q.Lender_Plan__c = lp.id;
         q.Application__c = a.id;
		 q.Lender_Fee__c = l.Id;
		 q.Active__c = true;
         insert q;
		Test.stopTest();
		
		Application__c oApplicationTest = [Select Id, Lender__c from Application__c where id =: a.Id];					
		system.assertEquals(l.Id, oApplicationTest.Lender__c, 'Expecting Lender in Application__c to equal Lender in Lender__c');
		
	}
			
	@isTest static void updateQuoteSuccess() {
		 account ac = new account();
         ac.name = 'Test3';
         insert ac;

         Application__c a = new Application__c();
         a.Account__c = ac.id;
         a.Loan_Amount__c = 2000;
         a.Loan_Term_Months__c = 60;
         insert a;

         Lender__c l = new Lender__c();
		 l.Name = 'Test Lender 2';
         insert l;

         Lender_Plan__c lp = new Lender_Plan__c();
         lp.Lender__c = l.id;
         lp.Variable_Rate__c = 10;
		 lp.Max_Loan_Amount__c = 30000;
         insert lp;
		
		 Lender_Plan_Rate__c lpr = new Lender_Plan_Rate__c();
		 lpr.Active__c = true;
		 lpr.Rate_Max_Loan_Amount__c = 30000;
		 lpr.Rate_Max_Loan_Amount__c = 1;
		 lpr.Lender_Plan__c = lp.Id;
		 lpr.Rate_Max_LTV__c = 30000;
		 lpr.Rate_Min_LTV__c = 1;
		 insert lpr;
		 
         Quote__c q = new Quote__c();
         q.Lender_Plan__c = lp.id;
         q.Application__c = a.id;
		 q.Lender_Fee__c = l.Id;
		 q.Active__c = true;
         insert q;

		Test.startTest();
         lp.Variable_Rate__c = 11;
         q.Blow_Out_Detail__c = 'xxxx';
		 update q;
		Test.stopTest();	
		
		Application__c oApplicationTest = [Select Id, Lender__c from Application__c where id =: a.Id];					
		system.assertEquals(l.Id, oApplicationTest.Lender__c, 'Expecting Lender in Application__c to equal Lender in Lender__c');
         
	}

	@isTest static void testUpdatesForActiveQuotes() {

		Account testAccount4 = new Account(
			Name = 'Test4'
			);
        Insert testAccount4;

        Application__c testApplication = new Application__c(
        	Account__c = testAccount4.Id,
        	Total_Lender_Fees__c = 1000,
        	Monthly_Repayment__c = 100,
        	Application_Value__c = 2000
        	);
        Insert testApplication;

        Quote__c testActiveQuote1 = new Quote__c(
        	Application__c = testApplication.Id,
        	Active__c = true
        	);
        Insert testActiveQuote1;

        Test.startTest();
        //Insert new Active quote. 1st one should be made inactive and values on Application should be updated from this quote
        Quote__c testActiveQuote2 = new Quote__c(
        	Application__c = testApplication.Id,
        	Active__c = true,
        	Lender_Fee_Value__c = 1100, // therefore Total_Fees__c will equal this too
        	Monthly_Repayment__c = 110,
        	Broker_Fee__c = 2100 // therefore Total_Remuneration__c will equal this too
        	);
        Insert testActiveQuote2;
        Test.stopTest();

        // Asserting the Applciation field updates
        Application__c theTestApplication = [ SELECT Id, Total_Lender_Fees__c, Monthly_Repayment__c, Application_Value__c FROM Application__c WHERE Id = :testApplication.Id ];
        Quote__c theSecondTestQuote = [ SELECT Id, Total_Fees__c, Monthly_Repayment__c, Total_Remuneration__c FROM Quote__c WHERE Id = :testActiveQuote2.Id ];
        System.assertEquals(theSecondTestQuote.Total_Fees__c, theTestApplication.Total_Lender_Fees__c, 'theTestApplication.Total_Lender_Fees__c should now = theSecondTestQuote.Total_Fees__c');
        System.assertEquals(theSecondTestQuote.Monthly_Repayment__c, theTestApplication.Monthly_Repayment__c, 'theTestApplication.Monthly_Repayment__c should now = theSecondTestQuote.Monthly_Repayment__c');
        System.assertEquals(theSecondTestQuote.Total_Remuneration__c, theTestApplication.Application_Value__c, 'theTestApplication.Application_Value__c should now = theSecondTestQuote.Total_Remuneration__c');

        // Asserting the Quote will have been made inactive
        Quote__c theFirstTestQuote = [ SELECT Id, Active__c FROM Quote__c WHERE Id = :testActiveQuote1.Id ];
        System.assertEquals(false, theFirstTestQuote.Active__c, 'The 1st Quote should have been set to inactive by the Insertion of the 2nd active Quote');
	}
}