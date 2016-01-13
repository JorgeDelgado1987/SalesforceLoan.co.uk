@isTest
private class MandrillIntegration_Test {

    static testMethod void sendEmailMethodWithSuccess(){

        String email = 'MSmith@forcesupport.co.uk';
        String name = 'Mark Smith';

        CommsEmailService.Recipient recipient = new CommsEmailService.Recipient(email).setName(name);

        MandrillIntegration.EmailRecipient emailRecipient = new MandrillIntegration.EmailRecipient(recipient.getName(), recipient.getEmail());

		HttpMockHandler.addMock(getMockResponseSuccess());
        MandrillIntegration mandrill = new MandrillIntegration().setTemplateName('test_template');

        Test.startTest();
            MandrillIntegration.Response email_response = mandrill.sendEmail(emailRecipient);
        Test.stopTest();

        System.assertEquals(MandrillIntegration.Status.SUCCESS, email_response.getStatus(), 'should get SUCCESS from email response');
        System.assertEquals('', email_response.getExceptionMessage(), 'message should be an empty string if no exception thrown');
        System.assertEquals('test_template', mandrill.getTemplateName(), 'should get the name of the Template');
    }

	static testMethod void sendEmailMethodWithMandrillError(){

        String email = 'MSmith@forcesupport.co.uk';
        String name = 'Mark Smith';
        CommsEmailService.Recipient recipient = new CommsEmailService.Recipient(email).setName(name);

        MandrillIntegration.EmailRecipient emailRecipient = new MandrillIntegration.EmailRecipient(recipient.getName(), recipient.getEmail());

		HttpMockHandler.addMock(getMockResponseMandrillError());
        MandrillIntegration mandrill = new MandrillIntegration().setTemplateName('test_template');

        Test.startTest();
            MandrillIntegration.Response email_response = mandrill.sendEmail(emailRecipient);
        Test.stopTest();

        System.assertEquals(MandrillIntegration.Status.MANDRILL_EXCEPTION, email_response.getStatus(), 'should get MANDRILL_EXCEPTION from email response');
    }

	static testMethod void sendEmailMethodWithCalloutError(){

        String email = 'MSmith@forcesupport.co.uk';
        String name = 'Mark Smith';
        CommsEmailService.Recipient recipient = new CommsEmailService.Recipient(email).setName(name);

        MandrillIntegration.EmailRecipient emailRecipient = new MandrillIntegration.EmailRecipient(recipient.getName(), recipient.getEmail());

		HttpHandler.HttpHandlerResponse testException = new HttpHandler.HttpHandlerResponse(new TestException());
        HttpMockHandler.addMock(testException);
		MandrillIntegration mandrill = new MandrillIntegration().setTemplateName('test_template');

        Test.startTest();
            MandrillIntegration.Response email_response = mandrill.sendEmail(emailRecipient);
        Test.stopTest();

        System.assertNotEquals(null, email_response.getExceptionMessage(), 'should get an Exception message, so should not be null');
        System.assertEquals(MandrillIntegration.Status.CALLOUT_EXCEPTION, email_response.getStatus(), 'should get CALLOUT_EXCEPTION from email response');
    }

    static testMethod void sendEmailMethodTemplateWithSuccess(){

        String email = 'ekbates@gmail.com';
        String name = 'Eddie Test';
        Account acc = new Account();
        acc.Name = 'Acme Mortgages Ltd';
        insert acc;

        Application__c appl = new Application__c();
        appl.Account__c = acc.id;
        appl.Loan_Amount__c = 25000;
        appl.Loan_Term_Months__c = 36;
        insert appl;

        Applicant__c app = new Applicant__c();
        app.Last_Name__c = 'Bloggs';
        app.First_Name__c = 'Joe';
        app.Email_Address__c = 'test@app.com';
        app.Date_of_Birth__c = date.today().addYears(-25);
        app.Home_Phone__c = '0123456789';
        app.Mobile_Phone__c = '077733377';
        app.Postcode__c = 'AB123CD';
        app.Application__c = appl.id;
        insert app;

        Application__c applInserted = [Select Name from Application__c where Id =: appl.id];

        CommsEmailService.Recipient recipient = new CommsEmailService.Recipient(email).setName(name);
        System.debug('theApplicant.First_Name__c: ' + app.First_Name__c);
        System.debug('theApplicant.Application__r.Name: ' + applInserted.Name);
        System.debug('theApplicant.Application__r.Loan_Amount__c: ' + appl.Loan_Amount__c);
        System.debug('theApplicant.Application__r.Loan_Term_Months__c: ' + appl.Loan_Term_Months__c);

        recipient.setMergeData('FirstName',app.First_Name__c);
        recipient.setMergeData('ApplicationName',applInserted.Name);
        recipient.setMergeData('ApplicationLoanAmount',appl.Loan_Amount__c);
        recipient.setMergeData('ApplicationLoanTermMonths',appl.Loan_Term_Months__c);

        CommsEmailService.Template template = new CommsEmailService.Template('loan-co-uk-welcome-email', true);


        //MandrillIntegration.EmailRecipient emailRecipient = new MandrillIntegration.EmailRecipient(recipient.getName(), recipient.getEmail());

		HttpMockHandler.addMock(getMockResponseSuccess());
        MandrillIntegration mandrill = new MandrillIntegration().setTemplateName('loan-co-uk-welcome-email');

        Test.startTest();
            //MandrillIntegration.Response email_response = mandrill.sendEmail(emailRecipient);
            CommsEmailService.SendResult emailSendResult = new MandrillEmailService().sendEmail(recipient, template);
        Test.stopTest();

        System.assertEquals(true, emailSendResult.IsSuccess(), 'should be true if no errors thrown');
        System.assertEquals('loan-co-uk-welcome-email', mandrill.getTemplateName(), 'should get the name of the Template');
    }

	static testMethod void createEmailRecipient(){

        String email 	= 'MSmith@forcesupport.co.uk';
        String name 	= 'Mark Smith';
		CommsEmailService.Recipient recipient = new CommsEmailService.Recipient(email).setName(name);

        Test.startTest();
            MandrillIntegration.EmailRecipient emailRecipient = new MandrillIntegration.EmailRecipient(recipient.getName(), recipient.getEmail());
        Test.stopTest();

        System.assertEquals('Mark Smith', emailRecipient.getName());
		System.assertEquals('MSmith@forcesupport.co.uk', emailRecipient.getEmail());
    }

	static testMethod void createMandrillSubjectAndBody(){

		String subject 	= 'Hi Mr Smith';
		String body 	= 'This is your welcome email';

        Test.startTest();
            MandrillIntegration mandrill = new MandrillIntegration();
			mandrill.setSubject(subject);
			mandrill.setBody(body);
        Test.stopTest();

		System.assertEquals('Hi Mr Smith', mandrill.getSubject(), 'Should return a String for Subject');
		System.assertEquals('This is your welcome email', mandrill.getBody(), 'Should return a String for Body');
    }

	public class TestException extends Exception {}

	private static HttpHandler.HttpHandlerResponse getMockResponseSuccess(){
        HttpResponse response = new HttpResponse();
        response.setBody(getMockBodySuccess());
        response.setStatusCode(200);
        return new HttpHandler.HttpHandlerResponse(response);
    }


	private static String getMockBodySuccess(){
        return '[{"email": "eddie@forcesupport.co.uk","status": "sent","_id": "c44926b6fc7e4a8c896093ed88a4b30a","reject_reason": null}]';
	}

	private static HttpHandler.HttpHandlerResponse getMockResponseMandrillError(){
        HttpResponse response = new HttpResponse();
        response.setBody(getMockBodyMandrillError());
        response.setStatusCode(500);
        return new HttpHandler.HttpHandlerResponse(response);
    }

	private static String getMockBodyMandrillError(){
        return '{"status": "error","code": -2,"name": "ValidationError","message": "Validation error: {\"message\":{\"from_email\":\"An email address must contain a single @\"}}"}';
	}


}