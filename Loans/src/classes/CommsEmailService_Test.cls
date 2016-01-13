@IsTest
public class CommsEmailService_Test {

    static testMethod void receipientConstructionSetsEmail(){
        String email = 'tom@slayer.net';
        Test.startTest();
            CommsEmailService.Recipient recipient = new CommsEmailService.Recipient(email);
        Test.stopTest();
        System.assertEquals(email, recipient.getEmail());
        System.assertEquals(null, recipient.getName());
        System.assertEquals(new Map<String,String>(), recipient.getMergeData());
    }

    static testMethod void recipientSetNameSetsNameVariable(){
        String email = 'tom@slayer.net';
        String name = 'Tom Araya';
        Test.startTest();
            CommsEmailService.Recipient recipient = new CommsEmailService.Recipient(email).setName(name);
        Test.stopTest();
        System.assertEquals(email, recipient.getEmail());
        System.assertEquals(name, recipient.getName());
        System.assertEquals(new Map<String,String>(), recipient.getMergeData());
    }

    static testMethod void recipientSetMergeDataSetsMergeData(){
        String email = 'tom@slayer.net';
        String merge_key = 'best_album';
        String merge_value = 'South of Heaven';
        Test.startTest();
            CommsEmailService.Recipient recipient = new CommsEmailService.Recipient(email).setMergeData(merge_key, merge_value);
        Test.stopTest();
        System.assertEquals(email, recipient.getEmail());
        System.assertEquals(null, recipient.getName());
        System.assertEquals(1, recipient.getMergeData().size());
        System.assertEquals(merge_value, recipient.getMergeData().get(merge_key));
    }

    static testMethod void templateConstructorSetsVariablesCorrectly(){
        String template_name = 'Album Cover';
        Boolean isLocal = false;
        Test.startTest();
            CommsEmailService.Template template = new CommsEmailService.Template(template_name, isLocal);
        Test.stopTest();
        System.assertEquals(template_name, template.getName());
        System.assertEquals(isLocal, template.isLocal());
    }

    static testMethod void templateSetSubjectAndBodyVariables(){
        String template_name = 'Album Cover';
        Boolean isLocal = false;
        String subject  = 'Hi Mr Smith';
        String body     = 'This is your welcome email';
        Test.startTest();
            CommsEmailService.Template template = new CommsEmailService.Template(template_name, isLocal);
			template.setSubject(subject);
			template.setBody(body);
        Test.stopTest();
		System.assertEquals(template_name, template.getName());
        System.assertEquals(subject, template.getSubject());
        System.assertEquals(body, template.getBody());
        System.assertEquals(isLocal, template.isLocal());
    }

    static testMethod void testSendResultIsTrueByDefault(){
        Test.startTest();
            CommsEmailService.SendResult sr = new CommsemailService.SendResult();
        Test.stopTest();
        System.assertEquals(true, sr.IsSuccess());
        System.assertEquals(new List<String>(), sr.getErrors());
    }

    static testMethod void testSendResultAddErrorChangesSuccessFlagAndAddsError(){
        String error_string = 'Something went wrong';
        CommsEmailService.SendResult sr = new CommsemailService.SendResult();
        Test.startTest();
            sr.addError(error_string);
        Test.stopTest();
        System.assertEquals(false, sr.IsSuccess());
        System.assertEquals(1, sr.getErrors().size());
        System.assertEquals(error_string, sr.getErrors().get(0));
    }

    static testMethod void testScheduleDateTimeGetsSetCorrectly(){
        DateTime future_date = DateTime.now().addDays(10);
        Test.startTest();
            CommsEmailService.Schedule sch = new CommsEmailService.Schedule(future_date);
        Test.stopTest();
        System.assertEquals(future_date, sch.getDateTime());
    }

    static testMethod void testInstantiationOfRecipientWithApplicantWorksAsExpected(){
        Applicant__c applicant = getTestApplicant();
        Test.startTest();
            CommsEmailService.Recipient recipient = new CommsemailService.Recipient(applicant);
        Test.stopTest();
        System.assertEquals(applicant, recipient.getApplicant());
        System.assertEquals('Joe Bloggs', recipient.getName());
        System.assertEquals('test@app.com', recipient.getEmail());
    }

    static testMethod void testStaticFactoryMethodReturnsInstanceOfCorrectServiceService(){
        HttpMockHandler.addMock(getMockResponseSuccess());
        CommsEmailService.Recipient recipient = new CommsEmailService.Recipient(getTestApplicant());
        CommsEmailService.Template template = new CommsEmailService.Template('Bob', false);
        Test.startTest();
            CommsEmailService.SendResult sr = CommsEmailservice.sendEmailNow(recipient, template);
        Test.stopTest();
        System.assertNotEquals(null, sr);
    }

    private static HttpHandler.HttpHandlerResponse getMockResponseSuccess(){
        HttpResponse response = new HttpResponse();
        response.setBody(getMockBodySuccess());
        response.setStatusCode(200);
        return new HttpHandler.HttpHandlerResponse(response);
    }

    private static String getMockBodySuccess(){
        return '[{"email": "eddie@forcesupport.co.uk","status": "sent","_id": "c44926b6fc7e4a8c896093ed88a4b30a","reject_reason": null}]';
    }

    static Applicant__c getTestApplicant(){
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
        return app;
    }


}