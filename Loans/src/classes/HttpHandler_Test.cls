@isTest
public class HttpHandler_Test {
	static testMethod void testHttpHandlerResponseInstantiationWithHttpResponse(){
        HttpResponse http_response = new HttpResponse();
        Test.startTest();
            HttpHandler.HttpHandlerResponse r = new HttpHandler.HttpHandlerResponse(http_response);
        Test.stopTest();
        System.assertEquals(true, r.IsSuccess());
        System.assertEquals(http_response, r.getHttpResponse());
        System.assertEquals(null, r.getExceptionMessage());
    }

    static testMethod void testHttpHandlerResponseInstantiationWithException(){
        TestException e = new TestException();
        Test.startTest();
            HttpHandler.HttpHandlerResponse r = new HttpHandler.HttpHandlerResponse(e);
        Test.stopTest();
        System.assertEquals(false, r.IsSuccess(), 'isSuccess should be false when class instantiated with exception');
        System.assertEquals(null, r.getHttpResponse(), 'http response should be null when instatiated with exception');
        System.assertEquals('Exception Type: HttpHandler_Test.TestException.\n Exception Message: Script-thrown exception', r.getExceptionMessage(), 'message should be not be null');
    }

    static testMethod void testHttpHandlerInstantiation(){
        Test.startTest();
            HttpHandler handler = new HttpHandler();
        Test.stopTest();
        System.assertNotEquals(null, handler);
    }

    static testMethod void testHttpHandlerSendMethodWithHttpRequest(){
        HttpRequest request = new HttpRequest();
        Test.startTest();
            HttpHandler.HttpHandlerResponse handler_response = new HttpHandler().send(request);
        Test.stopTest();
        System.assertNotEquals(null, handler_response);
    }

    public class TestException extends Exception{}
}