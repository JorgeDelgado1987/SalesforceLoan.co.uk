@isTest
public class GoogleOAuth_Test {

    @isTest static void testIsAuthenticatedreturnsFalseIfNoTokensArePresent() {
        Test.startTest();
          Boolean result = GoogleOAuth.getInstance().isAuthenticated();
        Test.stopTest();
        System.assertEquals(false, result, 'Result should be False as no tokens inserted');
    }

    @isTest static void testIsAuthenticatedreturnsFalseIfTokenIsPresentButExpiryDateIsInThePast() {
        OAuthTokens__c tokens = getTokens(-10);
        Test.startTest();
          Boolean result = GoogleOAuth.getInstance().isAuthenticated();
        Test.stopTest();
        System.assertEquals(false, result, 'Result should be False as Token Expiry Date is in the past');
    }

    @isTest static void testIsAuthenticatedreturnsTrueIfTokenIsPresentAndExpiryIsInTheFuture() {
        OAuthTokens__c tokens = getTokens(10);
        Test.startTest();
          Boolean result = GoogleOAuth.getInstance().isAuthenticated();
        Test.stopTest();
        System.assertEquals(true, result, 'Result should be True as Token Expiry Date is in the future and tokens exist');
    }

    @isTest static void testGetRefresTokenReturnsCorrectToken() {
        OAuthTokens__c tokens = getTokens(10);
        Test.startTest();
          String result = GoogleOAuth.getInstance().getRefreshToken();
        Test.stopTest();
        System.assertEquals(tokens.Refresh_Token__c, result, 'Refresh Token should be token set');
    }

    @isTest static void testGetAccessTokenReturnsCorrectToken() {
        OAuthTokens__c tokens = getTokens(10);
        Test.startTest();
          String result = GoogleOAuth.getInstance().getAccessToken();
        Test.stopTest();
        System.assertEquals(tokens.Access_Token__c, result, 'Access Token should be token set');
    }

    @isTest static void testGetAuthURLReturnsCorrectPageReferenceByDefault() {
        String state = '/mypage';
        Test.startTest();
          PageReference result = GoogleOAuth.getInstance().getAuthURL(state);
        Test.stopTest();
        System.assertEquals('https://accounts.google.com/o/oauth2/auth',result.getUrl().substringBefore('?'), 'URL should be Google Auth url');
        System.assertEquals(state, EncodingUtil.urldecode(result.getParameters().get('state'), 'utf-8'),'State should be ' + state);
    }

    @isTest static void testGetAuthURLReturnsAuthorizedRedirectWithRefreshParamSet() {
        String state = '/mypage';
        OAuthTokens__c tokens = getTokens(10);
        Test.startTest();
          PageReference result = GoogleOAuth.getInstance().getAuthURL(state);
        Test.stopTest();
        System.assertEquals(System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/GoogleAuthorized',result.getUrl().substringBefore('?'), 'URL should be Salesforce Authorized URL');
        System.assertEquals(state, EncodingUtil.urldecode(result.getParameters().get('state'), 'utf-8'),'State should be ' + state);
        System.assertEquals('true', result.getParameters().get('refresh'), 'refresh paramter should be set and should be true');
    }

    @isTest static void testGetAccessTokenFromCodeWorks() {
        HttpMockHandler.addMock(getGoogleOAuthMockSuccess());
        String code = 'someauthcode';
        Test.startTest();
          String result = GoogleOAuth.getInstance().retrieveAccessAndRefreshTokensUsingCode(code);
        Test.stopTest();
        System.assertEquals('1/fFAGRNJru1FTz70BzhT3Zg', result, 'Access token should be returnedx');
    }

    @isTest static void testGetAccessTokenFromRefresh() {
        HttpMockHandler.addMock(getGoogleOAuthMockSuccess());
        OAuthTokens__c tokens = getTokens(10);
        Test.startTest();
          String result = GoogleOAuth.getInstance().refreshAccessToken();
        Test.stopTest();
        System.assertEquals('1/fFAGRNJru1FTz70BzhT3Zg', result, 'Access token should be returnedx');
    }

    @isTest static HttpHandler.HttpHandlerResponse getGoogleOAuthMockSuccess(){
        HttpResponse response = new HttpResponse();
        response.setBody('{\n  \"access_token\":\"1/fFAGRNJru1FTz70BzhT3Zg\",\n  \"expires_in\":3920,\n  \"token_type\":\"Bearer\",\n  \"refresh_token\":\"1/xEoDL4iW3cxlI7yDbSRFYNG01kVKM2C-259HOF2aQbI\"\n}');
        response.setStatusCode(200);
        response.setStatus('OK');
        HttpHandler.HttpHandlerResponse handler_response = new HttpHandler.HttpHandlerResponse(response);
        return handler_response;
    }

    public static OAuthTokens__c getTokens(Integer expiration_offset){
        OAuthTokens__c tokens = new OAuthTokens__c();
        tokens.Name = 'GoogleOAuthTokens';
        tokens.Access_Token__c = 'dasdfsdfasdfasdasdasdfasdfasdasdffdsaasd';
        tokens.Refresh_Token__c = 'asdfsadfasfasfsadfasdfsadfdsdfsdsfaadfssdfa';
        tokens.Expiration_Date_Time__c = Datetime.now().addMinutes(expiration_offset);
        insert tokens;
        return tokens;
    }

}