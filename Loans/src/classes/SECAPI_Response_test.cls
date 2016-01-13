@isTest

private class SECAPI_Response_test {
		@isTest static void test_createresponse() {

			Test.startTest();

			SECAPI_Response_Application response = new SECAPI_Response_Application();

			response.setSuccessMessage('success');
			response.setFailureMessage('failure');
			response.setStatus('ok');

			Test.stopTest();

			System.assertEquals('success', response.SuccessMessage,'expected success back');
			System.assertEquals('failure', response.FailureMessage,'expected success back');
			System.assertEquals('ok',response.Status,'expected OK back');

		}

		@isTest static void test_additionalmessages() {

			Test.startTest();

			SECAPI_Response_Application response = new SECAPI_Response_Application();

			response.setSuccessMessage('first');
			response.setFailureMessage('first');

			response.setSuccessMessage('second');
			response.setFailureMessage('second');			

			Test.stopTest();

			System.assertEquals('first : second', response.SuccessMessage,'expected success back');
			System.assertEquals('first : second', response.FailureMessage,'expected success back');
		}

		private class SECAPI_Response_Application extends SECAPI_Response {

        public String appId;
        public String password;
        public String userprofileid;
        public Boolean usernameemailexists;

        public SECAPI_Response_Application() {

        }

        public SECAPI_Response_Application setAppId(String inappid){
            appId = inappid;
            return this;
        }

        public SECAPI_Response_Application setPassword(String inpassword){
            password = inpassword;
            return this;
        }

        public SECAPI_Response_Application setUserProfileId(String inuserprofileid){
            userprofileid = inuserprofileid;
            return this;
        }

        public SECAPI_Response_Application setUserNameEmailExists(Boolean inexists){
            usernameemailexists = inexists;
            return this;
        }
    }
}