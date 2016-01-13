global class SKUIDValidateApplication {

	// 07/04/2015 - Simon Parker
	// webservice to validate application from SKUID page snippet

	webservice static String validateApplication(string ApplicationID){

		List<Application__c> applications = [Select id from Application__c WHERE id=:ApplicationID LIMIT 1];
		if (applications.size() < 1){
			return 'Error : application does not exist';
		}


		String response = '';

		//Check all applicants - if Marital Status = Married then Number of Applicants >= 2

		List<Applicant__c> allApplicants = [Select id from Applicant__c WHERE Application__c=:ApplicationID];
		List<Applicant__c> marriedApplicants = [Select id, Marital_Status__c from Applicant__c WHERE Application__c=:ApplicationID AND Marital_Status__c = 'Married'];

		if (marriedApplicants.size()>0 && allApplicants.size() < 2){
			response = 'Validation Failure : if any Applicant has Marital Status of Married then there must be 2 or more Applicants. ';
		}

		//Check all properties - either Current Address or Previous Property - and get oldest Date Moved In - must be > 3 years ago

		//First check that at least one property does not have a moved out date
		Date threeyearsago = Date.today().addYears(-3);
		Boolean hasthreeyears = false;
		List<Property__c> currentproperties = [Select id, Date_Moved_In__c from Property__c WHERE Application__c=:ApplicationID AND Date_Moved_Out__c = null ORDER BY Date_Moved_In__c ASC];

		if (currentproperties.size() <1){
			response += 'Validation Failure : Application must have at least 1 property without a Moved Out date - a current property.  ';
		}

		//check through all current properties to see if any have been lived in for > 3 years
		else{
			for (Property__c prop : currentproperties){
				if (prop.Date_Moved_In__c <= threeyearsago){
					hasthreeyears = true;
				}
			}
			if (hasthreeyears == false){
				//Don't have three years within current addresses, so need to go back through those they have moved out from
				Date earliestmovedindate = currentproperties[0].Date_Moved_In__c;
				//get previous properties (have moved out) with most recent moved out first
				List<Property__c> previousproperties = [Select id, Date_Moved_In__c, Date_Moved_Out__c from Property__c WHERE Application__c=:ApplicationID AND Date_Moved_Out__c != null ORDER BY Date_Moved_Out__c DESC];
				//loop through previous properties
				for (Property__c prop : previousproperties){
					if (prop.Date_Moved_Out__c < earliestmovedindate){ // break in successive dates so error
						break;
					}
					else{
						if (prop.Date_Moved_In__c <= threeyearsago){
							hasthreeyears = true;
							break;
						}
					}
					earliestmovedindate = prop.Date_Moved_In__c;
				}
			}
		}

		if (!hasthreeyears){
			response += 'Validation Failure : Application must have at least 3 years of address history provided.';
		}

		if (response == ''){
			response = 'Passed';
		}


		return response;
	}
}