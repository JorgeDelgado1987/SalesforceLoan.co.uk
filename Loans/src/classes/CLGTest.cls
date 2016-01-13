public class CLGTest {
    public LGIntegration.LenderExchangeResult jsonResponse {get;set;}

    public void doPost() {
        string appId = ApexPages.currentPage().getParameters().get('id');
        string lender = ApexPages.currentPage().getParameters().get('lender');        
        jsonResponse = LGIntegration.executeLenderExchange(SecuredLoansIntegrationModels.getAllApplicationData(appId), lender);
    }
}