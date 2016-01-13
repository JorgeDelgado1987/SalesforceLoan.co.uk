@isTest
public class HttpMockHandler_Test {

    static testMethod void testInstnatiationCreatesListOfMocks(){
        Test.startTest();
            HttpMockHandler mh = new HttpMockHandler();
        Test.stopTest();
        System.assertEquals(null, HttpMockHandler.mocks, 'Mocks list should be null');
    }

    static testMethod void testAddMockAddsMockToMocksList(){
        HttpHandler.HttpHandlerResponse response = new HttpHandler.HttpHandlerResponse(new HttpResponse());
        Test.startTest();
            HttpMockHandler.addMock(response);
        Test.stopTest();
        System.assertEquals(1, HttpMockHandler.mocks.size(), 'Mocks size should be 1 when mock added');
    }

    static testMethod void testCallingSendReturnsMockAndRemovesFromList(){
        HttpMockHandler mh = new HttpMockHandler();
        HttpRequest request = new HttpRequest();
        HttpHandler.HttpHandlerResponse mock_response = new HttpHandler.HttpHandlerResponse(new HttpResponse());
        HttpMockHandler.addMock(mock_response);
        Test.startTest();
            HttpHandler.HttpHandlerResponse response = mh.send(request);
        Test.stopTest();
        System.assert(HttpMockHandler.mocks.isEmpty(), 'mocks should be an empty list as mock should be removed');
        System.assertEquals(mock_response, response, 'mock response should be returned');
    }


    static testMethod void testCallingSendReturnsMocksInOrder(){
        HttpMockHandler mh = new HttpMockHandler();
        HttpRequest request = new HttpRequest();
        HttpHandler.HttpHandlerResponse first_mock = new HttpHandler.HttpHandlerResponse(new HttpResponse());
        HttpHandler.HttpHandlerResponse second_mock = new HttpHandler.HttpHandlerResponse(new HttpResponse());
        Test.startTest();
            HttpMockHandler.addMock(first_mock);
            HttpMockHandler.addMock(second_mock);
            HttpHandler.HttpHandlerResponse first_response = mh.send(request);
            HttpHandler.HttpHandlerResponse second_response = mh.send(request);
        Test.stopTest();
        System.assertEquals(first_mock, first_response, 'first response should equal first mock');
        System.assertEquals(second_mock, second_response, 'second response should equal second mock ordering NOT maintained');
    }

}