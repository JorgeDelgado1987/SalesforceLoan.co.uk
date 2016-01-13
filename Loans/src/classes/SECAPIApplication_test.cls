@isTest

// 19/09/2014 - Simon Parker
private class SECAPIApplication_test {

    @isTest static void test_post_create() {
        // setup test data
        Account account = new Account();
        account.Name = 'First';
        insert account;

        Campaign camp = new Campaign();
        camp.Account__c = account.id;
        camp.Name = 'Test';
        insert camp;

        Application__c appl = new Application__c();
        appl.Account__c = account.id;
        appl.Campaign__c = camp.id;
        appl.Loan_Amount__c = 150000;
        appl.Application_Type__c = 'Bridging Loan';

        List<Applicant__c> apps = new List<Applicant__c>();
        List<Dependants__c> deps = new List<Dependants__c>();
        List<Applicant_Income__c> appincomes = new List<Applicant_Income__c>();
        List<Expenditure__c> expenditures = new List<Expenditure__c>();
        List<Property__c> props = new List<Property__c>();
        List<Mortgage__c> morts = new List<Mortgage__c>();
        List<CCJ__c> ccjs = new List<CCJ__c>();
        List<Debt__c> debts = new List<Debt__c>();

        Applicant__c appli1 = new Applicant__c();
        appli1.Email_Address__c = 'test@test.com';
        appli1.Mobile_Phone__c = '07777777777';
        appli1.First_Name__c = 'Fred';
        appli1.Last_Name__c = 'Bloggs';
        appli1.Applicant_Index__c = 1;

        apps.add(appli1);

        SECAPIApplication.SECAPI_Response_Application myResp = SECAPIApplication.doPost('','','',appl,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'action is required');

        myResp = SECAPIApplication.doPost('ggg','','',appl,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'action can only be Create or Update');

        myResp = SECAPIApplication.doPost('create','appl.id','',appl,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'Must not supply an ApplicationID for a create action');

        myResp = SECAPIApplication.doPost('update','','',appl,apps,deps,appincomes, expenditures, props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'Must supply an ApplicationID for an update action');

    Application__c appl1 = new Application__c();
        appl1.Campaign__c = camp.id;
        appl1.Loan_Amount__c = 150000;
        appl1.Application_Type__c = 'Bridging Loan';

        myResp = SECAPIApplication.doPost('create','','',appl1,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'Account is required');

        appl1.Account__c = account.id;
        appl1.Campaign__c = null;

        myResp = SECAPIApplication.doPost('create','','',appl1,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'Campaign is required');

        appl1.Loan_Amount__c = 0;
        appl1.Campaign__c = camp.id;

        myResp = SECAPIApplication.doPost('create','','',appl1,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'Loan Amount is required');

        appl1.Loan_Amount__c = 1;
        appl1.Application_Type__c = null;

        myResp = SECAPIApplication.doPost('create','','',appl1,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'Application Type is required');

        appl1.Application_Type__c = 'Bridging Loan';

        Applicant__c app1 = new Applicant__c();

        app1.Last_Name__c = 'Last';
        app1.Email_address__c = 'me@here.com';
        app1.Mobile_Phone__c = '07777777777';
        app1.Applicant_index__c = 1;

        apps.add(app1);

        myResp = SECAPIApplication.doPost('create','','',appl1,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'First Name is required');

        app1.First_Name__c = 'First';
        app1.Last_Name__c = null;

        myResp = SECAPIApplication.doPost('create','','',appl1,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'Last Name is required');

        app1.Last_Name__c = 'Last';
        app1.Email_address__c = null;

        myResp = SECAPIApplication.doPost('create','','',appl1,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'Email address is required');

        app1.Email_address__c = 'me@here.com';
        app1.Mobile_Phone__c = '077777777777';
        app1.Applicant_index__c = null;

        myResp = SECAPIApplication.doPost('create','','',appl1,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'Applicant index is required');

        app1.Applicant_index__c = 1;

        Dependants__c dep1 = new Dependants__c();
        dep1.First_Name__c = 'Young';
        dep1.Last_Name__c = 'Bloggs';
        dep1.Age__c = 9;
        dep1.Applicant_Index__c = 1;

        deps.add(dep1);

        myResp = SECAPIApplication.doPost('create','','',appl1,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'Dependant index is required');

        dep1.Dependant_Index__c = 1;
        dep1.Applicant_Index__c = null;

        myResp = SECAPIApplication.doPost('create','','',appl1,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'Dependant Applicant index is required');

        dep1.Applicant_Index__c = 1;
        Applicant_Income__c appincome1 = new Applicant_Income__c();
        appincome1.Employer_Name__c = 'The Boss';
        appincome1.Applicant_Index__c = 1;

        appincomes.add(appincome1);

        myResp = SECAPIApplication.doPost('create','','',appl1,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'Applicant_Income index on Applicant_Income is required');

        appincome1.Applicant_Income_Index__c = 1;
        appincome1.Applicant_Index__c = null;

        myResp = SECAPIApplication.doPost('create','','',appl1,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'Applicant index on Applicant_Income is required');

        appincome1.Applicant_Index__c = 1;

        Property__c prop1 = new Property__c();
        props.add(prop1);

        myResp = SECAPIApplication.doPost('create','','',appl1,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'Property index is required');

        prop1.Property_index__c = 1;

        Mortgage__c mort1 = new Mortgage__c();
        mort1.Property_index__c = 1;
        morts.add(mort1);

        myResp = SECAPIApplication.doPost('create','','',appl1,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);


        mort1.Mortgage_index__c = 1;

        CCJ__c ccj1 = new CCJ__c();
        ccjs.add(ccj1);

        myResp = SECAPIApplication.doPost('create','','',appl1,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'CCJ index is required');

        ccj1.CCJ_Index__c = 1;

        Creditor__c cred1 = new Creditor__c();

        insert cred1;

        Debt__c debt1 = new Debt__c();

        debt1.Creditor__c = cred1.id;
        debts.add(debt1);

        myResp = SECAPIApplication.doPost('create','','',appl1,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals(myResp.failureMessage,'Debt index is required');

        debt1.Debt_Index__c = 1;
        debt1.Creditor__c = null;

        debt1.Creditor__c = cred1.id;
        myResp = SECAPIApplication.doPost('create','','',appl1,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);

        appl1.id = null;

    }

    @isTest static void test_post_insert() {
            // setup test data

        List<Applicant__c> apps = new List<Applicant__c>();
        List<Dependants__c> deps = new List<Dependants__c>();
        List<Applicant_Income__c> appincomes = new List<Applicant_Income__c>();
        List<Expenditure__c> expenditures = new List<Expenditure__c>();
        List<Property__c> props = new List<Property__c>();
        List<Mortgage__c> morts = new List<Mortgage__c>();
        List<CCJ__c> ccjs = new List<CCJ__c>();
        List<Debt__c> debts = new List<Debt__c>();


        Account account = AccountBuilder.getBuilder('Test Acc').save().getRecord();
        Campaign campaign = CampaignBuilder.getBuilder('Test')
                                .setAccount(account)
                                .save().getRecord();
        Application__c application = ApplicationBuilder.getBuilder(account)
                                .setCampaign(campaign)
                                .setLoanAmount(10000)
                                .setApplicationType('Bridging Loan')
                                .getRecord();

        Applicant__c applicant2 = ApplicantBuilder.getBuilder(application)
                                                 .setFirstName('Bob')
                                                 .setLastName('Turwilligar')
                                                 .setDateOfBirth(Date.newInstance(1984, 12, 1))
                                                 .setTitle('Mr')
                                                 .setPostCode('2AB 3CD')
                                                 .setMaidenName('Something')
                                                 .setEmail('bob@bob.com')
                                                 .setApplicantIndex(1)
                                                 .getRecord();


        apps.add(applicant2);

        SECAPIApplication.SECAPI_Response_Application myResp = SECAPIApplication.doPost('create','','',application,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
        system.assertEquals('success',myResp.status);
    }

    @isTest static void test_post_update() {
            // setup test data

        List<Applicant__c> apps = new List<Applicant__c>();
        List<Dependants__c> deps = new List<Dependants__c>();
        List<Applicant_Income__c> appincomes = new List<Applicant_Income__c>();
        List<Expenditure__c> expenditures = new List<Expenditure__c>();
        List<Property__c> props = new List<Property__c>();
        List<Mortgage__c> morts = new List<Mortgage__c>();
        List<CCJ__c> ccjs = new List<CCJ__c>();
        List<Debt__c> debts = new List<Debt__c>();


        Account account = AccountBuilder.getBuilder('Test Acc').save().getRecord();
        Campaign campaign = CampaignBuilder.getBuilder('Test')
                                .setAccount(account)
                                .save().getRecord();
        Application__c application = ApplicationBuilder.getBuilder(account)
                                .setCampaign(campaign)
                                .setLoanAmount(10000)
                                .setApplicationType('Bridging Loan')
                                .save().getRecord();

        Applicant__c applicant1 = ApplicantBuilder.getBuilder(application)
                                                 .setFirstName('Bob')
                                                 .setLastName('Turwilligar')
                                                 .setDateOfBirth(Date.newInstance(1984, 12, 1))
                                                 .setTitle('Mr')
                                                 .setPostCode('2AB 3CD')
                                                 .setMaidenName('Something')
                                                 .setEmail('bob@bob.com')
                                                 .setApplicantIndex(1)
                                                 .save().getRecord();

        Applicant_Income__c appincome2 = ApplicantIncomeBuilder.getBuilder(applicant1)
                                        .setApplicantIndex(1)
                                        .setApplicantIncomeIndex(1)
                                        .save().getRecord();

        Dependants__c dep2 = new Dependants__c();
        dep2.First_Name__c = 'Young';
        dep2.Last_Name__c = 'Bloggs';
        dep2.Age__c = 9;
        dep2.Applicant_Index__c = 1;
        dep2.Dependant_Index__c = 1;
        dep2.Applicant__c = applicant1.id;

        insert dep2;

        Applicant__c app2 = new Applicant__c();
        app2.First_Name__c = 'First';
        app2.Last_Name__c = 'Last';
        app2.Email_address__c = 'me@here.com';
        app2.Mobile_Phone__c = '07777777777';
        app2.Applicant_index__c = 1;

        apps.add(app2);

        Applicant_Income__c appincome1 = ApplicantIncomeBuilder.getBuilder(applicant1)
                                        .setApplicantIndex(1)
                                        .setApplicantIncomeIndex(1)
                                        .getRecord();

        appincomes.add(appincome1);

        Dependants__c dep1 = new Dependants__c();
        dep1.First_Name__c = 'Young';
        dep1.Last_Name__c = 'Bloggs';
        dep1.Age__c = 9;
        dep1.Applicant_Index__c = 1;
        dep1.Dependant_Index__c = 1;

        deps.add(dep1);

        Property__c prop1 = new Property__c();
        prop1.Property_index__c = 1;
        props.add(prop1);

        Mortgage__c mort1 = new Mortgage__c();
        mort1.Mortgage_index__c = 1;
        mort1.Property_index__c = 1;
        morts.add(mort1);

        CCJ__c ccj1 = new CCJ__c();
        ccj1.CCJ_Index__c = 1;
        ccj1.Applicant_Index__c = 1;
        ccjs.add(ccj1);


        Creditor__c cred1 = new Creditor__c();

        insert cred1;

        Debt__c debt1 = new Debt__c();
        debt1.Debt_Index__c = 1;
        debt1.Creditor__c = cred1.id;
        debt1.Applicant_Index__c =1;
        debts.add(debt1);

        SECAPIApplication.SECAPI_Response_Application myResp = SECAPIApplication.doPost('update',application.id,'',application,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);


        myResp = SECAPIApplication.doPost('update',application.id,'',application,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);


        Debt__c debt2 = new Debt__c();
        debt2.Debt_Index__c = 2;

        debts.add(debt2);

        myResp = SECAPIApplication.doPost('update',application.id,'',application,apps,deps,appincomes,expenditures,props,morts,ccjs,debts);
    }

        @isTest static void test_get_nodata() {

                RestRequest req = new RestRequest();
                RestResponse res = new RestResponse();

                req.requestURI = '/sec/application';
                req.httpMethod = 'GET';
                RestContext.request = req;
                RestContext.response = res;

                SECAPIApplication.SECAPI_Response_Application myResp = SECAPIApplication.doGet();

                System.assertEquals('Account is required : Campaign is required : Loan Amount is required : Application Type is required : First Name is required : Last Name is required : Email address is required',myResp.failureMessage,'Expecting validation failures');


        }

        @isTest static void test_get_withdata() {

                RestRequest req = new RestRequest();
                RestResponse res = new RestResponse();

                Account account = new Account();
                account.Name = 'First';
                insert account;

                Campaign camp = new Campaign();
                camp.Account__c = account.id;
                camp.Name = 'Test';
                insert camp;

                req.requestURI = '/sec/application';
                req.httpMethod = 'GET';
                req.addParameter('LoanAmount', '5000');
                req.addParameter('LoanTerm(Months)', '48');
                req.addParameter('Account', account.id);
                req.addParameter('Campaign', camp.id);
                req.addParameter('FirstName', 'Fred');
                req.addParameter('LastName', 'Bloggs');
                req.addParameter('ApplicationType', 'Bridging Loan');
                req.addParameter('EmailAddress', 'fred453@bloggs.com');
                req.addParameter('NumberofBathrooms', '2');
                req.addParameter('FirstTimeBuyer', 'true');

                RestContext.request = req;
                RestContext.response = res;

                Test.startTest();

                SECAPIApplication.SECAPI_Response_Application myResp = SECAPIApplication.doGet();

                Test.stopTest();

                system.debug(myResp);

                System.assertEquals('success',myResp.status,'Expecting success');

        }

        @isTest static void test_post_update_check_for_debts_and_ccjs() {
            // setup test data

        List<Applicant__c> applicants = new List<Applicant__c>();
        List<Dependants__c> dependants = new List<Dependants__c>();
        List<Applicant_Income__c> appincomes = new List<Applicant_Income__c>();
        List<Expenditure__c> expenditures = new List<Expenditure__c>();
        List<Property__c> properties = new List<Property__c>();
        List<Mortgage__c> mortgages = new List<Mortgage__c>();
        List<CCJ__c> ccjs = new List<CCJ__c>();
        List<Debt__c> debts = new List<Debt__c>();


        Account account = AccountBuilder.getBuilder('Test Acc').save().getRecord();
        Campaign campaign = CampaignBuilder.getBuilder('Test')
                                .setAccount(account)
                                .save().getRecord();
        Application__c application = ApplicationBuilder.getBuilder(account)
                                .setCampaign(campaign)
                                .setLoanAmount(10000)
                                .setApplicationType('Bridging Loan')
                                .save().getRecord();

        Applicant__c applicant1 = ApplicantBuilder.getBuilder(application)
                                                 .setFirstName('Bob')
                                                 .setLastName('Turwilligar')
                                                 .setDateOfBirth(Date.newInstance(1984, 12, 1))
                                                 .setTitle('Mr')
                                                 .setPostCode('2AB 3CD')
                                                 .setMaidenName('Something')
                                                 .setEmail('bob@bob.com')
                                                 .setApplicantIndex(1)
                                                 .save().getRecord();

        Applicant_Income__c appincome1 = ApplicantIncomeBuilder.getBuilder(applicant1)
                                        .setApplicantIndex(1)
                                        .setApplicantIncomeIndex(1)
                                        .save().getRecord();

        Creditor__c creditor1 = CreditorBuilder.getBuilder().save().getRecord();

        Debt__c debt1 = DebtBuilder.getBuilder(application)
                                                .setDebtIndex(1)
                                                .setApplicantIndex(1)
                                                .setAmountOutstanding(123.34)
                                                .setCreditor(creditor1)
                                                .save().getRecord();

        Debt__c debt2 = DebtBuilder.getBuilder(application)
                                                .setDebtIndex(1)
                                                .setApplicantIndex(1)
                                                .setAmountOutstanding(246.68)
                                                .setCreditor(creditor1)
                                                .getRecord();

        CCJ__c ccj1 = CCJBuilder.getBuilder(application)
                                                .setCCJIndex(1)
                                                .setApplicantIndex(1)
                                                .setValue(67.78)
                                                .save().getRecord();

        CCJ__c ccj2 = CCJBuilder.getBuilder(application)
                                                .setCCJIndex(1)
                                                .setApplicantIndex(1)
                                                .setValue(78.89)
                                                .getRecord();

        applicants.add(applicant1);
        appincomes.add(appincome1);
        debts.add(debt2);
        ccjs.add(ccj2);

        Test.startTest();

        SECAPIApplication.SECAPI_Response_Application myResp = SECAPIApplication.doPost('update',application.id,'',application,applicants,dependants,appincomes,expenditures,properties,mortgages,ccjs,debts);

        Test.stopTest();

        List<Debt__c> updated_debts = [Select id, Amount_Outstanding__c from Debt__c WHERE Application__c=:application.id];
        List<CCJ__c> updated_ccjs = [Select id, Value__c from CCJ__c WHERE Application__c=:application.id];

        system.debug(myResp);
        system.assertEquals('success',myResp.status,'expecting success repsonse');
        system.assertEquals(1,updated_debts.size(),'expecting only 1 debt on the Application');
        system.assertEquals(1,updated_ccjs.size(),'expecting only 1 CCJ on the Applicaiton');
        system.assertEquals(246.68,updated_debts[0].Amount_Outstanding__c,'expecting Amount to be the updated value');
        system.assertEquals(78.89,updated_ccjs[0].Value__c,'expecting Value to be the updated value');

    }

}