@isTest
private class ApplicationNextStage_test {

	@isTest static void testCallingApplicationNextStageFlowMovesApplicationToNextStage() {
		
		ID appID = setupData();

		ID outcomeID = setupOutcome(appID);

		Test.startTest();

		ApplicationNextStage.runFlow(appID, outcomeID, 'Secured Loan');

		Test.stopTest();

		Application__c theApp = [Select id, Stage__c from Application__c WHERE id=:appID LIMIT 1];

		System.assertEquals(theApp.Stage__c,'Stage 2','Failure with calling Flow');

	}


	private static ID	setupData(){

			Account acc = new Account();
			acc.Name = 'Bobs Loans';
			insert acc;

			Application__c app = new Application__c();
			app.Account__c = acc.id;
			app.Stage__c = 'Stage 1';
			insert app;

			return app.id;
	}

	private static ID setupOutcome(ID AppID){

			Application_Stage__c stage1 = new Application_Stage__c();
			stage1.stage__c = 'Stage 1';
			stage1.Stage_Order__c = 1;
			insert stage1;

			Application_Stage__c stage2 = new Application_Stage__c();
			stage2.stage__c = 'Stage 2';
			stage2.Stage_Order__c = 2;
			insert stage2;

			Stage_History__c appstage1 = new Stage_History__c();
			appstage1.Application__c = AppID;
			appstage1.Application_Stage_lkup__c = stage1.id;
			appstage1.Started_Date_Time__c = system.now();
			appstage1.Completed__c = false;
			insert appstage1;	

			Stage_Outcome__c out1 = new Stage_Outcome__c();
			out1.Application_Stage__c = stage1.id;
			out1.Outcome__c = 'Stage OK';
			out1.Next_Step__c = 'Move to Next Stage';
			insert out1;

			return out1.id;
	}
}