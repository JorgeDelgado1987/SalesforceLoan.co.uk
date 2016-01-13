public without sharing class QuoteTriggerHandler extends TriggerHandler {


////////////////////////////////////////////////////
//
// 02/10/2014 - Simon Parker
// Eddie Bates  23/01/2014    	JIRA SEC-246. Added updateApplicationLender() and updateApplication() for Quote Trigger
////////////////////////////////////////////////////

    public static boolean IsRecursiveUpdate=false ;

    public QuoteTriggerHandler() {
        //  Allow both before and after triggers
        preventRecursiveTrigger_Before(999);
        preventRecursiveTrigger_After(999);
    }


// *******************************************
// ************* After Insert ****************
// *******************************************
     public override void afterInsert(List<SObject> newObjects, Map<Id, SObject> newObjectsMap)
    {
        List<Quote__c> newQuotes = (List<Quote__c>)newObjects;

        if (IsRecursiveUpdate==false){
            IsRecursiveUpdate = true;
            calcAPR(newQuotes);
        }

        IsRecursiveUpdate = false;
        updateApplicationLender(newQuotes, 'insert');
        updatesForActiveQuotes(newQuotes);
    }

// *******************************************
// ************* After Update ****************
// *******************************************
    public override void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id, SObject> oldObjectsMap, Map<Id, SObject> newObjectsMap)
    {
        List<Quote__c> newQuotes = (List<Quote__c>)newObjects;

        if (IsRecursiveUpdate==false){
            IsRecursiveUpdate = true;
            calcAPR(newQuotes);
        }

        IsRecursiveUpdate = false;
        updateApplicationLender(newQuotes, 'update');
        updatesForActiveQuotes(newQuotes);
    }

/// *************************************************************************************************************************************************
/// ************************************* Sub Methods Below Here ************************************************************************************
/// *************************************************************************************************************************************************

    private void calcAPR(List<Quote__c> newQuotes){

        Set<Id> QuoteIds = (new Map<Id,Quote__c>(newQuotes)).keySet();
        List<Quote__c> theQuotes = [Select id,APR__c, Application__r.Loan_Amount__c, Estimated_Monthly_Repayment__c, Application__r.Loan_Term_Months__c from Quote__c WHERE id IN:QuoteIds];
        List<Quote__c> updatelist = new List<Quote__c>();

        for (Quote__c thisQuote : theQuotes){
            if ((thisQuote.Application__r.Loan_Amount__c > 0) && (thisQuote.Estimated_Monthly_Repayment__c > 0) && (thisQuote.Application__r.Loan_Term_Months__c > 0)){
                thisQuote.APR__c = APR.calculateAPR(thisQuote.Application__r.Loan_Amount__c, thisQuote.Estimated_Monthly_Repayment__c, integer.valueOf(thisQuote.Application__r.Loan_Term_Months__c));
                updatelist.add(thisQuote);
            }
        }
        update updatelist;
    }

    private void updateApplicationLender(List<Quote__c> newQuotes, String sType){


        Set<Id> QuoteIds = (new Map<Id,Quote__c>(newQuotes)).keySet();
        List<Quote__c> active_quotes = new List<Quote__c>();

        if(sType == 'insert'){
            active_quotes = [Select Id, Lender_Fee__c, Application__c, Active__c from Quote__c
                                    WHERE Id IN:QuoteIds AND Active__c = true AND Lender_Fee__c != null];
        }
        else if(sType == 'update'){
            active_quotes = [Select Id, Lender_Fee__c, Application__c, Active__c from Quote__c
                                    WHERE Id IN:QuoteIds AND Active__c = true AND Lender_Fee__c != null];
        }



        List<Application__c> applications_to_update = new List<Application__c>();

        for (Quote__c thisQuote : active_quotes){
                updateApplication(thisQuote);
        }
    }

    private void updateApplication(Quote__c theQuote){

        Savepoint sp = Database.setSavepoint();

        List<Application__c> theApplications = [Select Id, Lender__c from Application__c
                                    WHERE Id =:theQuote.Application__c];
        List<Application__c> applications_to_update = new List<Application__c>();

        if (theApplications.size()>0){

                For(Application__c application : theApplications){
                    application.Lender__c = theQuote.Lender_Fee__c;
                    applications_to_update.add(application);
                }
            }
        if (applications_to_update.size() > 0){

            try
            {
                update applications_to_update;
            }
            catch (System.DmlException e)
            {
                System.debug('ERROR: Not able to Update Applications Lender__c: ' + e);
                Database.rollback(sp);
            }
        }
    }

    private void updatesForActiveQuotes(List<Quote__c> newQuotes) {

        List<Quote__c> quotesToUpdate = new List<Quote__c>();

        for(Quote__c curQuote : newQuotes) {
            if(curQuote.Active__c == true) {
                quotesToUpdate.add(curQuote);
            }
        }

        if(!quotesToUpdate.isEmpty()) {
            //deactivateApplicationsOtherActiveQuotes(quotesToUpdate);
            //updateNewQuotesApplications(quotesToUpdate);
        }

    }

    private void deactivateApplicationsOtherActiveQuotes(List<Quote__c> newActiveQuotes) {

        Set<Id> applicationsWithNewActiveQuote = new Set<Id>();
        Set<Id> newActiveQuoteIds = new Set<Id>();
        for(Quote__c curQuote : newActiveQuotes) {
            applicationsWithNewActiveQuote.add(curQuote.Application__c);
            newActiveQuoteIds.add(curQuote.Id);
        }

        List<Quote__c> quotesToDeactivate = [ SELECT Id, Application__c, Active__c
                                              FROM Quote__c
                                              WHERE Application__c IN :applicationsWithNewActiveQuote
                                                AND Active__c = true
                                                AND Id NOT IN :newActiveQuoteIds ];

        if(!quotesToDeactivate.isEmpty()) {
            for(Quote__c curQuote : quotesToDeactivate) {
                curQuote.Active__c = false;
            }
            Update quotesToDeactivate;
        }

    }

    private void updateNewQuotesApplications(List<Quote__c> newActiveQuotes) {

        Set<Id> applicationsWithNewActiveQuote = new Set<Id>();
        for(Quote__c curQuote : newActiveQuotes) {
            applicationsWithNewActiveQuote.add(curQuote.Application__c);
        }

        List<Application__c> applicationsForNewActiveQuotes = [ SELECT Id, Total_Lender_Fees__c, Monthly_Repayment__c, Application_Value__c
                                                                  FROM Application__c
                                                                  WHERE Id IN :applicationsWithNewActiveQuote ];

        if(!applicationsForNewActiveQuotes.isEmpty()) {

            Map<Id, Application__c> applicationsToUpdateMap = new Map<Id, Application__c>();
            for(Application__c curApplication : applicationsForNewActiveQuotes) {
                applicationsToUpdateMap.put(curApplication.Id, curApplication);
            }

            List<Application__c> applicationsToUpdate = new List<Application__c>();
            for(Quote__c curQuote : newActiveQuotes) {
                Application__c curApplication = applicationsToUpdateMap.get(curQuote.Application__c);
                curApplication.Total_Lender_Fees__c = curQuote.Total_Fees__c;
                curApplication.Monthly_Repayment__c = curQuote.Monthly_Repayment__c;
                curApplication.Application_Value__c = curQuote.Total_Remuneration__c;
                applicationsToUpdate.add(curApplication);
            }

            if(!applicationsToUpdate.isEmpty()) {
                Update applicationsToUpdate;
            }

        }

    }
}