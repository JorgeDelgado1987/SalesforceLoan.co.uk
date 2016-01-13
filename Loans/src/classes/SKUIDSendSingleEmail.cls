global class SKUIDSendSingleEmail {
    webservice static CommsEmailService.SendResult send(Id applicant_id, String template_name){
        CommsEmailService.SendResult emailSendResult = new CommsEmailService.SendResult();
        Applicant__c applicant = [Select Id, Application__r.Loan_Amount__c, Email_Address__c, First_Name__c, Last_Name__c,
            Application__r.Case_Manager__r.Email, Application__r.Case_Manager__r.FirstName
            from Applicant__c where Id=:applicant_id];

        if(applicant.Email_Address__c != null){
            try{
                CommsEmailService.Recipient recipient = new CommsEmailService.Recipient(applicant.Email_Address__c)
                                                                             .setName(applicant.First_Name__c + ' ' + applicant.Last_Name__c);
                recipient.setMergeData('FirstName', applicant.First_Name__c);
                recipient.setMergeData('LoanAmount', applicant.Application__r.Loan_Amount__c);
                recipient.setMergeData('LoanExpertEmail', applicant.Application__r.Case_Manager__r.Email);
                recipient.setMergeData('LoanExpertFirstName', applicant.Application__r.Case_Manager__r.FirstName);
                CommsEmailService.Template template = new CommsEmailService.Template(template_name, false);

                emailSendResult = CommsEmailService.sendEmailNow(recipient, template);
                if(!emailSendResult.IsSuccess()){
                    System.debug('Error: Unable to send Email the Following Errors Occurred');
                    for(String s:emailsendResult.getErrors()){
                        System.debug('Error: ' + s);
                    }
                }
            }
            catch (Exception ex) {
                System.debug('ERROR: Not able to sendWelcomeEmail: ' + ex);
            }
        }
        return emailSendResult;
    }
}