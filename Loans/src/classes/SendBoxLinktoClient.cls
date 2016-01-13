public class SendBoxLinktoClient {
	 @InvocableMethod(label='Send Box URL' description='Sends email to Applicant with link to most reecent Box document.')
	public static void sendEmailtoClientBox(List<String> applicationIDs){
		String applicationID = applicationIDs[0];
		WebmergeCaller.sendEmailtoClientBox(applicationID);
		/*
		String boxshareurl = BoxUtilities.getRecentLenderDocShareURL(applicationID);

		Applicant__c thisApplicant = new Applicant__c();
		List<Applicant__c> theApplicants = [Select id, First_Name__c, Last_Name__c, Email_Address__c, Is_Primary__c from Applicant__c WHERE Application__c=:applicationID];
		if (theApplicants.size()>0){
			thisApplicant = theApplicants[0];
			if (!String.isEmpty(thisApplicant.Email_Address__c)){
				// Send Email to Applicant
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setUseSignature(false);
				mail.setSaveAsActivity(false);
				mail.setToAddresses(new String[] {thisApplicant.Email_Address__c});
				mail.setSubject('Your Loan Application Documents');
					string Content = '<span style="font-family:arial; color:#28476C;font-size:9pt;">'+
                    'Hello '+ thisApplicant.First_Name__c + ' ' + thisApplicant.Last_Name__c+
                    '<br /><br />'+
                    '<br /><br />'+
                    'Your Loan Application documents are now ready for your completion and signature.'+
                    '<br /><br />'+
                    'Please click on the link below to view and download your documents:'+
                     '<br /><br />'+
                     boxshareurl +
                      '<br /><br />'; 
				mail.setHtmlBody(Content); 
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
			}

		}
		//upsert BoxAuth.authInfo;
		*/
	}

}