@isTest
private class ApplicationRollbackStage_test {

    @isTest static void testCallingApplicationRollbackStageFlowMovesApplicationBack1Stage() {

        ID appID = setupData();

        Test.startTest();

        ApplicationRollbackStage.runFlow(appID, 'Secured Loan');

        Test.stopTest();

        Application__c theApp = [Select id, Stage__c from Application__c WHERE id=:appID LIMIT 1];

        System.assertEquals(theApp.Stage__c,'Stage 1','Failure with calling Flow');

    }


    private static ID	setupData(){

            Application_Stage__c stage1 = new Application_Stage__c();
            stage1.stage__c = 'Stage 1';
            stage1.Stage_Order__c = 1;
            insert stage1;

            Application_Stage__c stage2 = new Application_Stage__c();
            stage2.stage__c = 'Stage 2';
            stage2.Stage_Order__c = 2;
            insert stage2;

            Account acc = new Account();
            acc.Name = 'Bobs Loans';
            insert acc;

            Application__c app = new Application__c();
            app.Account__c = acc.id;
            app.Stage__c = 'Stage 2';
            insert app;

            Stage_History__c appstage1 = new Stage_History__c();
            appstage1.Application__c = app.id;
            appstage1.Application_Stage_lkup__c = stage2.id;
            appstage1.Started_Date_Time__c = system.now();
            appstage1.Completed__c = false;
            insert appstage1;

            return app.id;
    }
}