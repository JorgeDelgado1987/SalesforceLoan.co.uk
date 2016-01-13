@isTest
private class Login_util_test {
	
	@isTest static void login_util_create_user_profile_no_applicants() {

		Account account = new Account();
		account.Name = 'First';
		account.Phone = '123456788';
        insert account;

        Application__c myApp = new Application__c();
        myApp.Account__c = account.id;
        insert myApp;

        Test.startTest();

        String result = Login_util.createUserProfile(myApp.id);


        system.assertEquals(null,result,'Error with USer Profile ID expected null');
		

	}

	@isTest static void login_util_create_user_profile_with_applicants() {

		Account account = new Account();
		account.Name = 'First';
		account.Phone = '123456788';
        insert account;

        Application__c myApp = new Application__c();
        myApp.Account__c = account.id;
        insert myApp;

        Applicant__c theApplicant = new Applicant__c();
        theApplicant.Email_Address__c = 'test@test.com';
        theApplicant.Mobile_phone__c = '07777777777';
        theApplicant.Application__c = myApp.id;
        insert theApplicant;

        Test.startTest();

        String result = Login_util.createUserProfile(myApp.id);

        system.assertNotEquals('',result,'Error with expected USer Profile ID');

        List<User_Profile__c> theUP = [Select id, Username__c, PAssword__c, Mobile__c from User_Profile__c WHERE id=:result LIMIT 1];

        system.assertEquals(1,theUP.size(),'Error with new USer Profile created');

        system.assertEquals('test@test.com', theUP[0].Username__c,'Error with UP created with email for username');
		

	}
	
	
	
}