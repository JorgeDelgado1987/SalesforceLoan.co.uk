@isTest
/////////////////////////////////////////////////
//       Simon Parker   09/09/2014
////////////////////////////////////////////////

private class ApplicantTriggerHandler_Test {

    static testMethod void testSendWelcomeSMSCreatesExpectedRecords(){
        Account account = AccountBuilder.getBuilder('Test Acc').save().getRecord();
        Application__c app = ApplicationBuilder.getBuilder(account).setBusiness('Loan.co.uk').save().getRecord();
        Test.startTest();
            Applicant__c applicant = ApplicantBuilder.getBuilder(app).setFirstName('Bob').setLastName('Turwilligar')
                .setMobilePhone('07777777777').setIsPrimary(true).save().getRecord();
        Test.stopTest();
        applicant = [SELECT Id, CreatedDate FROM Applicant__c WHERE Id = :applicant.Id];
        List<Customer_Comms_Queue_Item__c> comms_items = [SELECT Remote_Template_Name__c, Send_Date_Time__c, Resend_after_hours__c,
            Application_Stage_to_Handle__c FROM Customer_Comms_Queue_Item__c
            WHERE Applicant__c = :applicant.Id AND Type__c = 'SMS' ORDER BY Remote_Template_Name__c ASC];
        System.assertEquals(2, comms_items.size());
        System.assertEquals('loan-co-uk-fullapp-repeating', comms_items.get(0).Remote_Template_Name__c);
        System.assertEquals(applicant.CreatedDate.addDays(1), comms_items.get(0).Send_Date_Time__c);
        System.assertEquals(24, comms_items.get(0).Resend_after_hours__c);
        System.assertEquals('Call for full app', comms_items.get(0).Application_Stage_to_Handle__c);

        System.assertEquals('loan-co-uk-welcome-sms-1', comms_items.get(1).Remote_Template_Name__c);
        System.assertEquals(true, System.now() >= comms_items.get(1).Send_Date_Time__c);
        System.assertEquals(null, comms_items.get(1).Resend_after_hours__c);
        System.assertEquals('Call for full app', comms_items.get(1).Application_Stage_to_Handle__c);
    }

    @isTest static void testLeadApplicantNameIsCopiedtoApplication() {

        Application__c application = ApplicationBuilder.getBuilder(
            AccountBuilder.getBuilder('Acme Mortgages Ltd')
                              .save()
                              .getRecord()
                                ).save()
                                 .getRecord();
        Test.startTest();
            Applicant__c applicant = ApplicantBuilder.getBuilder(application).setLastName('Bloggs').save().getRecord();
        Test.stopTest();

        Application__c application_result = [Select id, Lead_Applicant_Name__c from Application__c WHERE id=:application.id];
        Applicant__c applicant_result = [Select Id, Is_Primary__c from Applicant__c where id=:applicant.Id];
        System.assertEquals('Bloggs', application_result.Lead_Applicant_Name__c);
        System.assertEquals(true, applicant_result.Is_Primary__c);
    }

    @isTest static void ApplicantCustomerCheck() {
        //setup test data
        Account acc = new Account();
        acc.Name = 'Acme Mortgages Ltd';
        insert acc;

        Application__c appl = new Application__c();
        appl.Account__c = acc.id;
        insert appl;

        Applicant__c app = new Applicant__c();
        app.Last_Name__c = 'Bloggs';
        app.Email_Address__c = 'test@app.com';
        app.Date_of_Birth__c = date.today().addYears(-25);
        app.Home_Phone__c = '0123456789';
        app.Mobile_Phone__c = '077733377';
        app.Postcode__c = 'AB123CD';
        app.Application__c = appl.id;
        insert app;

        Applicant__c result = [Select id, Customer__r.id, Customer__r.Last_Name__c  from Applicant__c WHERE id=:app.id];

        system.assertEquals('Bloggs', result.Customer__r.Last_Name__c);

        Applicant__c app1 = new Applicant__c();
        app1.Application__c = appl.id;
        app1.Email_Address__c = 'test@app.com';
        insert app1;

        Applicant__c result1 = [Select id, Customer__r.id, Customer__r.Email_Address__c from Applicant__c WHERE id=:app1.id];

        system.assertEquals('test@app.com', result1.Customer__r.Email_Address__c);

        Applicant__c app2 = new Applicant__c();
        app2.Application__c = appl.id;
        app2.Mobile_Phone__c = '077733377';
        insert app2;

        Applicant__c result2 = [Select id, Customer__r.id, Customer__r.Mobile_Number__c from Applicant__c WHERE id=:app2.id];

        system.assertEquals('077733377', result2.Customer__r.Mobile_Number__c);

        Applicant__c app3 = new Applicant__c();
        app3.Application__c = appl.id;
        app3.Home_Phone__c = '0123456789';
        app3.Last_Name__c = 'Bloggs';
        app3.Date_of_Birth__c = date.today().addYears(-25);
        insert app3;

        Applicant__c result3 = [Select id, Customer__r.id, Customer__r.Home_Phone__c from Applicant__c WHERE id=:app3.id];

        system.assertEquals('0123456789', result3.Customer__r.Home_Phone__c);

        Applicant__c app4 = new Applicant__c();
        app4.Application__c = appl.id;
        app4.Postcode__c = 'AB123CD';
        app4.Last_Name__c = 'Bloggs';
        app4.Date_of_Birth__c = date.today().addYears(-25);
        insert app4;

        Applicant__c result4 = [Select id, Customer__r.id, Customer__r.Home_Phone__c from Applicant__c WHERE id=:app4.id];

        system.assertEquals('0123456789', result3.Customer__r.Home_Phone__c);

    }

    @isTest static void sendWelcomeEmailSuccess() {

        //Create Account
        Account oAccount = new Account();
        oAccount.Name = 'Loans & Mortgages';
        oAccount.Business__c = 'Loan.co.uk';
        oAccount.Affiliate_ID__c = 'SAMLOAN';
        insert oAccount;

        Campaign camp = new Campaign();
        camp.Lead_Cost_Type__c = 'Cost Per Lead';
        camp.CPL_Amount__c = 123;
        camp.Name = 'Test';
        camp.Receive_Loan_co_uk_Welcome_Email__c = true;
        insert camp;

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
        oApplication.Campaign__c = camp.id;
        insert oApplication;

        //Create Applicant
        Applicant__c oApplicant = new Applicant__c();
        oApplicant.First_Name__c = 'Joe';
        oApplicant.Last_Name__c = 'Bloggs';
        oApplicant.Marital_Status__c = 'Married';
        oApplicant.Email_Address__c = 'joebloggs@hotmail.com';
        oApplicant.Home_Phone__c = '002890777888';
        oApplicant.Employment_Status__c = 'Full Time Employment';
        oApplicant.Time_in_Employment_Months__c = '6';
        oApplicant.Time_in_Employment_Years__c = '3';
        oApplicant.Gross_Monthly_Income__c = 4000.00;
        oApplicant.Is_Primary__c = true;
        oApplicant.Applicant_Index__c =1;
        oApplicant.Application__c = oApplication.Id;
        insert oApplicant;

    }

}