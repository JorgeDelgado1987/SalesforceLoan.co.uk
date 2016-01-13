public class MandrillIntegration{

    private final String KEY = '6h9Mha1xpEc7K1IbQ1QIzA';
    private final String ENDPOINT = 'https://mandrillapp.com/api/1.0/messages/send-template.json';
    private final Integer TIMEOUT = 20000;
    private final String FROM_EMAIL = 'hello@loan.co.uk';
    private final String FROM_NAME = 'hello@loan.co.uk';

	public enum Status{SUCCESS, CALLOUT_EXCEPTION, MANDRILL_EXCEPTION}

    @TestVisible private IHandleHttpRequests http_handler;
	@Testvisible private String subject;
    @Testvisible private String body;
	@Testvisible private String template_name;

	public MandrillIntegration() {
        http_handler = HttpHandler.getHandler();
    }

	public MandrillIntegration setSubject(String subject){
		this.subject = subject;
		return this;
	}

	public MandrillIntegration setBody(String body){
		this.body = body;
		return this;
	}

	public MandrillIntegration setTemplateName(String template_name){
		this.template_name = template_name;
		return this;
	}

	public String getSubject(){
        return this.subject;
    }

    public String getBody(){
        return this.body;
    }

	public String getTemplateName(){
        return this.template_name;
    }

    public Response sendEmail(EmailRecipient emailRecipient){

        String jsonBody = buildJSONSendTemplate(emailRecipient);
		System.debug(jsonBody);
        HttpRequest httpBody = new HttpRequest();
        httpBody = buildHTTPBody(jsonBody);

        HttpHandler.HttpHandlerResponse requestResponse = sendHTTPRequest(httpBody);

		Response result;
		result = new Response(requestResponse);

        return result;
    }

	public String buildJSONSendTemplate(EmailRecipient emailRecipient){

        // Pass true to the constructor for pretty print formatting.
        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();

            gen.writeStringField('key', KEY);
			gen.writeStringField('template_name', template_name);
			gen.writeFieldName('template_content');
                gen.writeStartArray();
                    gen.writeStartObject();

                        gen.writeStringField('name', '');
                        gen.writeStringField('content', '');

                    gen.writeEndObject();
                gen.writeEndArray();
            gen.writeFieldName('message');

                gen.writeStartObject();

                    gen.writeFieldName('to');
                        gen.writeStartArray();
                            gen.writeStartObject();

                                gen.writeStringField('email', emailRecipient.getEmail());
                                gen.writeStringField('name', emailRecipient.getName());
                                gen.writeStringField('type', 'to');

                            gen.writeEndObject();
                        gen.writeEndArray();

                    gen.writeFieldName('merge_vars');
                        gen.writeStartArray();
                            gen.writeStartObject();

                                gen.writeStringField('rcpt', emailRecipient.getEmail());

								if(emailRecipient.getMergeData() != null){
									gen.writeFieldName('vars');
				                        gen.writeStartArray();
											for (String var_name : emailRecipient.getMergeData().keySet())
											{
												gen.writeStartObject();
					                                gen.writeStringField('name', var_name);
													gen.writeStringField('content', String.valueOf(emailRecipient.getMergeData().get(var_name)));
					                            gen.writeEndObject();
											}


				                        gen.writeEndArray();
    							}
                            gen.writeEndObject();
                        gen.writeEndArray();

                gen.writeEndObject();
        gen.writeEndObject();

        String generatedJSONString = gen.getAsString();
        return generatedJSONString;
    }

/*    public String buildJSONBody(EmailRecipient emailRecipient){

        // Pass true to the constructor for pretty print formatting.
        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();

            gen.writeStringField('key', KEY);
            gen.writeFieldName('message');

                gen.writeStartObject();

                    gen.writeStringField('html', body);
                    gen.writeStringField('text', body);
                    gen.writeStringField('subject', subject);
                    gen.writeStringField('from_email', FROM_EMAIL);
                    gen.writeStringField('from_name', FROM_NAME);

                    gen.writeFieldName('to');
                        gen.writeStartArray();
                            gen.writeStartObject();

                                gen.writeStringField('email', emailRecipient.getEmail());
                                gen.writeStringField('name', emailRecipient.getName());
                                gen.writeStringField('type', 'to');

                            gen.writeEndObject();
                        gen.writeEndArray();

                    gen.writeFieldName('headers');
                        gen.writeStartObject();
                            gen.writeStringField('Reply-To', 'message.reply@example.com');
                        gen.writeEndObject();

                gen.writeEndObject();
        gen.writeEndObject();

        String generatedJSONString = gen.getAsString();
        return generatedJSONString;
    }
*/
    public HttpRequest buildHTTPBody(String generatedJSONString){

        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT);
        request.setMethod('POST');
        request.setBody(generatedJSONString);
        request.setTimeout(TIMEOUT);

        return request;
    }

    public HttpHandler.HttpHandlerResponse sendHTTPRequest(HttpRequest request){

        HttpHandler.HttpHandlerResponse response = http_handler.send(request);
		return response;
    }

	public class Response{
		private HttpHandler.HttpHandlerResponse handler_response;

        public Response(HttpHandler.HttpHandlerResponse response){
			handler_response = response;
        }

		public String getExceptionMessage(){
            if(handler_response.IsSuccess()){
                return '';
            } else {
                return handler_response.getExceptionMessage();
            }
        }

		public MandrillIntegration.Status getStatus(){

            if(handler_response.IsSuccess()){
                if(handler_response.getHttpResponse().getStatusCode() == 200){
				    return Status.SUCCESS;
                } else {
				    return Status.MANDRILL_EXCEPTION;
                }
            } else {
                return Status.CALLOUT_EXCEPTION;
            }
        }
    }

	public class EmailRecipient{
		//This needs to have a Map instantiated and iterate through the Merge Data
		@Testvisible private String name;
        @Testvisible private String email;
		@Testvisible Map<String,Object> merge_data = new Map<String,Object>();

		public EmailRecipient(String name,String email){

			this.name = name;
			this.email = email;
        }

		public EmailRecipient setMergeData(Map<String,Object> merge_data){
            this.merge_data = merge_data;
			return this;
        }

		public Map<String,Object> getMergeData(){
            return this.merge_data;
        }

		public String getName(){
            return this.name;
        }

        public String getEmail(){
            return this.email;
        }
	}
}