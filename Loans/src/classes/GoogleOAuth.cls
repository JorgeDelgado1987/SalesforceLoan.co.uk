public class GoogleOAuth {
    private final String CLIENT_ID = '10844507633-pjpltt8ajc48ka8u2ui0sa74rn5o7ei2.apps.googleusercontent.com';
    private final String CLIENT_SECRET = 'locKxL6wHqcggOe8IX9i-faw';
    private final String AUTH_URL = 'https://accounts.google.com/o/oauth2/auth';
    private final String TOKEN_URL = 'https://www.googleapis.com/oauth2/v3/token';
    private final String TOKEN_NAME = 'GoogleOAuthTokens';
    private final String REDIRECT_URL;
    private static GoogleOAuth instance;

    public static GoogleOAuth getInstance(){
        if(instance == null){
            instance = new GoogleOAuth();
        }
        return instance;
    }

    private GoogleOAuth(){
        REDIRECT_URL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/GoogleAuthorized';
    }

    public Boolean isAuthenticated(){
        if(hasTokens() && OAuthTokens__c.getInstance(TOKEN_NAME).Expiration_Date_Time__c > DateTime.now()){
            return true;
        }
        return false;
    }

    public Boolean hasTokens(){
        return (OAuthTokens__c.getInstance(TOKEN_NAME) != null
            && OAuthTokens__c.getInstance(TOKEN_NAME).Access_Token__c != null);
    }

    public String getAccessToken(){
        return OAuthTokens__c.getInstance(TOKEN_NAME).Access_Token__c;
    }

    public String getRefreshToken(){
        return OAuthTokens__c.getInstance(TOKEN_NAME).Refresh_Token__c;
    }

    public PageReference getAuthURL(String state){
        PageReference auth_redirect;
        if(hasTokens()){
            auth_redirect = new PageReference(REDIRECT_URL);
            auth_redirect.getParameters().put('refresh','true');
        } else {
            auth_redirect = new PageReference(AUTH_URL);
            auth_redirect.getParameters().put('response_type', 'code');
            auth_redirect.getParameters().put('client_id', CLIENT_ID);
            auth_redirect.getParameters().put('redirect_uri', REDIRECT_URL);
            auth_redirect.getParameters().put('scope', 'https://www.googleapis.com/auth/adwords');
            auth_redirect.getParameters().put('access_type','offline');
        }
        auth_redirect.getParameters().put('state', encodeString(state));
        return auth_redirect;
    }

    public String retrieveAccessAndRefreshTokensUsingCode(String code){
        HttpRequest token_request = getTokenRequest(code);
        IHandleHttpRequests handler = HttpHandler.getHandler();
        HttpHandler.HttpHandlerResponse response = handler.send(token_request);
        if(response.IsSuccess()){
            TokenResponse tr = (TokenResponse)JSON.deserialize(response.getHttpResponse().getBody(), TokenResponse.class);
            setTokens(tr);
        } else {
            throw new AuthException('Exception calling out to retrieve tokens ' + response.getExceptionMessage());
        }
        return getAccessToken();
    }

    public String refreshAccessToken(){
        HttpRequest token_request = getRefreshRequest();
        IHandleHttpRequests handler = HttpHandler.getHandler();
        HttpHandler.HttpHandlerResponse response = handler.send(token_request);
        if(response.IsSuccess()){
            TokenResponse tr = (TokenResponse)JSON.deserialize(response.getHttpResponse().getBody(), TokenResponse.class);
            setTokens(tr);
        } else {
            throw new AuthException('Exception calling out to refresh tokens ' + response.getExceptionMessage());
        }
        return getAccessToken();
    }

    private HTTPRequest getTokenRequest(String code){
        HttpRequest token_request = getTokenRequestBase();
        token_request.setBody(getcodeBody(code));
        return token_request;
    }

    private HTTPRequest getRefreshRequest(){
        HttpRequest token_request = getTokenRequestBase();
        token_request.setBody(getRefreshBody());
        return token_request;
    }

    private HTTPRequest getTokenRequestBase(){
        HttpRequest token_request = new HttpRequest();
        token_request.setMethod('POST');
        token_request.setEndpoint(TOKEN_URL);
        token_request.setHeader('content-type', 'application/x-www-form-urlencoded');
        return token_request;
    }

    private String getCodeBody(String code){
        String body_string = 'client_id=' + encodeString(CLIENT_ID);
        body_string += '&client_secret=' + encodeString(CLIENT_SECRET);
        body_string += '&redirect_uri=' + encodeString(REDIRECT_URL);
        body_string += '&grant_type=' + encodeString('authorization_code');
        body_string += '&code=' + encodeString(code);
        return body_string;
    }

    private String getRefreshBody(){
        String body_string = 'client_id=' + encodeString(CLIENT_ID);
        body_string += '&client_secret=' + encodeString(CLIENT_SECRET);
        body_string += '&grant_type=' + encodeString('refresh_token');
        body_string += '&refresh_token=' + encodeString(getRefreshToken());
        return body_string;
    }

    private String encodeString(String s){
        return EncodingUtil.urlEncode(s, 'utf-8');
    }

    public void setTokens(TokenResponse tr){
        OAuthTokens__c gtokens = OAuthTokens__c.getInstance(TOKEN_NAME);
        if(gtokens == null){
            gtokens = new OAuthTokens__c();
            gtokens.Name = TOKEN_NAME;
        }
        gtokens.Access_Token__c = tr.access_token;
        if(tr.refresh_token != null){
            gtokens.Refresh_Token__c = tr.refresh_token;
        }
        gtokens.Expiration_Date_Time__c = DateTime.now().addSeconds(tr.expires_in);
        upsert gtokens;
    }

    public class AuthException extends Exception{}

    private class TokenResponse{
        protected String access_token;
        protected Integer expires_in;
        protected String token_type;
        protected String refresh_token;
    }

}