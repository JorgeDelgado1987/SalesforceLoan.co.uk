@isTest
private class SECAPIuploadApplicationDocument_test {
	
	@isTest static void noparentid() {
		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		String jsonString = '{"records":[{"records":"iVBORw0KGgoAAAANSUhE"}]}';
       
        request.requestBody = Blob.valueOf(jsonString);


        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();

        SECAPIuploadApplicationDocument.DocsResponse myresponse =  SECAPIuploadApplicationDocument.receiveData();

        Test.stopTest();

        System.assertEquals(true, myresponse.errorMessage.contains('Must supply an ApplicationID as the parentId.'));

        
	}

	@isTest static void invalidparentid() {
		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();
		String jsonString = '{"parentId":"aaaaaa"}';
       
        request.requestBody = Blob.valueOf(jsonString);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();

        SECAPIuploadApplicationDocument.DocsResponse myresponse =  SECAPIuploadApplicationDocument.receiveData();

        Test.stopTest();

        System.assertEquals(true, myresponse.errorMessage.contains('No matching Application record'));

        
	}

	@isTest static void nofilename() {
		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();

		 //Create Account
        Account oAccount = new Account();
		oAccount.Name = 'Loans & Mortgages';
		oAccount.Business__c = 'Loan.co.uk';
		oAccount.Affiliate_ID__c = 'SAMLOAN';
		
		insert oAccount;
		
		//Create Application
		Application__c oApplication = new Application__c();
		oApplication.Status__c = 'White';
		oApplication.Sub_Status__c = 'Application';
		oApplication.Loan_Amount__c = 100000.00;
		oApplication.Business__c = 'Loan.co.uk';
		oApplication.Account__c = oAccount.Id;
		oApplication.Application_Type__c = 'Secured Loan';
		oApplication.Loan_Purpose__c = 'Business';
		oApplication.Loan_Term_Months__c = 48.00;
		oApplication.Lead_Applicant_Name__c = 'Joe Bloggs';		
		
		insert oApplication;
		String jsonString = '{"parentId":"'+oApplication.id+'"}';
       
        request.requestBody = Blob.valueOf(jsonString);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();

        SECAPIuploadApplicationDocument.DocsResponse myresponse =  SECAPIuploadApplicationDocument.receiveData();

        Test.stopTest();

        System.assertEquals(true, myresponse.errorMessage.contains('Must supply a filename.'));

	}

@isTest static void goodrequest() {
		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();

		 //Create Account
        Account oAccount = new Account();
		oAccount.Name = 'Loans & Mortgages';
		oAccount.Business__c = 'Loan.co.uk';
		oAccount.Affiliate_ID__c = 'SAMLOAN';
		
		insert oAccount;
		
		//Create Application
		Application__c oApplication = new Application__c();
		oApplication.Status__c = 'White';
		oApplication.Sub_Status__c = 'Application';
		oApplication.Loan_Amount__c = 100000.00;
		oApplication.Business__c = 'Loan.co.uk';
		oApplication.Account__c = oAccount.Id;
		oApplication.Application_Type__c = 'Secured Loan';
		oApplication.Loan_Purpose__c = 'Business';
		oApplication.Loan_Term_Months__c = 48.00;
		oApplication.Lead_Applicant_Name__c = 'Joe Bloggs';		
		
		insert oApplication;
		String jsonString = '{"parentId":"'+oApplication.id+'","filename":"Test.pdf","filebody":"iVBORw0KGgoAAAANSUhEUgAAAAIAAAACAgMAAAAP2OW3AAAADFBMVEWxf2/KgHhvwEfedoetG6yMAAAADElEQVQI12NoYCgAAAH0APFbzVilAAAAAElFTkSuQmCC"}';
       
        request.requestBody = Blob.valueOf(jsonString);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();

        SECAPIuploadApplicationDocument.DocsResponse myresponse =  SECAPIuploadApplicationDocument.receiveData();

        Test.stopTest();

        System.assertEquals('success', myresponse.status);

        Attachment newattachment = [Select id, parentId from Attachment WHERE id=:myresponse.newAttachmentID LIMIT 1];

        System.assertEquals(oApplication.id,newattachment.parentId);
        
	}	
	
}