global class SKUIDsubmitToLG {

	private static String thisApplication;
	private static String thisLender;
	private static String returnMessage;

	// 10/04/2015 - Simon Parker
	// webservice to submit application to Lender Gateway from SKUID page snippet

	webservice static String submit(String applicationid, String lendername){

		system.debug (applicationid + ' ' + lendername);
		thisApplication = applicationid;
		thisLender = lendername;
		returnmessage = '';

		LGIntegration.LenderExchangeResult result = LGIntegration.executeLenderExchange(SecuredLoansIntegrationModels.getAllApplicationData(applicationid), lendername);
        
        system.debug (result);
        system.debug (result.RawResult);

        if(result.IsSuccessful){
        	 if(result.ProductsOffered != null && !result.ProductsOffered.isEmpty()){
        	 	 createQuote(result.ProductsOffered, result.LenderReferenceId);
            } else {
               addStandardError(result.getMessages(LGIntegration.MessageType.ERROR));
            }
        }
        else{
        	addStandardError(result.getMessages(LGIntegration.MessageType.ERROR));
        }


		return returnMessage;
	}

	private static void createQuote(List<LGIntegration.Product> products, String lender_reference){
        if(products != null){
        	system.debug('thisLender = '+thisLender);
        	List<Lender__c> lender = [Select id, Integration_Name__c from Lender__c WHERE Integration_Name__c=:thisLender];
        	if (lender.size()>0){
	            for(LGIntegration.Product p:products){
	            	try{
	            		Quote__c newQuote = new Quote__c();
		            	newQuote.Lender_Fee__c = lender[0].id;
		            	newQuote.Application__c = thisApplication;
		            	newQuote.Lender_Reference__c = lender_reference;
		            	newQuote.APR__c = p.APR;
		            	newQuote.Interest_Rate__c = p.InterestRate;
		            	newQuote.Lender_Fee_Value__c = p.LenderFee;
		            	newQuote.Monthly_Repayment__c = p.MonthlyRepayment;
		            	newQuote.Solicitors_Costs__c = p.SolicitorsCosts;
		            	newQuote.TT_Fee__c = p.TTFee;
		            	newQuote.Title_Insurance__c = p.TitleInsurance;
		            	insert newQuote;
		            	returnMessage = 'Success: New Quote created.';
	            	}
	            	catch(Exception e){
	            		returnMessage = 'Problem creating new Quote record - error = ' + e;
	            	}	
	            }
            }
            else{
            	returnMessage = 'Problem creating new Quote record';
            }
        }
    }

    private static void addStandardError(List<String> errors){
        String error_string = '';
        if(errors != null && !errors.isEmpty()){
            for(String s:errors){
                error_string += s + '<br />';
            }
        } else {
            error_string = 'An Unknown Error Occurred. Please Try again.';
        }
        returnMessage = 'The following Errors Occurred: ' + error_string;
    }
}