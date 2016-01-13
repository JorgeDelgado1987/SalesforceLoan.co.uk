public class HttpMockHandler implements IHandleHttpRequests{

    @TestVisible private static List<HttpHandler.HttpHandlerResponse> mocks;

    public HttpMockHandler() {}

    public HttpHandler.HttpHandlerResponse send(HttpRequest request){
        return HttpMockHandler.mocks.remove(0);
    }

    public static void addMock(HttpHandler.HttpHandlerResponse mock){
        if(mocks == null){
            mocks = new List<HttpHandler.HttpHandlerResponse>();
        }
        mocks.add(mock);
    }

    public static void addSuccessfulMock(String mock_body){
        HttpResponse response = new HttpResponse();
        response.setBody(mock_body);
        response.setStatusCode(200);
        response.setStatus('OK');
        addMock(new HttpHandler.HttpHandlerResponse(response));
    }

}