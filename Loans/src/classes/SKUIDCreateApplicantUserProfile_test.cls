@isTest
private class SKUIDCreateApplicantUserProfile_test {
	
	@isTest static void TestNoApplicants() {

		ID appID = setupApplication();

		Test.startTest();

		string upid = SKUIDCreateApplicantUserProfile.createUP(appID);

		Test.stopTest();

		Application__c theApp = [Select id, User_Profile__c from Application__c WHERE id=:appID LIMIT 1];

		System.assertEquals(theApp.User_Profile__c,upid,'Failure with setting new user profileID');
	}

	@isTest static void TestWithApplicantNoUP() {

		ID appID = setupApplication();

		setupApplicant(appID);

		Test.startTest();

		string upid = SKUIDCreateApplicantUserProfile.createUP(appID);

		Test.stopTest();

		Application__c theApp = [Select id, User_Profile__c from Application__c WHERE id=:appID LIMIT 1];

		System.assertEquals(theApp.User_Profile__c,upid,'Failure with setting new user profileID');
	}

	@isTest static void TestWithApplicantWithUP() {

		ID appID = setupApplication();

		setupApplicant(appID);

		String existingUP = setupUserProfile(appID);

		Test.startTest();

		string upid = SKUIDCreateApplicantUserProfile.createUP(appID);

		Test.stopTest();

		Application__c theApp = [Select id, User_Profile__c from Application__c WHERE id=:appID LIMIT 1];

		System.assertEquals(theApp.User_Profile__c,existingUP,'Failure with setting new user profileID');
	}
	
	private static ID setupApplication(){

		Account acc = new Account();
		acc.Name = 'Bobs Loans';
		insert acc;

		Application__c app = new Application__c();
		app.Account__c = acc.id;
		app.Stage__c = 'Stage 1';
		insert app;
		return app.id;
	}

	private static void setupApplicant(ID appID){

		Applicant__c appl = new Applicant__c();
		appl.Email_Address__c = 'test@test.com';
		appl.Application__c = appID;
		insert appl;
	}

	private static ID setupUserProfile(ID appID){

		User_Profile__c up = new User_Profile__c();
		up.Username__c = 'test@test.com';
		up.Password__c = 'password';
		insert up;

		Application__c thisapp = [Select id, User_Profile__c from Application__c WHERE id=:appID LIMIT 1];
		thisapp.User_Profile__c = up.id;
		update thisapp;
		return up.id;
	}
}