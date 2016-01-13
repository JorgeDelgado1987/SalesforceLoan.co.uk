@isTest
private class SKUIDValidateApplication_test {
	
	@isTest static void test_validateapplication_noapplication() {
		
		Test.startTest();

		string response = SKUIDValidateApplication.validateApplication('gggggg');

		Test.stopTest();

		System.assertEquals('Error : application does not exist',response,'Expected Error message');
	}

	@isTest static void test_validateapplication_withapplication() {
		ID appID = setupApplication();

		Test.startTest();

		string response = SKUIDValidateApplication.validateApplication(appID);

		Test.stopTest();

		System.assertEquals('Validation Failure',response.substring(0,18),'Expected Validation Failure message');
	}

	@isTest static void test_validateapplication_withapplicants() {
		ID appID = setupApplication();
		setupApplicant(appID);
		setupProperty(appID);

		Test.startTest();

		string response = SKUIDValidateApplication.validateApplication(appID);

		Test.stopTest();

		System.assertEquals('Validation Failure : if any Applicant has Marital Status of Married then there must be 2 or more Applicants. ',response,'Expected Validation Failure message');
	}

	@isTest static void test_validateapplication_withpropertynot3years() {
		ID appID = setupApplication();
		setupApplicant(appID);
		setupProperty2(appID);

		Test.startTest();

		string response = SKUIDValidateApplication.validateApplication(appID);

		Test.stopTest();

		System.assertEquals('Validation Failure',response.substring(0,18),'Expected Validation Failure message');
	}

	@isTest static void test_validateapplication_withpropertywith3years() {
		ID appID = setupApplication();
		setupProperty2(appID);
		setupProperty3(appID);

		Test.startTest();

		string response = SKUIDValidateApplication.validateApplication(appID);

		Test.stopTest();

		System.assertEquals('Passed',response,'Expected Passed message');
	}

	@isTest static void test_validateapplication_complete() {
		ID appID = setupApplication();
		setupApplicant(appID);
		setupApplicant2(appID);
		setupProperty(appID);

		Test.startTest();

		string response = SKUIDValidateApplication.validateApplication(appID);

		Test.stopTest();

		System.assertEquals('Passed',response,'Expected Passed message');
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
		appl.Marital_Status__c = 'Married';
		insert appl;
	}	

private static void setupProperty(ID appID){

		Property__c prop = new Property__c();
		prop.Date_Moved_In__c = Date.today().addYears(-3);
		prop.Application__c = appID;
		insert prop;
}

private static void setupProperty2(ID appID){

		Property__c prop = new Property__c();
		prop.Date_Moved_In__c = Date.today().addYears(-2);
		prop.Application__c = appID;
		insert prop;
}

private static void setupProperty3(ID appID){

		Property__c prop = new Property__c();
		prop.Date_Moved_Out__c = Date.today().addYears(-2);
		prop.Date_Moved_In__c = Date.today().addYears(-3);
		prop.Application__c = appID;
		insert prop;
}

private static void setupApplicant2(ID appID){

		Applicant__c appl = new Applicant__c();
		appl.Email_Address__c = 'test@test.com';
		appl.Application__c = appID;
		insert appl;
	}	


}