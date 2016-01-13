@isTest
// *******************************************
// Developer:   Simon Parker
// Name:        ApplicationTriggerHandler_Test
// Created:     29/09/2014
// Description:
// *******************************************
/* +-----------------------------------------------------------------------------------------------------------------------------+
   | Updates                                                                                                                     |
   |-----------------------------------------------------------------------------------------------------------------------------|
   | Developer    Date          Description                                                                                      |
   +-----------------------------------------------------------------------------------------------------------------------------+
    Eddie Bates  24/11/2014    	JIRA SEC-121. Added assignAgentToApplicationAndInsertChatterFeedItem(), updateAgentInApplicationAndInsertChatterFeedItem
                                   createUser(), createUser2(), createAccount(), createCampaign(), createAutoAssignGroup(),
                                createAgent(), createApplication() for Testing Application Trigger.

    Simon Parker 09/01/2015		SEC-197 - added createFirstStageHistory
   |-----------------------------------------------------------------------------------------------------------------------------|
*/


private class ApplicationTriggerHandler_Test {

    static testMethod void testUpdateRelatedLeadsOccurs(){
        Test.startTest();
            Account account = AccountBuilder.getBuilder('Loan.co.uk Ltd').save().getRecord();
            Campaign campaign = CampaignBuilder.getBuilder('Hubspot').setAccount(account).save().getRecord();
            Lead lead = new Lead(LastName = 'Test', Company = 'Test');
            insert lead;
            Application__c app = [SELECT Id, Application_Value__c, Stage__c, Loan_Amount__c FROM Application__c WHERE Lead__c = :lead.Id LIMIT 1];
            app.Application_Value__c = 999;
            app.Stage__c = 'Cancelled';
            app.Loan_Amount__c = 888;
            update app;
        Test.stopTest();
        lead = [SELECT Id, Application_Value__c, Application_Stage__c, Application_Loan_Amount__c FROM Lead WHERE Id = :lead.Id];
        System.assertEquals(app.Application_Value__c, lead.Application_Value__c);
        System.assertEquals(app.Stage__c, lead.Application_Stage__c);
        System.assertEquals(app.Loan_Amount__c, lead.Application_Loan_Amount__c);
    }

    static testMethod void testScheduleAwaitingPackSMSsCreatesExpectedRecords(){
        Account account = AccountBuilder.getBuilder('Test Acc').save().getRecord();
        Application__c app = ApplicationBuilder.getBuilder(account).setBusiness('Loan.co.uk').save().getRecord();
        Applicant__c applicant = ApplicantBuilder.getBuilder(app).setFirstName('Bob').setLastName('Turwilligar')
            .setMobilePhone('07777777777').setIsPrimary(true).save().getRecord();
        Test.startTest();
            app.Stage__c = 'Awaiting Pack';
            update app;
        Test.stopTest();
        List<Customer_Comms_Queue_Item__c> comms_items = [SELECT Id, Remote_Template_Name__c FROM Customer_Comms_Queue_Item__c
                WHERE Applicant__r.Application__c = :app.Id
                AND Remote_Template_Name__c LIKE 'loan-co-uk-awaiting-pack-day-%'
                ORDER BY Remote_Template_Name__c ASC];
        System.assertEquals(5, comms_items.size());
        System.assertEquals('loan-co-uk-awaiting-pack-day-1', comms_items.get(0).Remote_Template_Name__c);
        System.assertEquals('loan-co-uk-awaiting-pack-day-3', comms_items.get(1).Remote_Template_Name__c);
        System.assertEquals('loan-co-uk-awaiting-pack-day-5', comms_items.get(2).Remote_Template_Name__c);
        System.assertEquals('loan-co-uk-awaiting-pack-day-7', comms_items.get(3).Remote_Template_Name__c);
        System.assertEquals('loan-co-uk-awaiting-pack-day-9', comms_items.get(4).Remote_Template_Name__c);
    }

    static testMethod void testCancelAwaitingPackSMSsOccurs(){
        Account account = AccountBuilder.getBuilder('Test Acc').save().getRecord();
        Application__c app = ApplicationBuilder.getBuilder(account).setBusiness('Loan.co.uk').save().getRecord();
        Applicant__c applicant = ApplicantBuilder.getBuilder(app).setFirstName('Bob').setLastName('Turwilligar')
            .setMobilePhone('07777777777').setIsPrimary(true).save().getRecord();
        Test.startTest();
            app.Stage__c = 'Awaiting Pack';
            update app;
            app.Stage__c = 'Unknown??';
            update app;
        Test.stopTest();
        List<Customer_Comms_Queue_Item__c> comms_items = [SELECT Id, Cancelled__c FROM Customer_Comms_Queue_Item__c
                WHERE Applicant__r.Application__c = :app.Id
                AND Remote_Template_Name__c LIKE 'loan-co-uk-awaiting-pack-day-%'
                ORDER BY Remote_Template_Name__c ASC];
        System.assertEquals(5, comms_items.size());
        for(Customer_Comms_Queue_Item__c item:comms_items){
            System.assertEquals(true, item.Cancelled__c);
        }
    }

    @isTest static void CheckPaidOutUpdateOccurs()
    {
         //Setup Data
        Account oAccount = createAccount();
        Campaign oCampaign = createCampaign();
        User oUser = createUser();
        User oUser2 = createUser2();
        Application__c oApplication = createApplication(oAccount, oCampaign);
        lender__c oLender = CreateLender();
        Lender_Required_Documents__c oLRD = CreateLenderRequiredDocuments(oLender);
        Quote__c oQuote = createQuote(oApplication,oLender);
        Task oTask = CreateTask(oApplication,true);
        oApplication.stage__c = 'Test';
        update oApplication;

        //Run the Test - Update the Application Case Owner
        Test.startTest();
        oApplication.stage__c = 'Paid Out';
        update oApplication;
        Test.stopTest();

        // now check we have a closed task
        list<task> tlist = [select id from task where whatid= :oApplication.id and isClosed=true];
        system.assertEquals(tlist.size(),1, 'Expecting a closed task for this application?');

    }


    @isTest static void test_with_campaign() {
         account ac = new account();
         ac.name = 'Testf';
         insert ac;

         Campaign camp = new Campaign();
         camp.Lead_Cost_Type__c = 'Cost Per Lead';
         camp.CPL_Amount__c = 123;
         camp.Name = 'Test';

         insert camp;

         Application__c a = new Application__c();
         a.Account__c = ac.id;
         a.Campaign__c = camp.id;
         insert a;

         //get last ledger item and check value

         List<Ledger__c> ledgers = [Select id, Amount__c from Ledger__c];

         system.assertEquals(ledgers[0].Amount__c,-123);
    }

    @isTest static void test_without_campaign() {
         account ac = new account();
         ac.name = 'Testf';
         ac.Commission_Type__c = 'Cost Per Lead';
         ac.CPL_Amount__c = 345;
         insert ac;

         Application__c a = new Application__c();
         a.Account__c = ac.id;
         insert a;

         //get last ledger item and check value

         List<Ledger__c> ledgers = [Select id, Amount__c from Ledger__c];

         system.assertEquals(ledgers[0].Amount__c,-345);
    }

    @isTest static void assignAgentToApplicationAndInsertChatterFeedItem() {

        //Setup
        Account oAccount = createAccount();
        Campaign oCampaign = createCampaign();
        Auto_Assign_Group__c oAutoAssignGroup = createAutoAssignGroup(oCampaign);
        User oUser= createUser();
        Agent__c oAgent = createAgent(oUser, oAutoAssignGroup);

        //Run the Test - Create an Application
        Test.startTest();
        Application__c oApplication = createApplication(oAccount, oCampaign);
        Test.stopTest();

        //Check Case Owner assigned
        Application__c oApplicationTest = [Select Id, Case_Owner__c from Application__c where id =: oApplication.Id];
        system.assertEquals(oAgent.Agent__c,oApplicationTest.Case_Owner__c,'Expecting Case Owner to equal Agent');

        //Check Chatter Feed Item Object
        List<Chatter_Feed_Item__c> insertChatterFeedItem = [Select Id, Agent__c, Application__c from Chatter_Feed_Item__c];
        system.assertEquals(oAgent.Agent__c, insertChatterFeedItem[0].Agent__c, 'Expecting Agent in Chatter Feed Item');
        system.assertEquals(oApplication.Id, insertChatterFeedItem[0].Application__c, 'Expecting Application in Chatter Feed Item');

    }

    @isTest static void updateAgentInApplicationAndInsertChatterFeedItem() {

        //Setup Data
        Account oAccount = createAccount();
        Campaign oCampaign = createCampaign();
        Auto_Assign_Group__c oAutoAssignGroup = createAutoAssignGroup(oCampaign);
        User oUser = createUser();
        User oUser2 = createUser2();
        Agent__c oAgent = createAgent(oUser, oAutoAssignGroup);
        Agent__c oAgent2 = createAgent(oUser2, oAutoAssignGroup);
        Application__c oApplication = createApplication(oAccount, oCampaign);

        //Run the Test - Update the Application Case Owner
        Test.startTest();
        oApplication.Case_Owner__c = oAgent2.Agent__c;
        update oApplication;
        Test.stopTest();

        //Check Case Owner
        system.assertEquals(oAgent2.Agent__c,oApplication.Case_Owner__c,'Expecting Case Owner to equal Updated Agent');

        //Check 2nd item in Chatter Feed Item Object, ordered by CreatedDate so I know I am always getting the second Agent
        List<Chatter_Feed_Item__c> insertChatterFeedItem = [Select Id, Agent__c, Application__c from Chatter_Feed_Item__c ORDER BY CreatedDate ASC];
        system.assertEquals(oAgent2.Agent__c, insertChatterFeedItem[1].Agent__c, 'Expecting Agent in Chatter Feed Item');
        system.assertEquals(oApplication.Id, insertChatterFeedItem[1].Application__c, 'Expecting Application in Chatter Feed Item');

    }

    @isTest static void CheckCoolingOffUpdateOccurs()
    {
        UserRole role_red_team_manager = new UserRole();
        role_red_team_manager.Name = 'Red Team Manager';
        role_red_team_manager.DeveloperName = 'Red_Team_Manager';
        insert role_red_team_manager;

        UserRole role_sales_user = new UserRole();
        role_sales_user.Name = 'Red Team Sales User';
        role_sales_user.DeveloperName = 'Red_Team_Sales_User';
        role_sales_user.ParentRoleId = role_red_team_manager.Id;
        insert role_sales_user;

        UserRole role_case_manager = new UserRole();
        role_case_manager.Name = 'Red Team Case Manager';
        role_case_manager.DeveloperName = 'Red_Team_Case_Manager';
        role_case_manager.ParentRoleId = role_red_team_manager.Id;
        insert role_case_manager;

        UserRole role_processor = new UserRole();
        role_processor.Name = 'Red Team Processor';
        role_processor.DeveloperName = 'Red_Team_Processor';
        role_processor.ParentRoleId = role_red_team_manager.Id;
        insert role_processor;

        User user_sales_user    = createSalesUser(role_sales_user);
        User user_case_manager  = createCaseManager(role_case_manager);
        User user_processor     = createProcessor(role_processor);
        Account oAccount = createAccount();
        Campaign oCampaign = createCampaign();
        Application__c oApplication = createApplication(oAccount, oCampaign);
        Lender__c oLender = CreateLender();
        Lender_Required_Documents__c oLRD = CreateLenderRequiredDocuments(oLender);
        Quote__c oQuote = createQuote(oApplication,oLender);
        oApplication.Stage__c = 'Test';
        update oApplication;

        Test.startTest();
        oApplication.Case_Owner__c = user_sales_user.Id;
        oApplication.Stage__c = 'Advance copy specimen Pack Out';
        update oApplication;
        Test.stopTest();

        List<Outstanding_Items__c> oiList = [select id from Outstanding_Items__c where application__c =:oApplication.id];
        System.assertEquals(1, oilist.size(), 'Expecting an Outstanding Item For Application');
    }



    @isTest static void assignSalesUserCaseManagerToApplication() {

        //Setup
        UserRole role_red_team_manager = new UserRole();
        role_red_team_manager.Name = 'Red Team Manager';
        role_red_team_manager.DeveloperName = 'Red_Team_Manager';
        insert role_red_team_manager;

        UserRole role_sales_user = new UserRole();
        role_sales_user.Name = 'Red Team Sales User';
        role_sales_user.DeveloperName = 'Red_Team_Sales_User';
        role_sales_user.ParentRoleId = role_red_team_manager.Id;
        insert role_sales_user;

        UserRole role_case_manager = new UserRole();
        role_case_manager.Name = 'Red Team Case Manager';
        role_case_manager.DeveloperName = 'Red_Team_Case_Manager';
        role_case_manager.ParentRoleId = role_red_team_manager.Id;
        insert role_case_manager;

        UserRole role_processor = new UserRole();
        role_processor.Name = 'Red Team Processor';
        role_processor.DeveloperName = 'Red_Team_Processor';
        role_processor.ParentRoleId = role_red_team_manager.Id;
        insert role_processor;

        User user_sales_user 	= createSalesUser(role_sales_user);
        User user_case_manager 	= createCaseManager(role_case_manager);
        User user_processor	 	= createProcessor(role_processor);

        System.runAs(user_sales_user) {
            Account oAccount = createAccount();
            Campaign oCampaign = createCampaign();
            setupStages();
            Application__c oApplication = createApplication(oAccount, oCampaign);

            //Run the Test - Update an Application
            Test.startTest();
                oApplication.Stage__c = 'Underwrite';
                update oApplication;
            Test.stopTest();

        //Check Case Owner assigned
        Application__c oApplicationTest = [Select Id, Case_Owner__c, Case_Manager__c from Application__c where id =: oApplication.Id];
        system.assertEquals(user_sales_user.Id,oApplicationTest.Case_Owner__c,'Expecting Case_Owner__c to equal User with Sales User Role');

        //Check Case Manager assigned
        system.assertEquals(user_case_manager.Id,oApplicationTest.Case_Manager__c,'Expecting Case_Manager__c to equal User with Case Manager Role');
        }
    }

    @isTest static void assignProcessorToApplication() {

        //Setup
        UserRole role_red_team_manager = new UserRole();
        role_red_team_manager.Name = 'Red Team Manager';
        role_red_team_manager.DeveloperName = 'Red_Team_Manager';
        insert role_red_team_manager;

        UserRole role_sales_user = new UserRole();
        role_sales_user.Name = 'Red Team Sales User';
        role_sales_user.DeveloperName = 'Red_Team_Sales_User';
        role_sales_user.ParentRoleId = role_red_team_manager.Id;
        insert role_sales_user;

        UserRole role_case_manager = new UserRole();
        role_case_manager.Name = 'Red Team Case Manager';
        role_case_manager.DeveloperName = 'Red_Team_Case_Manager';
        role_case_manager.ParentRoleId = role_red_team_manager.Id;
        insert role_case_manager;

        UserRole role_processor = new UserRole();
        role_processor.Name = 'Red Team Processor';
        role_processor.DeveloperName = 'Red_Team_Processor';
        role_processor.ParentRoleId = role_red_team_manager.Id;
        insert role_processor;

        User user_sales_user 	= createSalesUser(role_sales_user);
        User user_case_manager 	= createCaseManager(role_case_manager);
        User user_processor	 	= createProcessor(role_processor);

        System.runAs(user_sales_user) {
            Account oAccount = createAccount();
            Campaign oCampaign = createCampaign();
            setupStages();
            Application__c oApplication = createApplication(oAccount, oCampaign);
            oApplication.Case_Owner__c = user_sales_user.Id;
            update oApplication;

            //Run the Test - Update an Application
            Test.startTest();
                oApplication.Stage__c = 'Send Advance Copy Pack';
                update oApplication;
            Test.stopTest();

        //Check Case Owner assigned
        Application__c oApplicationTest = [Select Id, Processor__c from Application__c where id =: oApplication.Id];
        system.assertEquals(user_processor.Id,oApplicationTest.Processor__c,'Expecting Processor__c to equal User with Processor Role');
        }
    }

    @isTest static void setupStages(){

            Application_Stage__c stage1 = new Application_Stage__c();
            stage1.stage__c = 'Call for full app';
            stage1.Stage_Order__c = 1;
            insert stage1;

            Application_Stage__c stage2 = new Application_Stage__c();
            stage2.stage__c = 'Underwrite';
            stage2.Stage_Order__c = 2;
            insert stage2;

            Application_Stage__c stage3 = new Application_Stage__c();
            stage3.stage__c = 'Send Advance Copy Pack';
            stage3.Stage_Order__c = 3;
            insert stage3;
    }

    @isTest static void createfirststagehistory(){

        //Setup Data
        Account oAccount = createAccount();
        Campaign oCampaign = createCampaign();
        Application_Stage__c oStage1 = createApplicationStage1();

        Test.startTest();
        Application__c oApplication = createApplication(oAccount, oCampaign);
        Test.stopTest();

        //Check if new Stage History created for Application

        List<Stage_History__c> createdStages = [Select id, Stage_Name__c from Stage_History__c WHERE Application__c=:oApplication.id];

        system.assertEquals(createdStages[0].Stage_Name__c, 'Stage 1');

    }

    // Supporting Data preparation methods


    public static User createUser() {
        // need to change these values
        List<Profile> profiles = [select Id From Profile where Name = 'System Administrator' limit 1];
        String profileId = profiles.get(0).Id;
        User user = new User();
        user.Username = 'Joe.Bloggs@forcesupport.co.uk';
        user.Email = 'Joe.Bloggs@forcesupport.co.uk';
        user.CommunityNickname = 'JBloggs';
        user.FirstName = 'Joe';
        user.LastName = 'Bloggs';
        user.Alias = 'jbl';
        user.ProfileId = profileId;
        user.EmailEncodingKey = 'ISO-2022-JP';
        user.LanguageLocaleKey = 'ja';
        user.LocaleSidKey = 'ja_JP';
        user.TimeZoneSidKey = 'Asia/Tokyo';
        insert user;
        system.assertNotEquals(user.Id , null);

        return user;
    }

    public static User createUser2() {
        // need to change these values
        List<Profile> profiles = [select Id From Profile where Name = 'System Administrator' limit 1];
        String profileId = profiles.get(0).Id;
        User user = new User();
        user.Username = 'Mark.Jackson@forcesupport.co.uk';
        user.Email = 'Mark.Jackson@forcesupport.co.uk';
        user.CommunityNickname = 'MJackson';
        user.FirstName = 'Mark';
        user.LastName = 'Jackson';
        user.Alias = 'mjac';
        user.ProfileId = profileId;
        user.EmailEncodingKey = 'ISO-2022-JP';
        user.LanguageLocaleKey = 'ja';
        user.LocaleSidKey = 'ja_JP';
        user.TimeZoneSidKey = 'Asia/Tokyo';
        insert user;
        system.assertNotEquals(user.Id , null);

        return user;
    }

    public static User createUser3() {
        // need to change these values
        List<Profile> profiles = [select Id From Profile where Name = 'System Administrator' limit 1];
        String profileId = profiles.get(0).Id;
        User user = new User();
        user.Username = 'Henry.James@forcesupport.co.uk';
        user.Email = 'Henry.James@forcesupport.co.uk';
        user.CommunityNickname = 'HJames';
        user.FirstName = 'Henry';
        user.LastName = 'James';
        user.Alias = 'hjam';
        user.ProfileId = profileId;
        user.EmailEncodingKey = 'ISO-2022-JP';
        user.LanguageLocaleKey = 'ja';
        user.LocaleSidKey = 'ja_JP';
        user.TimeZoneSidKey = 'Asia/Tokyo';
        insert user;
        system.assertNotEquals(user.Id , null);

        return user;
    }

    public static Account createAccount() {

        Account oAccount = new Account();
        oAccount.Name = 'Loans & Mortgages';
        oAccount.Business__c = 'Loan.co.uk';
        oAccount.Affiliate_ID__c = 'SAMLOAN';
        insert oAccount;
        system.assertNotEquals(oAccount.Id , null);

        return oAccount;
    }

    public static Campaign createCampaign(){

        Campaign oCampaign = new Campaign();
         oCampaign.Name = 'Test Campaign';
        oCampaign.Auto_Assign__c = true;
        insert oCampaign;
        system.assertNotEquals(oCampaign.Id , null);

        return oCampaign;
    }

    public static Auto_Assign_Group__c createAutoAssignGroup(Campaign oCampaign){

        Auto_Assign_Group__c oAutoAssignGroup = new Auto_Assign_Group__c();
        oAutoAssignGroup.Name = 'Test Auto Assign Group';
        oAutoAssignGroup.Campaign__c = oCampaign.Id;
        insert oAutoAssignGroup;
        system.assertNotEquals(oAutoAssignGroup.Id , null);

        return oAutoAssignGroup;
    }

    public static Agent__c createAgent(User oUser, Auto_Assign_Group__c oAutoAssignGroup){

        Agent__c oAgent = new Agent__c();
        oAgent.Agent__c = oUser.Id;
        oAgent.Auto_Assign_Group__c = oAutoAssignGroup.Id;
        insert oAgent;
        system.assertNotEquals(oAgent.Id , null);

        return oAgent;
    }

    public static Application__c createApplication(Account oAccount, Campaign oCampaign){

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
        oApplication.Campaign__c = oCampaign.Id;
        oApplication.Stage__c = 'Call for full app';
        insert oApplication;
        system.assertNotEquals(oApplication.Id , null);

        return oApplication;
    }

    public static quote__c createQuote(Application__c oApplication, lender__c oLender)
    {

        quote__c oQuote = new quote__c();
        oQuote.application__c = oApplication.id;
        oQuote.active__c = true;
        oQuote.Lender_Fee__c = oLender.id;
        insert oQuote;
        system.assertNotEquals(oQuote.Id , null);

        return oQuote;
    }

    public static Lender__c createLender()
    {
        Lender__c oLender = new Lender__c();
        oLender.Name = 'Lender';
        oLender.Active__c = true;
        insert oLender;
        system.assertNotEquals(oLender.id,null);
        return oLender;
    }

    public static Lender_Required_Documents__c CreateLenderRequiredDocuments(lender__c oLender)
    {
        Lender_Required_Documents__c oLRD = new Lender_Required_Documents__c();
        oLRD.Lender__c = oLender.id;
        oLRD.Item_Name__c = 'Test1';
        oLRD.Days_before_Due__c = 1;
        oLRD.Days_Before_Requested__c = 1;
        oLRD.Item_Type__c = 'Test2';
        insert oLRD;
        system.assertNotEquals(oLRD.id,null);
        return oLRD;
    }

    public static task CreateTask(application__c oApplication,boolean OpenTask)
    {
        task oTask = new Task();
        oTask.whatID = oApplication.id;
        oTask.status = 'Open';
        if (!OpenTask) oTask.status = 'Completed';
        insert oTask;
        system.assertNotEquals(otask.id,null);
        return oTask;
    }

    public static Application_Stage__c createApplicationStage1(){

        Application_Stage__c oStage1 = new Application_Stage__c();
        oStage1.stage__c = 'Stage 1';
        oStage1.Stage_Order__c = 1;
        insert oStage1;
        system.assertNotEquals(oStage1.id, null);

        return oStage1;
    }

    public static User createSalesUser(UserRole user_role) {
        // need to change these values
        List<Profile> profiles = [select Id From Profile where Name = 'System Administrator' limit 1];
        String profileId = profiles.get(0).Id;
        User user = new User();
        user.Username = 'Joe.Bloggs@forcesupport.co.uk';
        user.Email = 'Joe.Bloggs@forcesupport.co.uk';
        user.CommunityNickname = 'JBloggs';
        user.FirstName = 'Joe';
        user.LastName = 'Bloggs';
        user.Alias = 'jbl';
        user.ProfileId = profileId;
        user.EmailEncodingKey = 'ISO-2022-JP';
        user.LanguageLocaleKey = 'ja';
        user.LocaleSidKey = 'ja_JP';
        user.TimeZoneSidKey = 'Asia/Tokyo';
        user.UserRoleId = user_role.Id;
        insert user;
        system.assertNotEquals(user.Id , null);

        return user;
    }

    public static User createCaseManager(UserRole user_role) {
        // need to change these values
        List<Profile> profiles = [select Id From Profile where Name = 'System Administrator' limit 1];
        String profileId = profiles.get(0).Id;
        User user = new User();
        user.Username = 'Mark.Jackson@forcesupport.co.uk';
        user.Email = 'Mark.Jackson@forcesupport.co.uk';
        user.CommunityNickname = 'MJackson';
        user.FirstName = 'Mark';
        user.LastName = 'Jackson';
        user.Alias = 'mjac';
        user.ProfileId = profileId;
        user.EmailEncodingKey = 'ISO-2022-JP';
        user.LanguageLocaleKey = 'ja';
        user.LocaleSidKey = 'ja_JP';
        user.TimeZoneSidKey = 'Asia/Tokyo';
        user.UserRoleId = user_role.Id;
        insert user;
        system.assertNotEquals(user.Id , null);

        return user;
    }

    public static User createProcessor(UserRole user_role) {
        // need to change these values
        List<Profile> profiles = [select Id From Profile where Name = 'System Administrator' limit 1];
        String profileId = profiles.get(0).Id;
        User user = new User();
        user.Username = 'Henry.James@forcesupport.co.uk';
        user.Email = 'Henry.James@forcesupport.co.uk';
        user.CommunityNickname = 'HJames';
        user.FirstName = 'Henry';
        user.LastName = 'James';
        user.Alias = 'hjam';
        user.ProfileId = profileId;
        user.EmailEncodingKey = 'ISO-2022-JP';
        user.LanguageLocaleKey = 'ja';
        user.LocaleSidKey = 'ja_JP';
        user.TimeZoneSidKey = 'Asia/Tokyo';
        user.UserRoleId = user_role.Id;
        insert user;
        system.assertNotEquals(user.Id , null);

        return user;
    }


}