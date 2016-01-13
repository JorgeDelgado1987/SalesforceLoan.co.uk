public class GoogleAuthorizedController {

    public PageReference retrieveCodeAndRedirect(){
        PageReference return_ref;
        String code = ApexPages.CurrentPage().getParameters().get('code');
        String refresh = ApexPages.CurrentPage().getParameters().get('refresh');
        if(refresh == 'true'){
            GoogleOAuth.getInstance().refreshAccessToken();
            return_ref = new PageReference(EncodingUtil.urlDecode(ApexPages.CurrentPage().getParameters().get('state'), 'utf-8'));
        } else if(code == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Something went wrong authorizing with google ' + ApexPages.CurrentPage().getParameters().get('error')));
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Code Retrieved ' + code));
            GoogleOAuth.getInstance().retrieveAccessAndRefreshTokensUsingCode(code);
            return_ref = new PageReference(EncodingUtil.urlDecode(ApexPages.CurrentPage().getParameters().get('state'), 'utf-8'));
        }
        return return_ref;
    }

}