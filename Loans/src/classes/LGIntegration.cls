public class LGIntegration {
    @TestVisible private IHandleHttpRequests http_handler;
    private final Integer HTTP_TIMEOUT = 60000;
    public enum MessageType { INFO, ERROR, WARNING }

    @TestVisible
    private LGIntegration() {
        http_handler = HttpHandler.getHandler();
    }

    public static LenderExchangeResult executeLenderExchange(SecuredLoansIntegrationModels.Application application, String lenderName) {
        return new LGIntegration().executeLender(application, lenderName);
    }

    private LenderExchangeResult executeLender(SecuredLoansIntegrationModels.Application application, String lenderName) {
        LenderExchangeResult result = new LenderExchangeResult();
        HttpRequest http_request = buildHttpRequest(application, lenderName);
        HttpHandler.HttpHandlerResponse handled_response = sendRequest(http_request);
        if(handled_response.isSuccess()){
            if(handled_response.getHttpResponse().getStatusCode() == 200
                || handled_response.getHttpResponse().getStatusCode() == 400){
                result = (LenderExchangeResult)JSON.deserialize(handled_response.getHttpResponse().getBody(), LenderExchangeResult.class);
            } else if (handled_response.getHttpResponse().getStatusCode() == 500) {
                if(handled_response.getHttpResponse().getBody() != null){
                    Map<String, Object> response_body = (Map<String, Object>)JSON.deserializeUntyped(handled_response.getHttpResponse().getBody());
                    result.addErrorMessage('An unhandled exception occurred: Message "' + (String)response_body.get('Message') + '"  Error "' + (String)response_body.get('ExceptionMessage') + '"');
                } else {
                    result.addErrorMessage('An unhandled exception occurred: Status "' + handled_response.getHttpResponse().getStatus() + '"  Code ' + handled_response.getHttpResponse().getStatusCode());
                }
            } else {
                result.addErrorMessage('An unhandled http status was returned: Status "' + handled_response.getHttpResponse().getStatus() + '"  Code ' + handled_response.getHttpResponse().getStatusCode());
            }
        } else {
            if(handled_response.getExceptionMessage() != null){
                result.addErrorMessage(handled_response.getExceptionMessage());
            } else {
                result.addErrorMessage('An unkown eception has occurred');
            }
        }
        return result;
    }

     private HttpRequest buildHttpRequest(SecuredLoansIntegrationModels.Application application, String lenderName){
        HttpRequest http_request = new HttpRequest();
        http_request.setEndpoint(getLGEndpoint() + '?l=' + lenderName);
        http_request.setMethod('POST');
        http_request.setTimeout(HTTP_TIMEOUT);
        http_request.setHeader('Content-Type','application/json');
        http_request.setBody(getJSON(application));
        return http_request;
    }

    private String getLGEndpoint(){
        String url_suffix = '/api/Lender';
        if(Utility.isRunningInSandbox()){
            return 'http://819fcd2949c34220bf5256903f446d47.cloudapp.net/' + url_suffix;
        } else {
            return 'http://lender-gateway.cloudapp.net/' + url_suffix;
        }
    }

    @TestVisible
    private HttpHandler.HttpHandlerResponse sendRequest(HttpRequest request){
        HttpHandler.HttpHandlerResponse response = http_handler.send(request);
        return response;
    }

    private String getJSON(SecuredLoansIntegrationModels.Application application){
        return JSON.serialize(application);
    }

    public class LenderExchangeResult
    {
        public String Id { get; set; }
        public String RawResult { get; set; }
        public String LenderReferenceId { get; set; }
        public String RedirectUrl { get; set; }
        public List<Product> ProductsOffered { get; set; }
        public List<Document> Documents { get; set; }
        public Boolean IsSuccessful {
            get {
                if(IsSuccessful == null) {
                    return false;
                }
                return IsSuccessful;
            }
            set;
        }
        public List<String> Errors {
            get {
                if(Errors == null) {
                    Errors = new List<String>();
                    return Errors;
                }
                return Errors;
            }
            set;
        }
        public List<Message> Messages {
            get {
                if(Messages == null) {
                    Messages = new List<Message>();
                    return Messages;
                }
                return Messages;
            }
            set;
        }

        private void addMessage(MessageType type, String message_text){
            this.Messages.add(new Message(type, message_text));
        }

        public void addErrorMessage(String message_text){
            this.addMessage(MessageType.ERROR, message_text);
        }

        public void addInfoMessage(String message_text){
            this.addMessage(MessageType.INFO, message_text);
        }

        public void addWarningMessage(String message_text){
            this.addMessage(MessageType.WARNING, message_text);
        }

        public List<String> getMessages(MessageType type){
            List<String> messages_of_type = new List<String>();
            for(Message msg:this.Messages){
                if(msg.getType() == type){
                    messages_of_type.add(msg.MessageText);
                }
            }
            return messages_of_type;
        }

        public List<String> getMessages(){
            List<String> messages = new List<String>();
            messages.addAll(getMessages(MessageType.INFO));
            messages.addAll(getMessages(MessageType.ERROR));
            messages.addAll(getMessages(MessageType.WARNING));
            messages.addAll(Errors);
            Set<String> dedupe_messages = new Set<String>();
            for(String message:messages){
                if(!dedupe_messages.contains(message)){
                    dedupe_messages.add(message);
                }
            }
            messages.clear();
            messages.addAll(dedupe_messages);
            return messages;
        }

        public Boolean hasMessages(){
            return !getMessages().isEmpty();
        }
    }

    public class Document
    {
        public String Name { get; set; }
        public Boolean IsRequired { get; set; }
        public String ReferenceCode { get; set; }
    }

    public class Product
    {
        public String Name { get; set; }
        public String Code { get; set; }
        public Double InterestRate { get; set; }
        public Double ReversionRate { get; set; }
        public Double MonthlyRepayment { get; set; }
        public Double APR { get; set; }

        public Double InterestCharges { get; set; }
        public Double SettleAmountPeriod1 { get; set; }
        public Double SettleAmountPeriod2 { get; set; }
        public Double SettleAmountPeriod3 { get; set; }

        public Double LenderFee { get; set; }
        public Double TTFee { get; set; }

        public Double TitleInsurance { get; set; }
        public Double SolicitorsCosts { get; set; }

        public Boolean IsPrimary { get; set; }
    }

    public class Message
    {
        public String Type { private get; set; }
        public String MessageText { get; set; }

        public Message() {}

        public Message(MessageType type, String message_text){
            this.Type = type.name();
            this.MessageText = message_text;
        }

        public MessageType getType(){
            for(MessageType t:MessageType.values()){
                if(t.name() == Type){
                    return t;
                } else {
                    continue;
                }
            }
            throw new EnumDeserializationException('Unable to convert type ' + Type + 'to MessageType enum ');
        }
    }

    public class EnumDeserializationException extends Exception {}
}