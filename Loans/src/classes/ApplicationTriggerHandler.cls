public without sharing class ApplicationTriggerHandler extends TriggerHandler{
// *******************************************
// Developer:   Simon Parker
// Name:        ApplicationTriggerHandler
// Created:     29/09/2014
// Description:
// *******************************************
/* +-----------------------------------------------------------------------------------------------------------------------------+
   | Updates                                                                                                                     |
   |-----------------------------------------------------------------------------------------------------------------------------|
   | Developer    Date          Description                                                                                      |
   +-----------------------------------------------------------------------------------------------------------------------------+
    Eddie Bates  24/11/2014     JIRA SEC-121. Added setApplicationOwner(), autoAssignGroup(), updateAgentAndChatterFeed(),
                                updateAssignedAgent(), sales_user_applications() and insertChatterFeedItem(). These are for Auto
                                Assignment of an Agent to a New/Updated Application, and Chatter Notification.
    Eddie Bates 12/01/2015      JIRA SEC-199-202. Created Before Update trigger, and added methods to update Sales User, Case
                                Manager and Processor of an Application.
    JJ          27/01/2015      SEC-268 / SEC-235 Updates to replace manual buttons to copy "out standing items" to quote and to
                                set certain
    SRP         20/03/2015      SEC-374 change to Stage__c names

    SRP         26/03/2015      SEC-388 - change to createStageHistory to set First time boolean
    Pavel       28/04/2015      SEC-481 - added updateRelatedLeads()
    Pavel       25/05/2015      SEC-512 - added scheduleAwaitingPackSMSs(), cancelAwaitingPackSMSs()
   |-----------------------------------------------------------------------------------------------------------------------------|
*/

    public static Set<Id> already_assigned_sales_users;
    public static Set<Id> already_assigned_case_managers;
    public static Set<Id> already_assigned_processors;
    public static Set<Id> already_generated_required_documents = new Set<Id>();

    public ApplicationTriggerHandler()
    {
        //  Allow both before and after triggers
        preventRecursiveTrigger_Before(5);
        preventRecursiveTrigger_After(5);
        system.debug('Recursion check!' );
        already_assigned_sales_users = new Set<Id>();
        already_assigned_case_managers = new Set<Id>();
        already_assigned_processors = new Set<Id>();

    }

    // *******************************************
    // ************* Before Insert ***************
    // *******************************************
    public override void BeforeInsert(List<SObject> newObjects){

        List<Application__c> newApplications = (List<Application__c>)newObjects;

        setApplicationOwner(newApplications);

        DoPaidOutStageChange_Before(NewObjects,null,'Insert');
        DoCoolingOffStageChange_Before(newObjects,null, 'Insert');
    }
    // *******************************************
    // ************* After Insert ****************
    // *******************************************
     public override void afterInsert(List<SObject> newObjects, Map<Id, SObject> newObjectsMap)
    {
        List<Application__c> newApplications = (List<Application__c>)newObjects;

        payAffiliateCommission(newApplications);

        //Update Case Owner of Application, if there is an Auto Assign
        autoAssignGroup(newApplications);

        createStageHistory(newApplications);

        DoCoolingOffStageChange_After(newObjects,NewObjectsMap, 'Insert');
        DoPaidOutStageChange_After(NewObjects,NewObjectsMap,'Insert');
    }

    // *******************************************
    // ************* After Update ****************
    // *******************************************
    public override void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldObjectsMap, Map<Id, SObject> newObjectsMap)
    {


        List<Application__c> newApplications = (List<Application__c>)newObjects;
        List<Application__c> oldApplications = (List<Application__c>)oldObjects;
        Map<Id, Application__c> oldApplicationsMap = (Map<Id, Application__c>)oldObjectsMap;

        updateAgentAndChatterFeed(newApplications, oldApplicationsMap);
        updateRelatedLeads(oldApplications, newApplications);
        scheduleAwaitingPackSMSs(oldApplications, newApplications);
        cancelAwaitingPackSMSs(oldApplications, newApplications);

        system.debug('After update');
        DoCoolingOffStageChange_After(oldObjects,NewObjectsMap, 'Update');
        system.debug('Doing cooling off');
        DoPaidOutStageChange_After(oldObjects,newobjectsmap,'Update');

        moveApplicationToStartingStageWhenTypeIsChanged(oldApplications, newApplications);
    }

    // *******************************************
    // ************* Before Update ***************
    // *******************************************
    public override void beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldMap, Map<Id, SObject> newMap)
    {
        DoPaidOutStageChange_Before(oldObjects,newmap,'Update');
        DoCoolingOffStageChange_Before(oldObjects,newmap,'Update');

        List<Application__c> newApplications = (List<Application__c>)newObjects;
        Map<Id, Application__c> oldApplicationsMap = (Map<Id, Application__c>)oldMap;

        List<Application__c> sales_user_applications = new List<Application__c>();
        List<Application__c> case_manager_applications = new List<Application__c>();
        List<Application__c> processor_applications = new List<Application__c>();

        Map<Application__c, Id>  application_to_sales_user_map = new Map<Application__c, Id>();
        Map<Application__c, Id>  application_to_case_manager_map = new Map<Application__c, Id>();
        Map<Application__c, Id>  application_to_processor_map = new Map<Application__c, Id>();

        for (Application__c application : newApplications) {
            Application__c oldApplication = oldApplicationsMap.get(application.Id);

            // 20/03/2015 - SEC-374 changes to Stage_c names

            if ((oldApplication.Stage__c == 'Call for full app') && (application.Stage__c == 'Underwrite') && (oldApplication.Case_Owner__c == null && !already_assigned_sales_users.contains(application.Id))){
                sales_user_applications.add(application);
                already_assigned_sales_users.add(application.Id);
            }
            if ((application.Stage__c == 'Underwrite') && (oldApplication.Case_Manager__c == null) && application.Case_Manager__c == null && !already_assigned_case_managers.contains(application.Id)){
                case_manager_applications.add(application);
                already_assigned_case_managers.add(application.Id);
            }
            if ((application.Stage__c == 'Send Advance Copy Pack') && (oldApplication.Processor__c == null && application.Processor__c == null && !already_assigned_processors.contains(application.Id))){
                processor_applications.add(application);
                already_assigned_processors.add(application.Id);
            }
        }

        if (sales_user_applications.size() > 0){
            application_to_sales_user_map = ApplicationAssignment.getSalesUser(sales_user_applications);
            Map<Id,Application__c> application_map = (Map<Id,Application__c>)newMap;

            for(Application__c application:application_to_sales_user_map.keyset()){
                application_map.get(application.Id).Case_Owner__c = application_to_sales_user_map.get(application);
            }
        }

        if (case_manager_applications.size() > 0){
            application_to_case_manager_map = ApplicationAssignment.getCaseManager(case_manager_applications);
            Map<Id,Application__c> application_map = (Map<Id,Application__c>)newMap;

            for(Application__c application:application_to_case_manager_map.keyset()){
                application_map.get(application.Id).Case_Manager__c = application_to_case_manager_map.get(application);
            }
        }

        if (processor_applications.size() > 0){
            application_to_processor_map = ApplicationAssignment.getProcessor(processor_applications);
            Map<Id,Application__c> application_map = (Map<Id,Application__c>)newMap;

            for(Application__c application:application_to_processor_map.keyset()){
                application_map.get(application.Id).Processor__c = application_to_processor_map.get(application);
            }
        }
    }
    /// *************************************************************************************************************************************************
    /// ************************************* Sub Methods Below Here ************************************************************************************
    /// *************************************************************************************************************************************************

    // *************************************************************************************
    // ******* Application Changed To Paid Out So Update Dates And Close Actions ***********
    // *************************************************************************************
    private void DoPaidOutStageChange_Before(List<sobject> oldObjects,Map<Id, SObject> newObjectsMap, String TriggerType)
    {
        List<Application__c> ProcessApplications = GetEligibleApplications(oldobjects,newObjectsMap,triggertype,'Paid Out');
        if (ProcessApplications.size()<1) return; // nothing to do

        for(Application__c a:ProcessApplications)
        {
            if (a.Completed_Date__c==null) a.Completed_Date__c=system.today();
        }

    }
    private void DoPaidOutStageChange_After(List<sobject> oldObjects,Map<Id, SObject> newObjectsMap, String TriggerType)
    {
        List<Application__c> ProcessApplications = GetEligibleApplications(oldobjects,newObjectsMap,triggertype,'Paid Out');
        if (ProcessApplications.isEmpty()) return; // nothing to do

        // get a list of applicant ID's for searching
        List<Id> idlist = new List<Id>();
        for(Application__c a:ProcessApplications) idlist.add(a.Id);

        // get all open actions into a handy pocket map for later processing
        List<task> tlist = [select Id,whatid,isclosed from task where whatid in:idlist];
        Map<Id,List<task>> taskmap = new Map<Id,List<task>>();
        for(task t:tlist)
        {
            List<task> tl = new List<task>();
            if (taskmap.containskey(t.whatid)) tl = taskmap.get(t.whatid);
            tl.add(t);
            taskmap.put(t.whatid,tl);
        }

        // set completed date and close all the actions
        List<task> t_update = new List<task>();
        for(Application__c a:ProcessApplications)
        {
            List<task> tl = taskmap.get(a.Id);
            if (tl != null && tl.size()>0)
            {
                for(task t:tl)
                {
                    if (!t.isclosed)
                    {
                        t.status = 'Completed';
                        t_update.add(t);
                    }
                }
            }
        }
        update t_update;


        // get quotes into a nice map for later recall
        Map<Id,List<Quote__c>> qmap = new Map<Id,List<Quote__c>>();
        List<Quote__c> qlist = [Select Id, Broker_Fee__c, Lender_Plan__r.Commission__c,Application__c from Quote__c WHERE Active__c = true AND Application__c in :idlist ];
        for(Quote__c q:qlist)
        {
            List<Quote__c> tempqlist = new List<Quote__c>();
            if (qmap.containskey(q.Application__c)) tempqlist = qmap.get(q.Application__c);
            tempqlist.add(q);
            qmap.put(q.Application__c,qlist);
        }

        // sort out ledger stuff
        List<Ledger__c> insertLedgerList = new List<Ledger__c>();
        for(Application__c a:ProcessApplications)
        {
            Decimal updated_ledger = a.Total_Ledger__c;
            List<Quote__c> activequotes = qmap.get(a.Id);
            if (activequotes != null && activequotes.size()>0)
            {
                Ledger__c newLedge = new Ledger__c();
                newLedge.Amount__c = activequotes[0].Broker_Fee__c;
                if (activequotes[0].Broker_Fee__c != null)
                {
                     updated_ledger += activequotes[0].Broker_Fee__c;
                }
                newLedge.Type__c = 'Broker Fee';
                newLedge.Application__c = a.Id;
                newLedge.Description__c = 'From Paid Out on Application';
                newLedge.Transaction_Date_Time__c = system.now();
                insertledgerlist.add(newLedge);

                //What - (Plan_Commission_c from row in 'Lender Plan' object that is related to the Quote where Activec is True) * Loan_Amount_c on Application object
                Ledger__c newLedge1 = new Ledger__c();
                if(activequotes[0].Lender_Plan__r.Commission__c != null)
                {
                    newLedge1.Amount__c = (activequotes[0].Lender_Plan__r.Commission__c * a.Loan_Amount__c)/100;
                    updated_ledger += (activequotes[0].Lender_Plan__r.Commission__c * a.Loan_Amount__c)/100;
                }
                newLedge1.Type__c = 'Lender Commission';
                newLedge1.Application__c = a.Id;
                newLedge1.Description__c = 'From Paid Out on Application';
                newLedge1.Transaction_Date_Time__c = system.now();
                insertledgerlist.add(newLedge1);
            }

          //29/09/2014 - code added to check for Affiliate Commission and add ledger entry
            Decimal ledgeramount = 0;
            if(a.Campaign__r.Id == null) // if no Campaign for the Application, values from the Account
            {
                if (a.Account__r.Commission_Type__c == 'Cost Per Accept ?')
                {
                    ledgeramount = a.Account__r.CPA_Amount_currency__c;
                }
                else if (a.Account__r.Commission_Type__c == 'Cost Per Accept %')
                {
                    ledgeramount = (a.Account__r.CPA_Amount__c * a.Loan_Amount__c / 100);}
                else if (a.Account__r.Commission_Type__c == 'Revenue Share')
                {
                    ledgeramount = (a.Account__r.Remuneration_Split__c * updated_ledger / 100);
                }
            }

            if(a.Campaign__r.Id != null) // if valid Campaign for the Application, values from the Campaign
            {
            if (a.Campaign__r.Lead_Cost_Type__c == 'Cost Per Accept ?'){ledgeramount = a.Campaign__r.CPA_Amount_currency__c;}
                else if (a.Campaign__r.Lead_Cost_Type__c == 'Cost Per Accept %'){ledgeramount = (a.Campaign__r.CPA_Amount__c * a.Loan_Amount__c / 100);}
                else if (a.Campaign__r.Lead_Cost_Type__c == 'Revenue Share'){ledgeramount = (a.Campaign__r.Revenue_Share_Amount__c * updated_ledger / 100);}
            }


            if (ledgeramount != 0)
            {
                Ledger__c newLedge2 = new Ledger__c();
                newLedge2.Amount__c = -ledgeramount;
                newLedge2.Type__c = 'Affiliate Cost';
                newLedge2.Application__c = a.Id;
                newLedge2.Description__c = 'Created on Paid Out button';
                newLedge2.Transaction_Date_Time__c = system.now();
                insertledgerlist.add(newLedge2);
            }

        }

        if (!insertledgerlist.isempty()) insert insertledgerlist;

        return ;
    }

    // *****************************************************************************************
    // ***** Move Outstanding Items From Lender To Quote If Cooling Off Stage ******************
    // *****************************************************************************************
    private void DoCoolingOffStageChange_Before(List<sobject> oldObjects,Map<Id, SObject> newObjectsMap, String TriggerType)
    {
        List<Application__c> ProcessApplications = GetEligibleApplications(oldobjects,newObjectsMap,triggertype,'Advance Copy Cooling Off');
        if (ProcessApplications.isEmpty()) return;

        for(Application__c a:ProcessApplications)
        {
            a.Cooling_Off_Start_Date__c = System.today();
            a.Application_Pack_Sent__c = System.today();
        }
    }

    private List<Application__c> excludeAlreadyProcessedApps(List<Application__c> application_list){
        List<Application__c> application_not_processed = new List<Application__c>();
        for(Application__c app:application_list){
            if(!already_generated_required_documents.contains(app.Id)){
                already_generated_required_documents.add(app.Id);
                application_not_processed.add(app);
            }
        }
        return application_not_processed;
    }

    private void DoCoolingOffStageChange_After(List<sobject> oldObjects,Map<Id, SObject> NewObjectsMap, String TriggerType)
    {
        List<Application__c> TempProcessApplications = GetEligibleApplications(oldobjects,newObjectsMap,triggertype,'Advance copy specimen Pack Out');
        TempProcessApplications = excludeAlreadyProcessedApps(TempProcessApplications);
        if (tempProcessApplications.isempty()) return;
        List<Id> apids = new List<Id>();
        for(Application__c a:tempProcessApplications)   apids.add(a.Id);
        Map<Id,List<Quote__c>> qmap = new Map<Id,List<Quote__c>>();
        List<Quote__c> qlist = [select Id,Application__c,Lender_Fee__c from Quote__c where Application__c in : apids and active__c=true];
        for(Quote__c q:qlist)
        {
            List<Quote__c> tempqlist = new List<Quote__c>();
            if (qmap.containskey(q.Application__c)) tempqlist = qmap.get(q.Application__c);
            tempqlist.add(q);
            qmap.put(q.Application__c, tempqlist);
        }

        // filter out any applications which don't have an "active" quote and make note of the active quote if there is one
        List<Application__c> ProcessApplications = new List<Application__c>();
        for(Application__c a:tempProcessApplications)
        {
            if(qmap.containskey(a.Id))
            {
                qlist = qmap.get(a.Id);
                if (!qlist.isempty()) ProcessApplications.add(a);
            }
        }

        Map<Id,List<Lender_Required_Documents__c>> LRDMap = new Map<Id,List<Lender_Required_Documents__c>>();
        List<Id> LenderIDList = new List<Id>();
        for(Application__c a:ProcessApplications)
        {
            qlist = qmap.get(a.Id);
            Quote__c TheQuote = qlist[0];
            LenderIDList.add(TheQuote.Lender_Fee__c);
        }
        List <Lender_Required_Documents__c> LenderRequiredDocuments = [Select Days_before_Due__c, Days_Before_Requested__c, Item_Name__c,
                                                                            Item_Type__c, Name, Id , Lender__c
                                                                            from Lender_Required_Documents__c
                                                                                WHERE Lender__c in :LenderIDList];

        for(Lender_Required_Documents__c lrd:LenderRequiredDocuments)
        {
            List<Lender_Required_Documents__c> TempLRD = new List<Lender_Required_Documents__c>();
            if (LRDMap.containskey(lrd.lender__c)) TempLRD = LRDMap.get(lrd.lender__c);
            templrd.add(lrd);
            lrdmap.put(lrd.lender__c,templrd);
        }

        List<Outstanding_Items__c> outstandingItems = new List<Outstanding_Items__c>();
        for(Application__c a:ProcessApplications)
        {
            qlist = qmap.get(a.Id);
            Quote__c TheQuote = qlist[0];
            LenderRequiredDocuments = lrdmap.get(Thequote.Lender_Fee__c);

            if (LenderRequiredDocuments != null && LenderRequiredDocuments.size()>0)
            {
                for(Lender_Required_Documents__c lrd : LenderRequiredDocuments)
                {

                    Date scheduledDate = Date.today();
                    Date dueDate = Date.today();

                    if(lrd.Days_Before_Requested__c != null)
                    {
                        scheduledDate = scheduledDate.addDays(lrd.Days_Before_Requested__c.intValue());
                    }

                    if(lrd.Days_before_Due__c != null)
                    {
                        dueDate = scheduledDate.addDays(lrd.Days_before_Due__c.intValue());
                    }

                    Outstanding_Items__c getDocsData = new Outstanding_Items__c();

                    getDocsData.Item_Name__c = lrd.Item_Name__c;
                    getDocsData.Item_Type__c = lrd.Item_Type__c;
                    getDocsData.Application__c = a.Id;
                    getDocsData.Scheduled_Date__c = scheduledDate;
                    getDocsData.Due_Date__c = dueDate;

                    outstandingItems.add(getDocsData);
                }
            }
        }
        insert outstandingItems;
    }

    // *****************************************************************************************
    // ****** Get Eligible Trigger Applicants (ie. Stage Has Changed To xxxxxxx)   *************
    // *****************************************************************************************

    private List<Application__c> GetEligibleApplications(List<sobject> oldObjects,Map<Id, SObject> NewObjectsMap, String TriggerType, String NewStage)
    {
        List<Application__c> TempProcessApplications = new List<Application__c>();
        // check if the stage has changed to "cooling off" and if has, make a list of applications to be processed.
        if(TriggerType=='Update')
        {
            for(sobject so:oldobjects)
            {
                Application__c a = (Application__c)so;
                Application__c newa = (Application__c)newObjectsMap.get(a.Id);
                if (a.Stage__c != NewStage && newa.stage__c ==NewStage)
                {
                    TempProcessApplications.add(newa);
                }
            }
        }
        else
        {
            for(sobject so:oldobjects)
            {
                Application__c a = (Application__c)so;
                if(a.stage__c ==NewStage) TempProcessApplications.add(a);
            }
        }
        return tempProcessApplications;
    }

    // ********************************************************************


    private void updateAgentAndChatterFeed(List<Application__c> applications, Map<Id, Application__c> oldApplicationsMap) {

        // Create a savepoint to Rollback on Error
        Savepoint sp = Database.setSavepoint();

        String agentId;

        List<Chatter_Feed_Item__c> chatterFeedItems = new List<Chatter_Feed_Item__c>();

        for (Application__c application : applications) {
            Application__c oldApplication = oldApplicationsMap.get(application.Id);
            if (application.Case_Owner__c != oldApplication.Case_Owner__c){

                updateAssignedAgent(application, sp);

                agentId = application.Case_Owner__c;
                insertChatterFeedItem(agentId, application, sp, 'reassigned');

            }
        }

    }

    public void updateAssignedAgent(Application__c application, Savepoint sp){

        List<Agent__c> agentsToUpdate = new List<Agent__c>();

        List<Agent__c> agents = [Select Id, Agent__c, Name, Auto_Assign_Group__c, Last_Assignment__c, Millisecond__c from Agent__c WHERE Agent__c =: application.Case_Owner__c AND Auto_Assign_Group__c IN (Select Id from Auto_Assign_Group__c WHERE Campaign__c =: application.Campaign__c)];

            if (agents.size()>0){

                For(Agent__c agent : agents){

                    //Set last assignment datetime for the Agent
                    datetime now = datetime.now();
                    agent.Last_Assignment__c = now;
                    agent.Millisecond__c = now.millisecondGMT();

                    agentsToUpdate.add(agent);

                }
            }
        if (agentsToUpdate.size() > 0){

            try
            {
                update agentsToUpdate;
            }
            catch (System.DmlException e)
            {
                System.debug('ERROR: Not able to Update Agents: ' + e);
                // Rollback
                Database.rollback(sp);
            }
        }
    }

    public void setApplicationOwner(List<Application__c> newApplications){

        // Create a savepoint to Rollback on Error
        Savepoint sp = Database.setSavepoint();

        Set<Id> autoAssignGroupIds = new Set<Id>();
        Set<Id> campaignIds = new Set<Id>();
        //Map<Id, Application__c> app_map = new Map<Id,Application__c>(newApplications);

        For(Application__c theApplication : newApplications){

            campaignIds.add(theApplication.Campaign__c);
        }
        //Check if the Application is linked to a Campaign and has Auto Assign set to True
        List<Campaign> theCampaign = [Select Id, Auto_Assign__c, ( Select Name, Id from Auto_Assign_Groups_Campaign__r) from Campaign WHERE Id IN :campaignIds AND Auto_Assign__c = true];

        //A Campaign exists so we need to auto assign it to an Agent
        if (theCampaign.size()>0){

            for(Campaign camp: theCampaign){

                for(Auto_Assign_Group__c aag: camp.Auto_Assign_Groups_Campaign__r){

                    autoAssignGroupIds.add(aag.Id);
                }
            }
        }

        //The below SOQL needs to be taken out of the theApplication For Loop above as the last step
        //If Test is running remove 'where LastLoginDate = TODAY'
        List<Agent__c> agents;
        if(!Test.isRunningTest()){
            agents = [Select Id, Agent__c, Name, Auto_Assign_Group__c, Last_Assignment__c, Millisecond__c from Agent__c WHERE Auto_Assign_Group__c in :autoAssignGroupIds
                                                AND Agent__c in (select Id from User where LastLoginDate = TODAY)
                                                ORDER BY Last_Assignment__c ASC, Millisecond__c DESC LIMIT 1];
        }
        else{
            agents = [Select Id, Agent__c, Name, Auto_Assign_Group__c, Last_Assignment__c, Millisecond__c from Agent__c WHERE Auto_Assign_Group__c in :autoAssignGroupIds
                                                AND Agent__c in (select Id from User)
                                                ORDER BY Last_Assignment__c ASC, Millisecond__c DESC LIMIT 1];
        }

        For(Application__c theApplication : newApplications){

            //Assign the Application to an Agent
            if (agents.size()>0){

                For(Agent__c agent : agents){

                    //Assign the new Owner
                    theApplication.Case_Owner__c = agent.Agent__c;

                }
            }
        }

    }

    public void autoAssignGroup(List<Application__c> newApplications){

        // Create a savepoint to Rollback on Error
        Savepoint sp = Database.setSavepoint();

        Set<Id> ApplicationIds = (new Map<Id,Application__c>(newApplications)).keySet();
        List<Application__c> theApplications = [Select Id, Case_Owner__c, Campaign__c, Name, Loan_Amount__c from Application__c WHERE Id IN:ApplicationIds];


        For(Application__c theApplication : theApplications){


            //Check if the Application is linked to a Campaign and has Auto Assign set to True
            List<Campaign> theCampaign = [Select Id, Auto_Assign__c, ( Select Name, Id from Auto_Assign_Groups_Campaign__r) from Campaign WHERE Id =:theApplication.Campaign__c AND Auto_Assign__c = true];

            //A Campaign exists so we need to auto assign it to an Agent
            if (theCampaign.size()>0){

                for(Campaign camp: theCampaign){

                    for(Auto_Assign_Group__c aag: camp.Auto_Assign_Groups_Campaign__r){

                        //Update the Agents Assigned details
                        sales_user_applications(aag, theApplication, sp);
                    }
                }
            }

        }

    }

    public void sales_user_applications(Auto_Assign_Group__c aag, Application__c theApplication, Savepoint sp){

        String agentId;

        List<Agent__c> agentsToUpdate = new List<Agent__c>();
        //If Test is running remove 'where LastLoginDate = TODAY'
        List<Agent__c> agents;

        if(!Test.isRunningTest()){
            agents = [Select Id, Agent__c, Name, Auto_Assign_Group__c, Last_Assignment__c, Millisecond__c from Agent__c WHERE Auto_Assign_Group__c =: aag.Id
                                                AND Agent__c in (select Id from User where LastLoginDate = TODAY)
                                                ORDER BY Last_Assignment__c ASC, Millisecond__c DESC LIMIT 1];
        }
        else{
            agents = [Select Id, Agent__c, Name, Auto_Assign_Group__c, Last_Assignment__c, Millisecond__c from Agent__c WHERE Auto_Assign_Group__c =: aag.Id
                                                AND Agent__c in (select Id from User)
                                                ORDER BY Last_Assignment__c ASC, Millisecond__c DESC LIMIT 1];
        }

        if (agents.size()>0){

            For(Agent__c agent : agents){

                //Get the Agents Id
                agentId = agent.Agent__c;

                //Set last assignment datetime for the Agent, this is used for the Round Robin functionality
                //so that each Agent is assigned Applications equally
                datetime now = datetime.now();
                agent.Last_Assignment__c = now;
                agent.Millisecond__c = now.millisecondGMT();


                agentsToUpdate.add(agent);

                //Insert a Feed to Post
                insertChatterFeedItem(agentId, theApplication, sp, 'assigned');

            }
        }

        if (agentsToUpdate.size() > 0){
            try
            {
                update agentsToUpdate;
            }
            catch (System.DmlException e)
            {
                System.debug('ERROR: Not able to Update Agents: ' + e);
                // Rollback
                Database.rollback(sp);
            }
        }
    }

    public void insertChatterFeedItem(String agentId, Application__c theApplication, Savepoint sp, String assignType){

        String agentMessage;
        List<Chatter_Feed_Item__c> chatterFeedItems = new List<Chatter_Feed_Item__c>();

        //Create the Message to Post to Chatter
        agentMessage = theApplication.Name + ' with Loan Amount ?' + theApplication.Loan_Amount__c + ' has been ' + assignType + ' to: ';

        Chatter_Feed_Item__c getChatterFeedData = new Chatter_Feed_Item__c();
        getChatterFeedData.Message__c = agentMessage;
        getChatterFeedData.Agent__c = agentId;
        getChatterFeedData.Application__c = theApplication.Id;

        chatterFeedItems.add(getChatterFeedData);

        if (chatterFeedItems.size() > 0){
            try
                {
                    insert chatterFeedItems;
                }
                catch (System.DmlException e)
                {
                    System.debug('ERROR: Not able to Insert Chatter Feed Items: ' + e);
                    // Rollback
                    Database.rollback(sp);
                }
        }
    }


    public void payAffiliateCommission(List<Application__c> newApplications){

        Set<Id> ApplicationIds = (new Map<Id,Application__c>(newApplications)).keySet();
        List<Application__c> theApplications = [Select Id, Campaign__r.Id, Account__r.Commission_Type__c, Account__r.CPL_Amount__c, Campaign__r.Lead_Cost_Type__c, Campaign__r.CPL_Amount__c from Application__c WHERE Id IN:ApplicationIds];
        List<Ledger__c> newLedgers = new List<Ledger__c>();

        For(Application__c theApplication : theApplications){
            Decimal ledgeramount = 0;
            if((theApplication.Campaign__r.Id == null) && (theApplication.Account__r.Commission_Type__c == 'Cost Per Lead')){
                ledgeramount = theApplication.Account__r.CPL_Amount__c;
            }
            if((theApplication.Campaign__r.Id != null) && (theApplication.Campaign__r.Lead_Cost_Type__c == 'Cost Per Lead')){
                ledgeramount = theApplication.Campaign__r.CPL_Amount__c;
            }
            if (ledgeramount > 0){
                Ledger__c newLedge = new Ledger__c();
                newLedge.Amount__c = -ledgeramount;
                newLedge.Type__c = 'Affiliate Cost';
                newLedge.Application__c = theApplication.Id;
                newLedge.Description__c = 'Paid out on Application Creation';
                newLedge.Transaction_Date_Time__c = System.now();
                newLedgers.add(newLedge);
            }
        }
        if(newLedgers.size()>0){
            insert newLedgers;
        }
    }

    public void createStageHistory(List<Application__c> newApplications){
        Set<Id> ApplicationIds = (new Map<Id,Application__c>(newApplications)).keySet();
        List<Application__c> theApplications = [Select Id, Campaign__r.Id, Account__r.Commission_Type__c, Account__r.CPL_Amount__c,
                Campaign__r.Lead_Cost_Type__c, Campaign__r.CPL_Amount__c, Application_Type__c from Application__c WHERE Id IN:ApplicationIds];
        List<Stage_History__c> newStageHistories = new List<Stage_History__c>();

        List<Application_Stage__c> firstStages = [Select Id, Stage_Order__c, Application_Type__c from Application_Stage__c WHERE Stage_Order__c=1];

        if (!firstStages.IsEmpty()){
            for (Application__c the_app : theApplications){
                Stage_History__c newStage = new Stage_History__c();
                newStage.Application__c = the_app.Id;
                newStage.Application_Stage_lkup__c = getFirstStageId(firstStages, the_app.Application_Type__c);
                newStage.Started_Date_Time__c = system.now();
                //26/03/2015 first time set
                newStage.First_Time_in_Stage__c = true;
                newStageHistories.add(newStage);
            }
        insert newStageHistories;
        }
    }

    private String getFirstStageId(List<Application_Stage__c> stages, String application_type){
        for(Application_Stage__c s:stages){
            if(s.Application_Type__c == application_type){
                return s.Id;
            }
        }
        return null;
    }

    private void updateRelatedLeads(List<Application__c> old_applications, List<Application__c> new_applications){
        List<Lead> leads_to_update = new List<Lead>();
        for(Integer i=0; i<new_applications.size(); i++){
            Application__c new_app = new_applications.get(i);
            Application__c old_app = old_applications.get(i);
            if(new_app.Lead__c != null &&
                (old_app.Application_Value__c != new_app.Application_Value__c ||
                 old_app.Stage__c != new_app.Stage__c ||
                 old_app.Loan_Amount__c != new_app.Loan_Amount__c)
              ){
                    Lead updated_lead = new Lead(Id = new_app.Lead__c);
                    updated_lead.Application_Value__c = new_app.Application_Value__c;
                    updated_lead.Application_Stage__c = new_app.Stage__c;
                    updated_lead.Application_Loan_Amount__c = new_app.Loan_Amount__c;
                    leads_to_update.add(updated_lead);
            }
        }
        update leads_to_update;
    }

    private void scheduleAwaitingPackSMSs(List<Application__c> old_applications, List<Application__c> new_applications){
        Set<Id> awaiting_pack_app_ids = new Set<Id>();
        for(Integer i=0; i<new_applications.size(); i++){
            Application__c new_app = new_applications.get(i);
            Application__c old_app = old_applications.get(i);
            if(old_app.Stage__c != new_app.Stage__c && new_app.Stage__c == 'Awaiting Pack' && new_app.Business__c == 'Loan.co.uk'){
                awaiting_pack_app_ids.add(new_app.Id);
            }
        }

        if(!awaiting_pack_app_ids.isEmpty()){
            List<Customer_Comms_Queue_Item__c> new_comms_items = new List<Customer_Comms_Queue_Item__c>();
            for(Applicant__c applicant:[SELECT Id FROM Applicant__c WHERE Mobile_Phone__c != null AND Is_Primary__c = true AND Application__c IN :awaiting_pack_app_ids]){
                new_comms_items.addAll(getAwaitingPackCommsItemsForApplicant(applicant));
            }
            insert new_comms_items;
        }
    }

    private List<Customer_Comms_Queue_Item__c> getAwaitingPackCommsItemsForApplicant(Applicant__c applicant){
        List<Customer_Comms_Queue_Item__c> new_comms_items = new List<Customer_Comms_Queue_Item__c>();
        //SMS templates to be used: loan-co-uk-awaiting-pack-day-1, loan-co-uk-awaiting-pack-day-3,
        //loan-co-uk-awaiting-pack-day-5, loan-co-uk-awaiting-pack-day-7, loan-co-uk-awaiting-pack-day-9
        for(Integer i=1; i<=9; i+=2){
            Customer_Comms_Queue_Item__c awaiting_pack_sms = CustomerCommsQueueItemBuilder.getBuilder(CustomerCommsQueueItemBuilder.ItemType.SMS, applicant)
                .setRemoteTemplateName('loan-co-uk-awaiting-pack-day-' + i)
                .setSendDateTime(System.now().addDays(i-1)) //Sending SMS on day 1, 3, 5, 7, 9
                .setApplicationStageToHandle('Awaiting Pack')
                .getRecord();
            new_comms_items.add(awaiting_pack_sms);
        }
        return new_comms_items;
    }

    private void cancelAwaitingPackSMSs(List<Application__c> old_applications, List<Application__c> new_applications){
        Set<Id> awaiting_pack_app_ids = new Set<Id>();
        for(Integer i=0; i<new_applications.size(); i++){
            Application__c new_app = new_applications.get(i);
            Application__c old_app = old_applications.get(i);
            if(old_app.Stage__c != new_app.Stage__c && old_app.Stage__c == 'Awaiting Pack' && new_app.Business__c == 'Loan.co.uk'){
                awaiting_pack_app_ids.add(new_app.Id);
            }
        }

        if(!awaiting_pack_app_ids.isEmpty()){
            List<Customer_Comms_Queue_Item__c> comms_items_to_cancel = [SELECT Id, Cancelled__c FROM Customer_Comms_Queue_Item__c
                WHERE Applicant__r.Application__c IN :awaiting_pack_app_ids
                AND Sent__c = false
                AND Remote_Template_Name__c LIKE 'loan-co-uk-awaiting-pack-day-%'];
            for(Customer_Comms_Queue_Item__c comms_item:comms_items_to_cancel){
                comms_item.Cancelled__c = true;
            }
            update comms_items_to_cancel;
        }
    }

    private void moveApplicationToStartingStageWhenTypeIsChanged(List<Application__c> old_applications, List<Application__c> new_applications){
        for(Integer i=0; i<new_applications.size(); i++){
            Application__c new_app = new_applications.get(i);
            Application__c old_app = old_applications.get(i);
            if(old_app.Application_Type__c != new_app.Application_Type__c){
                ApplicationMovetoStage.runFlow(new_app.Id, 1, new_app.Application_Type__c);
            }
        }
    }
}