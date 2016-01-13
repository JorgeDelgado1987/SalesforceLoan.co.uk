global class SKUIDCreateApplicantUserProfile{
	// 26/01/2015 - Simon Parker
	// webservice to create userprofile from SKUID page snippet

	webservice static String createUP(string ApplicationID){

		String thisUP = '';

		//first check for any user profiles with first applicant email address

		Application__c thisApplication = [Select id, User_Profile__c from Application__c WHERE id=:ApplicationID LIMIT 1];

		List<Applicant__c> myApplicants = [Select id, email_address__c from Applicant__c WHERE Application__c = :ApplicationID];

		if (myApplicants.size()>0){
			List<User_Profile__c> existingUP = [Select id from User_Profile__c WHERE username__c = :myApplicants[0].email_address__c ];
			if (existingUP.size()>0){
				thisUP = existingUP[0].id;
			}
			else{
				thisUP = Login_util.createUserProfile(ApplicationID);
			}
		}
		else{
			thisUP = Login_util.createUserProfile(ApplicationID);
		}

		thisApplication.User_Profile__c = thisUP;
		update thisApplication;

		return thisUP;
	}
}