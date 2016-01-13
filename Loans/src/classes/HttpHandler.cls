public class HttpHandler implements IHandleHttpRequests{

    public static IHandleHttpRequests getHandler(){
        if(Test.isRunningTest()){
            return new HttpMockHandler();
        } else {
            return new HttpHandler();
        }
    }

    public HttpHandler() {}

    public HttpHandlerResponse send(HttpRequest request){
        Http h = new Http();
        System.debug('HTTP Request: ' + request);
        if(request.getBody() != null){
            System.debug('HTTP Request Body: ' + request.getBody());
        }
        HttpHandlerResponse response;
        try{
            HttpResponse r = h.send(request);
            response = new HttpHandlerResponse(r);
        }
        catch (System.CalloutException ce){
            response = new HttpHandlerResponse(ce);
        }
        catch (Exception e){
            response = new HttpHandlerResponse(e);
        }
        return response;
    }

    public class HttpHandlerResponse{

        private Boolean is_success;
        private HttpResponse response;
        private String exception_message;

        public HttpHandlerResponse(Exception e) {
            System.debug(e);
            is_success = false;
            exception_message = 'Exception Type: '
                    + e.getTypeName() + '.\n Exception Message: '
                    + e.getMessage();
        }

        public HttpHandlerResponse(HttpResponse r){
            System.debug('HTTP Response: ' + r);
            System.debug('HTTP Response Body: ' + r.getBody());
            is_success = true;
            response = r;
        }

        public Boolean IsSuccess(){
            return is_success;
        }

        public String getExceptionMessage(){
            return exception_message;
        }

        public HttpResponse getHttpResponse(){
            return response;
        }

    }
}