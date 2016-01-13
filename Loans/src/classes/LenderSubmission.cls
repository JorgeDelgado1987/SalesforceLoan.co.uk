public with sharing class LenderSubmission {

    private final Application__c APPLICATION;
    public String LenderIntegrationName { get; private set; }

    public List<Quote__c> ActiveQuotes { get; set; }
    public List<LGIntegration.Document> Documents { get; set; }
    public List<LenderProductRow> ProductRows { get; set; }
    public Boolean CanSubmitToLender { get; private set; }
    public Boolean ProductSelected { get; set; }
    public String LenderReference { get; private set; }
    public LGIntegration.LenderExchangeResult LatestLenderExchangeResult { get; private set; }
    public Integer CurrentLenderIndexToSubmitTo { get; private set; }
    public Boolean IsSubmissionSuccessful { get; private set; }
    public Boolean IsSubmissionInProgress { get; private set; }
    public List<Message> QuoteSubmissionResponses { get; private set; }
    //public List<SelectOption> SelectedLenderOptions { get; set; }

    public LenderSubmission(ApexPages.StandardController stdController) {
        this.ProductSelected = false;
        this.APPLICATION = (Application__c)stdController.getRecord();
        if(APPLICATION.Broker_Fee__c == null){
            Utility.addErrorMessage('Broker Fee must be set on application. Please update the application to have a broker fee');
        }
        this.CanSubmitToLender = false;
        this.CurrentLenderIndexToSubmitTo = 0;
        this.IsSubmissionSuccessful = false;
        this.QuoteSubmissionResponses = new List<Message>();
        //this.SelectedLenderOptions = new List<SelectOption>();
        this.ActiveQuotes = getActiveQuotes();
    }

    public Boolean getHasLenderReference(){
        return LenderReference != null;
    }

    public PageReference submitToLenderGateway(){
        CurrentLenderIndexToSubmitTo = 0;
        IsSubmissionSuccessful = false;
        IsSubmissionInProgress = true;
        QuoteSubmissionResponses.clear();
        //if(!SelectedLenderOptions.isEmpty()){
            processSingleLenderGatewaySubmission();
        //}else{
        //    Utility.addErrorMessage('No Lenders selected. Select at least one Lender.');
        //}
        return null;
    }

    public PageReference processSingleLenderGatewaySubmission(){
        Quote__c current_quote = ActiveQuotes.get(CurrentLenderIndexToSubmitTo);
        LenderIntegrationName = getLenderToSubmitTo();
        LGIntegration.LenderExchangeResult result = LGIntegration.executeLenderExchange(SecuredLoansIntegrationModels.getAllApplicationData(APPLICATION.Id), LenderIntegrationName);
        LatestLenderExchangeResult = result;

        System.debug(LoggingLevel.ERROR, 'LatestLenderExchangeResult = ' + LatestLenderExchangeResult);

        if(result.IsSuccessful){
            populateDocumentsList(result.Documents);
            if(result.ProductsOffered != null && !result.ProductsOffered.isEmpty()){
                IsSubmissionSuccessful = true;
                IsSubmissionInProgress = false;
                CurrentLenderIndexToSubmitTo = 0;
                populateProductsOfferedList(result.ProductsOffered, result.LenderReferenceId);
            } else {
                displayErrorsForLender(result, LenderIntegrationName);
                CurrentLenderIndexToSubmitTo++;
            }
        } else {
            addStandardError(result.getMessages());
            CurrentLenderIndexToSubmitTo++;
        }
        if(result.LenderReferenceId != null){
            populateLenderReferenceOnQuote(result.LenderReferenceId);
            LenderReference = result.LenderReferenceId;
        }
        String messages = formatPageMessages();
        addLogRecord(APPLICATION.Id, current_quote.Id, current_quote.Lender_Fee__c, result.IsSuccessful, result.Id, messages, result.LenderReferenceId);
        if(UserInfo.getProfileId() == '00eU0000000iZYxIAM' && result.Id != null){
            //Utility.addInfoMessage(result.Id);
            QuoteSubmissionResponses.add(new Message('INFO', result.Id));
        }
        CanSubmitToLender = true;
        if(CurrentLenderIndexToSubmitTo >= ActiveQuotes.size()){
            IsSubmissionInProgress = false;
            CurrentLenderIndexToSubmitTo = 0;
        }
        return null;
    }

    public String getLenderToSubmitTo(){
        /*if(SelectedLenderOptions.size() > CurrentLenderIndexToSubmitTo){
            return SelectedLenderOptions.get(CurrentLenderIndexToSubmitTo).getValue();
        }else{
            CurrentLenderIndexToSubmitTo = 0;
        }*/
        if(ActiveQuotes.size() > CurrentLenderIndexToSubmitTo){
            return ActiveQuotes.get(CurrentLenderIndexToSubmitTo).Lender_Fee__r.Integration_Name__c;
        }else{
            CurrentLenderIndexToSubmitTo = 0;
            IsSubmissionInProgress = false;
        }
        return null;
    }

    @TestVisible
    private String formatPageMessages(){
        String formatted_messages = '';
        ApexPages.Message[] all_messages = ApexPages.getMessages();
        Integer number_of_messages = all_messages.size();
        for(Integer i=0; i<number_of_messages; i++){
            if(i>0){
                formatted_messages += '<br/>';
            }
            formatted_messages += all_messages.get(i).getSummary();
        }
        return formatted_messages;
    }

    @future
    private static void addLogRecord(Id app_id, Id quote_id, Id lender_id, Boolean is_successful, String submission_id, String text_result, String lender_ref){
        Lender_Submission_Log__c log = new Lender_Submission_Log__c();
        log.Application__c = app_id;
        log.Quote__c = quote_id;
        log.Lender__c = lender_id;
        log.Is_Successful__c = is_successful;
        log.Submission_Id__c = submission_id;
        log.Lender_Response__c = text_result;
        log.Lender_Reference_Id__c = lender_ref;
        insert log;
    }

    private void populateLenderReferenceOnQuote(String reference_id){
        ActiveQuotes.get(CurrentLenderIndexToSubmitTo).Lender_Reference__c = reference_id;
        try{
            //update ActiveQuotes.get(CurrentLenderIndexToSubmitTo);
        }
        catch (Exception e) {
            Utility.addErrorMessage('Something went wrong setting the reference Id on the related quote message is: ' + e.getMessage());
        }
    }

    private void addStandardError(List<String> errors){
        String error_string = '<ol>';
        if(errors != null && !errors.isEmpty()){
            for(String s:errors){
                error_string += '<li>' + s + '</li>';
            }
        } else {
            error_string += '<li> An Unknown Error Occurred. Please Try again. </li>';
        }
        error_string += '</ol>';
        //Utility.addErrorMessage(error_string);
        QuoteSubmissionResponses.add(new Message('ERROR', error_string));
    }

    private void displayErrorsForLender(LGIntegration.LenderExchangeResult result, String lender){
        if(lender != null && lender.toLowerCase() == 'shawbrook'){
            String message = 'The case ' + APPLICATION.Name + ' has been successfully submitted to Shawbrook with Case Reference ' + result.LenderReferenceId + '<br />';
            if(result.hasMessages()){
                message += 'This case failed for reasons: <br />';
                message += '<ol>';
                for(String error:result.getMessages()){
                    message += '<li>' + error + '</li>';
                }
                message += '</ol>';
            }
            message += 'You can refer this case for manual review via Shawbrooks System';
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, message));
            QuoteSubmissionResponses.add(new Message('INFO', message));
        } else {
            addStandardError(result.getMessages());
        }
    }

    public Boolean getShowResults(){
        return (ProductRows != null && Documents != null && IsSubmissionSuccessful);
    }

    public Boolean getHasQuote(){
        return ActiveQuotes != null && !ActiveQuotes.isEmpty();
    }

    private List<Quote__c> getActiveQuotes(){
        List<Quote__c> quotes = [SELECT Id, Name, Active__c, Interest_Rate__c, Lender_Fee__r.Name, Lender_Fee__r.Is_Integrated__c, Lender_Reference__c,
                                    Monthly_Repayment__c, Confirmed__c, Lender_Plan__r.Plan_Name__c, Lender_Plan_Rate__r.Rate__c, Lender_Plan__c,
                                    Lender_Plan_Rate__c, Lender_Fee__r.Integration_Name__c, APR__c, Lender_Fee_Value__c, TT_Fee__c, Solicitors_Costs__c,
                                    Title_Insurance__c  FROM Quote__c WHERE Application__c =:APPLICATION.Id AND Active__c = true
                                    ORDER BY Interest_Rate__c];
        if(quotes.isEmpty()){
            Utility.addErrorMessage('No Quotes found for Application ' + APPLICATION.Name + '<br />' +
                                                                                'Please use the underwriting wizard to select a quote');
            return null;
        }

        /*if(hasMultipleActiveQuotes(quotes)){
            Utility.addErrorMessage('Customer has more than one active quote, please recheck');
            return null;
        }*/

        if(!quotes.isEmpty() && quotes.get(0).Confirmed__c){
            Utility.addErrorMessage('A Confirmed Quote is already selected for this Customer');
            return null;
        }

        if(!quotes.isEmpty() && quotes.get(0).Lender_Fee__r != null){
            if(quotes.get(0).Lender_Fee__r.Is_Integrated__c){
                LenderIntegrationName = quotes.get(0).Lender_Fee__r.Integration_Name__c;
                CanSubmitToLender = true;
            } else {
                Utility.addInfoMessage('The selected Lender ' + quotes.get(0).Lender_Fee__r.Name +
                                                        ' is not integrated with our systems. <br /> Please Underwrite manually');

            }
        }

        return quotes;
    }

    private void populateDocumentsList(List<LGIntegration.Document> result_documents){
        Documents = new List<LGIntegration.Document>();
        if(documents != null){
            for(LGIntegration.Document doc:result_documents){
                Documents.add(doc);
            }
        }
    }

    private void populateProductsOfferedList(List<LGIntegration.Product> products, String lender_reference){
        ProductRows = new List<LenderProductRow>();
        if(products != null){
            for(LGIntegration.Product p:products){
                ProductRows.add(new LenderProductRow(p, ActiveQuotes.get(0), this, lender_reference));
            }
        }
    }

    private Boolean hasMultipleActiveQuotes(List<Quote__c> quotes){
        Integer count = 0;
        for(Quote__c q:quotes){
            if(q.Active__c) count ++;
            if(count == 2) return true;
        }
        return false;
    }

    public void insertDocuments(){
        List<Outstanding_Items__c> outstanding_documents =   new List<Outstanding_Items__c>();
        for(LGIntegration.Document d:Documents){
            Outstanding_Items__c oi = new Outstanding_Items__c();
            oi.Item_Type__c = 'Lender Document';
            oi.Application__c = APPLICATION.Id;
            oi.Item_Name__c = d.Name;
            oi.Lender_Reference__c = d.ReferenceCode;
            outstanding_documents.add(oi);
        }
        if(!outstanding_documents.isEmpty()){
            try{
                insert outstanding_documents;
            } catch (DmlException dex) {
                Utility.addErrorMessage('Unable to Insert Lender Documents, <br />Error is ' + dex.getMessage());
            } catch (Exception ex) {
                Utility.addErrorMessage('An Error has Occurred, Unable to Insert Lender Documents, <br />Error is ' + ex.getMessage());
            }
        }
    }

    /*public List<SelectOption> getLenderOptions(){
        List<SelectOption> options = new List<SelectOption>();
        for(Lender__c l:[SELECT Integration_Name__c, Name FROM Lender__c WHERE Is_Integrated__c = true]){
            options.add(new SelectOption(l.Integration_Name__c, l.Name));
        }
        return options;
    }*/

    public class LenderProductRow{
        public LGIntegration.Product Product { get; set; }

        private LenderSubmission ParentClass;
        private Quote__c Quote;
        private String LenderReference;

        public LenderProductRow(LGIntegration.Product product, Quote__c active_quote, LenderSubmission parent, String lender_reference){
            this.Product = product;
            this.Quote = active_quote;
            this.ParentClass = parent;
            this.LenderReference = lender_reference;
        }

        public PageReference selectProduct(){
            if(Quote.Lender_Plan__r.Plan_Name__c != Product.Name){
                Quote = setPlanByName(Product.Name, Quote);
            }
            if(Quote.Lender_Plan_Rate__r.Rate__c != Product.InterestRate){
                Quote = setRateByRate(Product.InterestRate, Quote);
            }
            Quote.Confirmed__c = true;
            Quote.Interest_Rate__c = Product.InterestRate;
            Quote.Lender_Reference__c = LenderReference;
            Quote.Monthly_Repayment__c = Product.MonthlyRepayment;
            Quote.Redirect_URL__c = ParentClass.LatestLenderExchangeResult.RedirectUrl;
            try{
                update Quote;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Quote Confirmed with Lender'));
                ParentClass.ProductSelected = true;
            } catch (DmlException dex) {
                Utility.addErrorMessage('Unable to Update Quote, <br /> Error is ' + dex.getMessage());
            } catch (Exception ex) {
                Utility.addErrorMessage('An Error has Occurred, <br /> Error is ' + ex.getMessage());
            }
            ParentClass.insertDocuments();
            return null;
        }

        private Quote__c setPlanByName(String plan_name, Quote__c active_quote){
            for(Lender_Plan__c lp:[Select Id, Name,Lender__c, Plan_Name__c from Lender_Plan__c where Plan_Name__c =:plan_name]){
                if(lp.Lender__c == active_quote.Lender_Fee__c){
                    active_quote.Lender_Plan__c = lp.Id;
                    Utility.addInfoMessage('Quote Lender Plan Updated to ' + lp.Name);
                    break;
                }
            }
            return active_quote;
        }

        private Quote__c setRateByRate(Double interest_rate, Quote__c active_quote){
            for(Lender_Plan_Rate__c lpr:[Select Id, Name, Rate__c, Lender_Plan__r.Lender_Fee__c from Lender_Plan_Rate__c where Rate__c =:interest_rate
                                                                                                        AND Lender_Plan__r.Lender__c =:active_quote.Lender_Fee__c]){
                active_quote.Lender_Plan_Rate__c = lpr.Id;
                Utility.addInfoMessage('Quote Lender Plan Rate Updated to ' + lpr.Name);
                break;
            }
            return active_quote;
        }
    }

    private class Message{
        public String summary {get; private set;}
        public String severity {get; private set;}

        public Message(String sev, String mes){
            this.severity = sev;
            this.summary = mes;
        }
    }
}