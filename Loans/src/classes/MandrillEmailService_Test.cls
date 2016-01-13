@isTest
private class MandrillEmailService_Test {

	static testMethod void sendEmailResultIsSuccess(){
        HttpMockHandler.addMock(getMockResponseSuccess());
        String email = 'eddie@forcesupport.co.uk';
		String name = 'Eddie';
		CommsEmailService.Recipient recipient = new CommsEmailService.Recipient(email).setName(name);
		CommsEmailService.Template template = new CommsEmailService.Template('TestTemplate', true);

        Test.startTest();
           CommsEmailService.SendResult emailSendResult = new MandrillEmailService().sendEmail(recipient, template);
        Test.stopTest();
        System.assertEquals(true, emailSendResult.IsSuccess());
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
}