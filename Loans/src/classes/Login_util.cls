public without sharing class Login_util {
	
	//**************************************
	//
	//  Created 21/01/2015 - Simon Parker 
	//  Methods to support login & password processes
	//
	//**************************************

	// 30/01/2015 - SEC-279 - createLoginHistory added - SRP


	public static string createUserProfile(string AppID){
		//get first Applicant on the application
		User_Profile__c myUP = new User_Profile__c();
		List<Applicant__c> theApplicants = [Select id, Email_address__c, Mobile_phone__c from Applicant__c WHERE Application__c=:AppID];
		if (theApplicants.size()>0){
			myUP.Username__c = theApplicants[0].Email_address__c;
			myUP.Mobile__c = theApplicants[0].Mobile_phone__c;
			myUP.Password__c = Utility.generatePassword();
			insert myUP;
			return myUP.id;
		}
		return null;
	}


	public static string createLoginHistory(string UserProfileID, string UserId, string LoginResult){

		Login_History__c newLoginHist = new Login_History__c();
		newLoginHist.User_Profile__c = UserProfileID;
		newLoginHist.Login_Request__c = system.now();
		newLoginHist.Login_source__c = UserId;
		newLoginHist.Login_Result__c = LoginResult;

		insert newLoginHist;
		return newLoginHist.id;

	}
}